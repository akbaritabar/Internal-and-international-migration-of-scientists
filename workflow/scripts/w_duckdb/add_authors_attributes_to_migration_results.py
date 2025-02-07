## File name to use in search: add_authors_attributes_to_migration_results.py ##

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

# -- 2024-12-30, in this script, I am taking "internal", and "international" mobility results using mode-based method, subset the columns to only those we need (migration_from, migration_to, move_year, author_id) and then add the author attributes such as discipline, productivity, academic age to use in migration measures preparation to disaggregate based on these attributes


query = f"""
-- for internal mobility
copy (
select 
    internal.author_id,
    internal.from,
    internal.to,
    internal.move_year,
    author_measures.* exclude author_id
from '{args.input[0]}' internal
join (
        select *
        from '{args.input[1]}'
    ) author_measures
    using(author_id)
)
to '{args.output[0]}'
WITH (format parquet)
;


-- for international mobility
copy (
select 
    international.author_id,
    international.from,
    international.to,
    international.move_year,
    author_measures.* exclude author_id
from '{args.input[2]}' international
join (
        select *
        from '{args.input[1]}'
    ) author_measures
    using(author_id)
)
to '{args.output[1]}'
WITH (format parquet)
;

"""

# to run
duckdb.sql(query)

# status report in log
lg('DuckDB ran the query and successfully finished!')






