## File name to use in search: multiple_affiliations_per_author_career_year.py ##

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


# author level analysis of multiple affiliations over career

# -- take the ROR authorship data used for subnational paper and apply the same filters on years and exclude missing region information (not-geocoded ones) that is needed for internal migration

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


-- categorize authors' career years
-- aggregate the count of multiple affiliations at each unique author's career year, to categories of "Multiple_aff" or "Single_aff"
create or replace table categorize_author_career_years as
    select
        author_id,
        pubyear,
        --n_org_per_pub_cat, -- not needed anymore
        count(distinct item_id) as n_multaff_years,
        CASE 
            WHEN (n_org_per_pub_cat = 'Multiple_aff' and  n_multaff_years > 0) THEN 'Multiple_aff'
            WHEN (n_org_per_pub_cat = 'Single_aff' and  n_multaff_years > 0) THEN 'Single_aff' 
            ELSE 'Unknown 2' 
        END AS aut_stat_1y  
    from categorize_papers
    group by author_id, pubyear, n_org_per_pub_cat
;


create or replace table typology_of_affiliations as
select
    distinct
        author_id,
        pubyear,
        aff_type_y_cat
from (
    select 
        *, 
        count(distinct aut_stat_1y) over (partition by author_id, pubyear) as n_aff_type,
        CASE 
            WHEN n_aff_type > 1 THEN 'Both types'
            WHEN n_aff_type == 1 THEN 'One type' 
            ELSE 'Unknown 3' 
        END AS n_aff_type_y,
        CASE 
            WHEN n_aff_type_y == 'One type' THEN aut_stat_1y
            WHEN n_aff_type_y == 'Both types' THEN 'Both types' 
            ELSE 'Unknown 3' 
        END AS aff_type_y_cat
    from categorize_author_career_years
    )
;

-- export output to Python environment to plot etc.
select 
    *,
    count(distinct pubyear) over (partition by author_id, aff_type_y_cat) as n_years_in_type
from typology_of_affiliations
;

"""

author_year_mult_aff = duckdb.sql(query).df() # took 4 minutes on hydra 11 and used max 20GB RAM and about 30% CPU (wow!) to categorize 19,050,557 authors.

lg("DuckDB finished running SQL script with success.")

# in each year, how many unique authors have single or multiple affiliations?
summary_yearly_author_level_N = (
    author_year_mult_aff
    .groupby(['pubyear', 'aff_type_y_cat'])
    .author_id
    .nunique()
    .reset_index()
    .rename(columns={'author_id':'Count'})
    # exclude 2020 which is not complete
    .query("pubyear < 2020")
    )

# define order for affiliation type categories
affs_ordered = pd.Categorical(summary_yearly_author_level_N["aff_type_y_cat"], categories=['Single_aff', 'Multiple_aff', 'Both types'])

# assign to a new column in the DataFrame
summary_yearly_author_level_N = summary_yearly_author_level_N.assign(affs_ordered=affs_ordered)

summary_yearly_author_level_avg = author_year_mult_aff.groupby(['pubyear', 'aff_type_y_cat']).n_years_in_type.mean().reset_index().rename(columns={'n_years_in_type':'Average_years'})


# plot it
plot2save = (
        gg.ggplot(summary_yearly_author_level_N,
            gg.aes(x='pubyear', y='Count', color='affs_ordered', shape='affs_ordered', linetype='affs_ordered', group="affs_ordered")) +
        gg.geom_point(size=3, alpha=0.3) +
        gg.geom_line() +
        gg.scale_y_log10(limits=[20000, 4000000], labels=label_number(big_mark=',')) +
        gg.scale_color_manual(values=six_colors_colorblind, labels=['Single', 'Multiple', 'Both types']) +
        gg.scale_linetype_manual(values=['dashed', 'solid', 'dashdot'], labels=['Single', 'Multiple', 'Both types']) +
        gg.scale_shape_manual(values=['o', '^', 's'], labels=['Single', 'Multiple', 'Both types']) +
        gg.theme_bw() +
        gg.labs(x="Year", y='Count of authors', title='Author level analysis: \nAuthors with single vs. multiple affiliations', shape='', color='', linetype='') +
        gg.theme(panel_background=gg.element_rect(fill='gray', alpha=.08),
            legend_position="bottom", legend_direction='horizontal',
            axis_text_x=gg.element_text(hjust=0.5, size=10, angle=0),
            axis_text_y=gg.element_text(hjust=1, size=10),
            axis_title_x=gg.element_text(size=10),
            axis_title_y=gg.element_text(size=10),
            strip_text_x=gg.element_text(size=8),
            plot_title=gg.element_text(ha='left', ma='left', size=12, linespacing=1.25),
            figure_size=(6, 6))
              +
        gg.guides(color=gg.guide_legend(nrow=1), shape=gg.guide_legend(nrow=1), linetype=gg.guide_legend(nrow=1))
    )


gg.ggplot.save(plot2save, args.output[0], dpi=500, limitsize=False)

lg(f"Figure exported in: '{args.output[0]}'")


# ============================
#### additional analysis and summary tables on multiple affiliation authors ####
# ============================


# take summary statistics to show
summary_stat_mauthor_year_mult_aff = author_year_mult_aff.groupby(['aff_type_y_cat']).n_years_in_type.describe(percentiles=[.01, .1, .25, .5, .75, .90, .95, .99]).drop(columns='count').reset_index().rename(columns={'aff_type_y_cat':'Affiliation'})

count_of_unique_authors_2_join = author_year_mult_aff.groupby(['aff_type_y_cat']).author_id.nunique().reset_index().rename(columns={'aff_type_y_cat':'Affiliation', 'author_id':'Authors in category'})

# merge to results
summary_stat_mauthor_year_mult_aff = (
    summary_stat_mauthor_year_mult_aff
    .merge(count_of_unique_authors_2_join,
           on='Affiliation',
           how='left')
    # reorder columns
    [['Affiliation', 'Authors in category', 'mean', 'std', 'min', '1%', '10%', '25%', '50%','75%', '90%', '95%', '99%', 'max']]
)

headers2use = ['Affiliation', 'Authors in category', 'mean years', 'std', 'min', '1%', '10%', '25%', '50%','75%', '90%', '95%', '99%', 'max']

# convert to markdown (or latex) format
f = open(args.output[1], 'w')
f.write(tabulate.tabulate(summary_stat_mauthor_year_mult_aff,
                          showindex=False,
                          headers=headers2use,
                          tablefmt='latex',
                          floatfmt=',.0f',
                          intfmt=","))
f.close()

lg(f"Table exported in: '{args.output[1]}'")

####### Identifying a dominant typology throughout author's career #######

# an author's most dominant typology
author_dominant_typology = author_year_mult_aff.sort_values('n_years_in_type', na_position="first").groupby(['author_id']).tail(1)[['author_id', 'pubyear', 'aff_type_y_cat', 'n_years_in_type']]

# a summary of dominant typology per author over their career
summ_dominant_per_author = author_dominant_typology.groupby('aff_type_y_cat').author_id.nunique().reset_index().rename(columns={'author_id':'Count'})
# aff_type_y_cat
# Both types        147815 (0.77%)
# Multiple_aff      543201 (2.85%)
# Single_aff      18359541 (96.37%)

# add precent
summ_dominant_per_author['Percent'] = [str(round(ff, ndigits=2)) + '%' for ff in (summ_dominant_per_author.Count / summ_dominant_per_author.Count.sum()) * 100]

# this means ((18359541*100)/19050557) = 96.37% of authors have only single affiliations "THROUGHOUT THEIR CAREER", 0.78% experience "Both types" as dominant typology and 2.85% have "multiple affiliations" as their dominant typology

headers2use = ['Affiliation', 'N unique authors', 'Percent']

# convert to markdown (or latex) format
f = open(args.output[2], 'w')
f.write(tabulate.tabulate(summ_dominant_per_author,
                          showindex=False,
                          headers=headers2use,
                          tablefmt='latex',
                          floatfmt=',.2f',
                          intfmt=","))
f.close()

lg(f"Table exported in: '{args.output[2]}'")

# NOTE
# how about joining author ID with internal, international mobility and reporting if by mode-based method this author is identified as mobile in that year with multiple affiliation or not, or has they moved at all in their career i.e., if mode region/country changes or not?

# count unique authors in INTERNAL
lg(f"Count of authors who were internally mobile: ")
lg(
    duckdb.sql(f"""
    select
        count(distinct author_id) as n_authors_IN
    from
        '{args.input[1]}'
    """).df()
)
# 1328938

# join AFFILIATION TYPOLOGY results with INTERNAL and count authors
# who had multiple affiliations and were identified as mobile with mode-based method, and % of all
lg(f"Count of authors with multiple affiliation, who were internally mobile: ")
lg(
    duckdb.sql(f"""
    select
        count(distinct author_id) as n_mult_aff_mobile_IN
    from (
    select 
        *
    from 
        typology_of_affiliations t
    inner join (
        select
            ii.author_id,
            ii.from,
            ii.to,
            ii.move_year
        from 
            '{args.input[1]}' ii
        ) internal
        on 
            t.author_id = internal.author_id 
            and t.pubyear = internal.move_year
    where t.aff_type_y_cat == 'Multiple_aff'
    )
    """).df()
)

# N: 24216
# % of all: (24216*100)/1328938 = 1.82%

# count unique authors in INTERNATIONAL
lg(f"Count of authors who were internationally mobile: ")
lg(
    duckdb.sql(f"""
    select
        count(distinct author_id) as n_authors_INT
    from
        '{args.input[2]}'
    """).df()
)
# 847624

# join AFFILIATION TYPOLOGY results with INTERNATIONAL and count authors
# who had multiple affiliations and were identified as mobile with mode-based method, and % of all
lg(f"Count of authors with multiple affiliation, who were internationally mobile: ")
lg(
    duckdb.sql(f"""
    select
        count(distinct author_id) as n_mult_aff_mobile_INT
    from (
    select 
        *
    from 
        typology_of_affiliations t
    inner join (
        select
            ii.author_id,
            ii.from,
            ii.to,
            ii.move_year
        from 
            '{args.input[2]}' ii
        ) international
        on 
            t.author_id = international.author_id 
            and t.pubyear = international.move_year
    where t.aff_type_y_cat == 'Multiple_aff'
    )
    """).df()
)
# N: 22428
# % of all: (22428*100)/847624 = 2.65%

lg("Further analysis finished.")