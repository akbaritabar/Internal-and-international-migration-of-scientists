## File name to use in search: percentage_of_IN_INT_mobile_nonmobile_per_population.py ##

# Python script that use DuckDB and SQL script for data processing/reshaping

# for data handling
import duckdb
import pandas as pd
import tabulate
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
#### overall % of mobile, non-mobile internal/international ####
# ============================

# Previously, I had reported the count of unique researchers having more than 1 country or region of affiliation as potentially mobile authors using:

# N authors
lg("N authors: ")
lg(duckdb.sql(f"""select count(distinct author_id) from '{args.input[0]}'""").df())

# N with 2+ regions
lg("N with 2+ regions")
lg(duckdb.sql(f"""select count(distinct author_id) from '{args.input[0]}' where n_regions > 1""").df())

# N with 2+ countries
lg("N with 2+ countries")
lg(duckdb.sql(f"""select count(distinct author_id) from '{args.input[0]}' where n_countries > 1""").df())


# -- 2024-01-02, in this script, I am taking "internal", and "international" mobility results using mode-based method, to count unique mobile authors, then use the ROR authorship records we used in the paper to calculate percentage of unique mobile authors to all authors while limiting the years to 1998-2017 which we analyzed in paper

query = f"""
-- Unique number of scholars from 1996-2020; our main data for analysis
CREATE OR REPLACE VIEW POP1 AS
SELECT 
    '1996-2020' as period_analyzed,
    'Population' as metric,
    count(DISTINCT author_id) as count_of_scholars_or_pubs
from '{args.input[1]}' 
where pubyear > 1995
and pubyear < 2021
and author_id > 10
and disamb_ror_new_id is not null
and geonames_admin1_code is not null
and author_id is not null
and org_country3 is not null
;

CREATE OR REPLACE VIEW POP2 AS
-- Unique number of scholars from 1998-2017; subset of data used for migration analysis to be less prone to left- and right-censoring issues
SELECT 
    '1998-2017' as period_analyzed,
    'Population' as metric,    
    count(DISTINCT author_id) as count_of_scholars_or_pubs
from '{args.input[1]}' 
where pubyear > 1997
and pubyear < 2018
and author_id > 10
and disamb_ror_new_id is not null
and geonames_admin1_code is not null
and author_id is not null
and org_country3 is not null
;

CREATE OR REPLACE VIEW PUBS1 AS
SELECT 
    '1996-2020' as period_analyzed,
    'Publications' as metric,
    count(DISTINCT item_id) as count_of_scholars_or_pubs
from '{args.input[1]}' 
where pubyear > 1995
and pubyear < 2021
and author_id > 10
and disamb_ror_new_id is not null
and geonames_admin1_code is not null
and author_id is not null
and org_country3 is not null
;

CREATE OR REPLACE VIEW PUBS2 AS
-- Unique number of Publications from 1998-2017; subset of data used for migration analysis to be less prone to left- and right-censoring issues
SELECT 
    '1998-2017' as period_analyzed,
    'Publications' as metric,    
    count(DISTINCT item_id) as count_of_scholars_or_pubs
from '{args.input[1]}' 
where pubyear > 1997
and pubyear < 2018
and author_id > 10
and disamb_ror_new_id is not null
and geonames_admin1_code is not null
and author_id is not null
and org_country3 is not null
;

CREATE OR REPLACE VIEW IN1 AS
-- for internal mobility from 1996-2020; our main data for analysis
select 
    '1996-2020' as period_analyzed,
    'Internal' as metric,    
    count(DISTINCT internal.author_id) as count_of_scholars_or_pubs
from '{args.input[2]}' internal
where move_year > 1995
and move_year < 2021
and author_id > 10
;


CREATE OR REPLACE VIEW IN2 AS-- for internal mobility from 1998-2017; subset of data used for migration analysis to be less prone to left- and right-censoring issues
select 
    '1998-2017' as period_analyzed,
    'Internal' as metric,    
    count(DISTINCT internal.author_id) as count_of_scholars_or_pubs
from '{args.input[2]}' internal
where move_year > 1997
and move_year < 2018
and author_id > 10
;


CREATE OR REPLACE VIEW INT1 AS
-- for international mobility from 1996-2020; our main data for analysis
select 
    '1996-2020' as period_analyzed,
    'International' as metric,    
    count(DISTINCT international.author_id) as count_of_scholars_or_pubs
from '{args.input[3]}' international
where move_year > 1995
and move_year < 2021
and author_id > 10
;

CREATE OR REPLACE VIEW INT2 AS
-- for international mobility from 1998-2017; subset of data used for migration analysis to be less prone to left- and right-censoring issues
select 
    '1998-2017' as period_analyzed,
    'International' as metric,    
    count(DISTINCT international.author_id) as count_of_scholars_or_pubs
from '{args.input[3]}' international
where move_year > 1997
and move_year < 2018
and author_id > 10
;


CREATE OR REPLACE VIEW RES1 AS
SELECT * FROM POP1
UNION BY NAME
SELECT * FROM POP2
UNION BY NAME
SELECT * FROM IN1
UNION BY NAME
SELECT * FROM IN2
UNION BY NAME
SELECT * FROM INT1
UNION BY NAME
SELECT * FROM INT2
UNION BY NAME
SELECT * FROM PUBS1
UNION BY NAME
SELECT * FROM PUBS2
;

-- Final table of results with all counts and percentage per Population
SELECT 
    rr.*,
    (rr.Internal * 100 / Population) as IN_percent,
    (rr.International * 100 / Population) as INT_percent
FROM (
PIVOT RES1
ON metric
USING first(count_of_scholars_or_pubs)
) rr
;
"""

#### I replaced that approach by using mode-based method and count of mobile authors (and % over all authors), and also added the count of unique papers ####

## -- results are in latex table exported
results_df = duckdb.sql(query).df()

lg("DuckDB finished running SQL script with success.")


# change order of columns rename columns to be suitable and export to Latex
results_df = results_df[['period_analyzed', 'Internal', 'IN_percent', 'International', 'INT_percent', 'Population', 'Publications']]

headers2use = ['Period', 'Internally mobile', 'Internal %', 'Internationally mobile', 'International %', 'Population', 'Publications']

# convert to markdown (or latex) format
f = open(args.output[0], 'w')
f.write(tabulate.tabulate(results_df,
                          showindex=False,
                          headers=headers2use,
                          tablefmt='latex',
                          floatfmt=',.2f',
                          intfmt=","))
f.close()

lg(f"Table of results exported in: '{args.output[0]}'")
