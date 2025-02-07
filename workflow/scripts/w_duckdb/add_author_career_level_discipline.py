## File name to use in search: add_author_career_level_discipline.py ##

# Python script that use DuckDB and SQL script for data processing/reshaping

# for data handling
import duckdb
import pandas as pd
import numpy as np
#### Results log and progress report ####
from tolog import lg

# to see more pandas columns & not to use scientific notation
pd.set_option('max_colwidth',100)
pd.set_option('display.float_format', '{:.2f}'.format)


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
#### Scopus RP 2020 data ####
# ============================

authors = pd.read_parquet(args.input[0])

q_2use = f"""
SELECT DISTINCT author_id, pk_items, pubyear
from '{args.input[1]}'
where pubyear > 1995
and pubyear < 2021
and author_id > 10
and disamb_ror_new_id is not null
and geonames_admin1_code is not null
and author_id is not null
and org_country3 is not null
;
"""

edges = duckdb.sql(q_2use).df()

# Scopus 2020 ASJC classification and OECD matching tables to join to papers

scp_classifications = pd.read_parquet(args.input[2])
oecd_classifications = pd.read_csv(args.input[3],dtype='str')

# filter scp to be only asjc
scp_classifications = scp_classifications.loc[scp_classifications.CLASSIFICATION_TYPE == 'ASJC']
# join scp and oecd disciplines & drop those without OECD classifications
# number of rows here increases as one pub can have multiple subject class assignments
scp_classifications = scp_classifications.merge(oecd_classifications, how='left', left_on='CLASSIFICATION', right_on='ASJC_CODE').dropna(subset=['OECD_DESCRIPTION'])

# limit to only needed columns
scp_classifications = scp_classifications[['FK_ITEMS', 'ASJC_DESCRIPTION', 'OECD_DESCRIPTION']]

# add a discipline count per paper
scp_classifications['n_disc'] = scp_classifications.groupby('FK_ITEMS')['OECD_DESCRIPTION'].transform('nunique')
# add a fractional discipline to paper (1/count_of_disciplines)
scp_classifications['frc_disc'] = 1 / scp_classifications['n_disc']

# ============================
#### Add one discipline per author ####
# ============================

# here we calculate proportion of publications per author in each discipline, and take the highest proportion as the discipline of that author

# add discipline to edges table (that includes all papers by an author)
edges_w_discipline = edges.copy()
edges_w_discipline = edges_w_discipline.merge(scp_classifications, how='left', left_on='pk_items', right_on='FK_ITEMS')

# # groupby an author, calculate proportion of papers in each discipline (among 6 top OECD categories)
edges_w_discipline['aut_disc'] = edges_w_discipline.groupby(['author_id','OECD_DESCRIPTION'])['frc_disc'].transform('sum')

# # for each author, take the discipline with highest fractional value, limit to only needed columns
authors_w_discipline = edges_w_discipline.sort_values('aut_disc', na_position="first").groupby(['author_id']).tail(1)[['author_id', 'OECD_DESCRIPTION', 'aut_disc']]
# # for those without a discipline, add a string to clarify
authors_w_discipline.loc[authors_w_discipline.aut_disc.isnull(), 'OECD_DESCRIPTION'] = 'No_discipline_assigned'

# join with other author measures using DuckDB and write to parquet
q_2use = f"""
copy (
SELECT *
from authors
join authors_w_discipline using(author_id)
)
to '{args.output[0]}' WITH (format parquet)
;
"""
# DO NOT RUN (unless data updated) write to parquet for future use
duckdb.sql(q_2use)

# status report in log
lg('DuckDB ran the query and successfully finished!')
