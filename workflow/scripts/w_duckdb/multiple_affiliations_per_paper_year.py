## File name to use in search: multiple_affiliations_per_paper_year.py ##

# Python script that use DuckDB and SQL script for data processing/reshaping

# for data handling
import duckdb
import pandas as pd
# to visualize
import plotnine as gg
# for log (10^3 etc) labels
from mizani.labels import label_number
# for description tables
import tabulate
#### Results log and progress report ####
from tolog import lg

# to see more pandas columns & not to use scientific notation
pd.set_option('max_colwidth',100)
pd.set_option('display.float_format', '{:.2f}'.format)

# from here: https://gist.github.com/thriveth/8560036
six_colors_colorblind = ['#377eb8', '#ff7f00', '#4daf4a', '#984ea3', '#e41a1c', '#dede00']

lg(f"These items are in the environment: {dir()}")

# ============================
#### For command line arguments ####
# ============================
import argparse
parser = argparse.ArgumentParser()

# System arguments
# use ", nargs='+'" if more than one input is given, below have to choose args.input[] and list element number to use
parser.add_argument("-i", "--input", help = "Input file to use",
                    type = str, required = True, nargs='+')
parser.add_argument("-o", "--output", help = "Output data path",
                    type = str, required = False, nargs='+')

args = parser.parse_args()

lg(f"Arguments received from command line: \n {args}")

# ============================
#### Run DuckDB SQL script ####
# ============================

# ============================
#### multiple affiliation authors ####
# ============================

# - [ ] for multiple affiliation, first assign single or multiple affiliation to each author of a paper, then group by authors and count unique years in typology (single/multiple aff), an author having multiple years of career with multiple affiliations could be counted to find the dominant type of affiliation i.e., single or multiple for the population 

# plus ?!, bring an example authorship record in pandas like in SMD paper to show how mode based method treats multiple affiliations in a year under same or multiple papers.

# Needs using RAW data, use DuckDB to speed up

query = f"""
-- categorize papers
-- count multiple affiliations at each paper level for each unique author, aggregate to categories of "Multiple_aff" or "Single_aff"
create or replace table categorize_papers as
    select 
        pubyear,
        item_id,
        author_id,
        count(distinct disamb_ror_new_id) as n_org_per_pub,
        CASE 
            WHEN n_org_per_pub > 1 THEN 'Multiple_aff'
            WHEN n_org_per_pub = 1 THEN 'Single_aff' 
            ELSE 'Unknown' 
        END AS n_org_per_pub_cat    
    from
        -- here using: our main authorship records i.e., ROR-scp_rp_2020_authorship
        (
        select 
                item_id,
                pubyear,
                author_id, 
                disamb_ror_new_id
        from
            '{args.input[0]}' r
            where pubyear > 1995
            and pubyear < 2021
            and author_id > 10
            and disamb_ror_new_id is not null
            and geonames_admin1_code is not null
            and author_id is not null
            and org_country3 is not null
        -- take only 10 authors for testing
            -- and author_id in 
            -- (select distinct author_id from '{args.input[0]}' limit 10)
        ) r
    group by
        pubyear, item_id, author_id
;

-- aggregate the results to each year to pass to Python
select
    pubyear,
    n_org_per_pub_cat,
    count(distinct author_id) as n_auts,
    count(distinct item_id) as n_pubs
from categorize_papers
group by pubyear, n_org_per_pub_cat
;

"""

# paper level analysis that causes fallacy of thinking "it is all multiple affiliation now", NOTE, see below for author-level result resolving this fallacy
paper_level_yearly_mult_aff = duckdb.sql(query).df() # took 4 minutes, hydra11

# status report in log
lg('DuckDB ran the query and successfully finished!')

# summarize to yearly changes and plot it
paper_level_yearly_mult_aff['pubyear'] = paper_level_yearly_mult_aff['pubyear'].astype(int)

# conver to long format to plot
paper_level_yearly_mult_aff_long = (
    pd.melt(paper_level_yearly_mult_aff,
            id_vars=['pubyear', 'n_org_per_pub_cat'], 
            value_vars=['n_auts', 'n_pubs'], 
            var_name='Publication_or_author', 
            value_name='Count')
            # keep only papers, authors in in next plot
            .query("Publication_or_author == 'n_pubs'")
            # exclude 2020 which is not complete
            .query("pubyear < 2020")
            )

# define order for affiliation type categories
affs_ordered_p = pd.Categorical(paper_level_yearly_mult_aff_long["n_org_per_pub_cat"], categories=['Single_aff', 'Multiple_aff'])

# assign to a new column in the DataFrame
paper_level_yearly_mult_aff_long = paper_level_yearly_mult_aff_long.assign(affs_ordered_p=affs_ordered_p)

# plot it
plot2save = (
        gg.ggplot(paper_level_yearly_mult_aff_long,
            gg.aes(x='pubyear', y='Count', color='affs_ordered_p', linetype='affs_ordered_p', shape='affs_ordered_p', group="affs_ordered_p")) +
        gg.geom_point(size=3, alpha=0.3) +
        gg.geom_line() +
        gg.scale_y_log10(limits=[20000, 4000000], labels=label_number(big_mark=',')) +
        gg.scale_color_manual(values=six_colors_colorblind, labels=['Single', 'Multiple']) +
        gg.scale_linetype_manual(values=['dashed', 'solid'], labels=['Single', 'Multiple']) +
        gg.scale_shape_manual(values=['o', '^'], labels=['Single', 'Multiple']) +
        gg.theme_bw() +
        gg.labs(x="Year", y='Count of publications', title='Publication level analysis: \nPublications with single vs. multiple affiliation authors', shape='', color='', linetype='') +
        gg.theme(panel_background=gg.element_rect(fill='gray', alpha=.08),legend_position="bottom", legend_direction='horizontal',
            axis_text_x=gg.element_text(hjust=0.5, size=10, angle=0),
            axis_text_y=gg.element_text(hjust=1, size=10),
            axis_title_x=gg.element_text(size=10),
            axis_title_y=gg.element_text(size=10),
            strip_text_x=gg.element_text(size=8),
            plot_title=gg.element_text(ha='left', ma='left', size=12, linespacing=1.25),
            figure_size=(6, 6)) +
        gg.guides(color=gg.guide_legend(nrow=1), linetype=gg.guide_legend(nrow=1))
    )


gg.ggplot.save(plot2save, args.output[0], dpi=500, limitsize=False)

lg(f"Figure exported in: '{args.output[0]}'")
