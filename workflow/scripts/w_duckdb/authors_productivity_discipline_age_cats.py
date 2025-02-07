## File name to use in search: authors_productivity_discipline_age_cats.py ##

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

# -- join with the data I prepared at author level that includes discipline etc
# -- count population of scholars per year and discipline, age group, productivity level to use as denominator

query = f"""
copy(
SELECT 
    *,
    CASE 
        WHEN n_pub < 10 THEN 'Below-10'
        WHEN n_pub < 21 and n_pub > 9 THEN '10-20'
        WHEN n_pub < 51 and n_pub > 20 THEN '21-50'
        WHEN n_pub < 101 and n_pub > 50 THEN '51-100'
        WHEN n_pub < 201 and n_pub > 100 THEN '101-200'
        WHEN n_pub > 200 THEN 'Above-200'
        ELSE 'No-pub-check'
    END AS prod_cat,
    CASE 
        WHEN acadmic_age < 9 THEN 'Early-career'
        WHEN acadmic_age > 8 and acadmic_age < 17 THEN 'Mid-career'
        WHEN acadmic_age > 16 THEN 'Late-career'
        ELSE 'No-age-check' 
    END AS academic_age_cat,
    CASE 
        WHEN OECD_DESCRIPTION = 'Agricultural Sciences' THEN 'Agr-Eng-Nat'
        WHEN OECD_DESCRIPTION = 'Engineering and Technology' THEN 'Agr-Eng-Nat'
        WHEN OECD_DESCRIPTION = 'Natural Sciences' THEN 'Agr-Eng-Nat'
        WHEN OECD_DESCRIPTION = 'Humanities' THEN 'Hum-Soc'
        WHEN OECD_DESCRIPTION = 'Social Sciences' THEN 'Hum-Soc'
        WHEN OECD_DESCRIPTION = 'Medical and Health Sciences' THEN 'Med-Heal'
        ELSE 'No-Disc' 
    END AS fieldOfScience
from '{args.input[0]}'
)
to '{args.output[0]}' WITH (format parquet) 
;

"""

# to run
duckdb.sql(query)

# status report in log
lg('DuckDB ran the query and successfully finished!')






