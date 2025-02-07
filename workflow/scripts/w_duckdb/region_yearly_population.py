## File name to use in search: region_yearly_population.py ##

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

# -- count population of scholars per year and region to use as denominator

query = f"""
copy(
SELECT pubyear, geonames_admin1_code, count(DISTINCT author_id) as y_pop
from '{args.input[0]}' 
where pubyear > 1995
and pubyear < 2021
and author_id > 10
and disamb_ror_new_id is not null
and geonames_admin1_code is not null
and author_id is not null
and org_country3 is not null
group by pubyear, geonames_admin1_code
)
to '{args.output[0]}' WITH (format parquet) 
;

"""

# to run
duckdb.sql(query)

# status report in log
lg('DuckDB ran the query and successfully finished!')






