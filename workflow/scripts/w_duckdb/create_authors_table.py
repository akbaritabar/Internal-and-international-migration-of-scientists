## File name to use in search: create_authors_table.py ##

# Python script that use DuckDB and SQL script for data processing/reshaping

# for data handling
import duckdb
#### Results log and progress report ####
from tolog import lg

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

# -- 1 authors table (for each author, id, years, orgs, countries, regions)

query = f"""
copy (
SELECT author_id,
	-- I am sorting based on years and item_id to take latest publication of the last year
	-- LAST(disamb_ror_new_id order by pubyear, item_id) org,
	-- LAST(org_country3 order by pubyear, item_id) country,
	-- LAST(geonames_admin1_code order by pubyear, item_id) region,
	min(pubyear) as start_y, 
	max(pubyear) as end_y,
	max(pubyear) - min(pubyear) as delta_y,
	2021 - min(pubyear) as acadmic_age,
	count(distinct item_id) as n_pub,
	count(distinct pubyear) as n_years,
	count(DISTINCT disamb_ror_new_id) n_orgs,
	count(DISTINCT org_country3) n_countries,
	count(DISTINCT geonames_admin1_code) n_regions
from '{args.input[0]}'
where pubyear > 1995
and pubyear < 2021
and author_id > 10
and disamb_ror_new_id is not null
and geonames_admin1_code is not null
and author_id is not null
and org_country3 is not null
group by author_id
)
to '{args.output[0]}' WITH (format parquet)
;
"""

# to run
duckdb.sql(query)

# status report in log
lg('DuckDB ran the query and successfully finished!')

