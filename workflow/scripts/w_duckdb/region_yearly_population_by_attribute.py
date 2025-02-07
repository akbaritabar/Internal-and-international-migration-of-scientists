## File name to use in search: region_yearly_population_by_acad_age.py ##

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
parser.add_argument("-dis", "--DISAGGREGATION", help = "Author attribute to disaggregate migration with",
                    type = str, required = True)
parser.add_argument("-o", "--output", help = "Output data path",
                    type = str, required = False, nargs='+')

args = parser.parse_args()

lg(f"Arguments received from command line: \n {args}")

# ============================
#### Run DuckDB SQL script ####
# ============================

# -- join with the data I prepared at author level that includes discipline etc
# -- count population of scholars per year and discipline, age group, productivity level to use as denominator

query_AGE = f"""
copy(
SELECT pubyear, geonames_admin1_code, academic_age_cat, count(DISTINCT author_id) as y_pop
from '{args.input[0]}' 
join (
    select author_id,
        CASE 
            WHEN acadmic_age < 9 THEN 'Early-career'
            WHEN acadmic_age > 8 and acadmic_age < 17 THEN 'Mid-career'
            WHEN acadmic_age > 16 THEN 'Late-career'
            ELSE 'No-age-check' 
        END AS academic_age_cat  
    from '{args.input[1]}')
    using (author_id)
where pubyear > 1995
and pubyear < 2021
and author_id > 10
and disamb_ror_new_id is not null
and geonames_admin1_code is not null
and author_id is not null
and org_country3 is not null
group by pubyear, geonames_admin1_code, academic_age_cat
)
to '{args.output[0]}' WITH (format parquet) 
;

"""

query_DISCIPLINE = f"""
copy(
SELECT pubyear, geonames_admin1_code, fieldOfScience, count(DISTINCT author_id) as y_pop
from '{args.input[0]}' 
join (
    select author_id,
        CASE 
            WHEN OECD_DESCRIPTION = 'Agricultural Sciences' THEN 'Agr-Eng-Nat'
            WHEN OECD_DESCRIPTION = 'Engineering and Technology' THEN 'Agr-Eng-Nat'
            WHEN OECD_DESCRIPTION = 'Natural Sciences' THEN 'Agr-Eng-Nat'
            WHEN OECD_DESCRIPTION = 'Humanities' THEN 'Hum-Soc'
            WHEN OECD_DESCRIPTION = 'Social Sciences' THEN 'Hum-Soc'
            WHEN OECD_DESCRIPTION = 'Medical and Health Sciences' THEN 'Med-Heal'
            ELSE 'No-Disc' 
        END AS fieldOfScience  
    from '{args.input[1]}')
    using (author_id)
where pubyear > 1995
and pubyear < 2021
and author_id > 10
and disamb_ror_new_id is not null
and geonames_admin1_code is not null
and author_id is not null
and org_country3 is not null
group by pubyear, geonames_admin1_code, fieldOfScience
)
to '{args.output[0]}' WITH (format parquet) 
;

"""


query_PRODUCTIVITY = f"""
copy(
SELECT pubyear, geonames_admin1_code, prod_cat, count(DISTINCT author_id) as y_pop
from '{args.input[0]}' 
join (
    select author_id,
        CASE 
            WHEN n_pub < 10 THEN 'Below-10'
            WHEN n_pub < 21 and n_pub > 9 THEN '10-20'
            WHEN n_pub < 51 and n_pub > 20 THEN '21-50'
            WHEN n_pub < 101 and n_pub > 50 THEN '51-100'
            WHEN n_pub < 201 and n_pub > 100 THEN '101-200'
            WHEN n_pub > 200 THEN 'Above-200'
            ELSE 'No-pub-check'
        END AS prod_cat  
    from '{args.input[1]}')
    using (author_id)
where pubyear > 1995
and pubyear < 2021
and author_id > 10
and disamb_ror_new_id is not null
and geonames_admin1_code is not null
and author_id is not null
and org_country3 is not null
group by pubyear, geonames_admin1_code, prod_cat
)
to '{args.output[0]}' WITH (format parquet) 
;

"""


# depending on the disaggregation measure used, take that variable from authors' attributes and use it below in group-by calls to disaggregate by it 
if args.DISAGGREGATION == 'PRODUCTIVITY':
    lg(f"Disaggregating: {args.DISAGGREGATION}")
    # to run
    duckdb.sql(query_PRODUCTIVITY)
elif args.DISAGGREGATION == 'AGE':
    lg(f"Disaggregating: {args.DISAGGREGATION}")
    # to run
    duckdb.sql(query_AGE)
elif args.DISAGGREGATION == 'DISCIPLINE':
    lg(f"Disaggregating: {args.DISAGGREGATION}")
    # to run
    duckdb.sql(query_DISCIPLINE)


# status report in log
lg('DuckDB ran the query and successfully finished!')






