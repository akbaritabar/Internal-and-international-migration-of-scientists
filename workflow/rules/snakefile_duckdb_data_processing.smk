## File name to use in search: snakefile_duckdb_data_processing.smk ##

# ===========
## Different tasks/rules using DuckDB and RAW Scopus authorship data ##
# ===========

rule duckdb_create_authors_table:
    input:
        ancient(AUTHORSHIP)
    output:
        protected(AUTHORS_TABLE)
    log:
        'logs/AUTHORS_TABLE.log'
    shell:
        "(python workflow/scripts/w_duckdb/create_authors_table.py --input {input}  --output {output}) 2> {log}"


rule duckdb_add_career_level_discipline_of_authors:
    input:
        ancient(AUTHORS_TABLE),
        ancient(AUTHORSHIP),
        ancient(SCP_CLASSIFICATIONS),
        ancient(OECD_FIELDS)
    output:
        protected(SOME_OF_AUTHOR_ATTRIBUTES)
    log:
        'logs/SOME_OF_AUTHOR_ATTRIBUTES.log'
    shell:
        "(python workflow/scripts/w_duckdb/add_author_career_level_discipline.py --input {input}  --output {output}) 2> {log}"


rule duckdb_authors_productivity_discipline_age_cats:
    input:
        SOME_OF_AUTHOR_ATTRIBUTES
    output:
        protected(AUTHOR_ATTRIBUTES)
    log:
        'logs/AUTHOR_ATTRIBUTES.log'
    shell:
        "(python workflow/scripts/w_duckdb/authors_productivity_discipline_age_cats.py --input {input}  --output {output}) 2> {log}"

rule duckdb_add_author_attributes_to_migration_data:
    input:
        INTERNAL_PREV,
        AUTHOR_ATTRIBUTES,
        INTERNATIONAL_PREV
    output:
        INTERNAL,
        INTERNATIONAL
    log:
        'logs/add_author_attributes_INTERNAL_INTERNATIONAL.log'
    shell:
        "(python workflow/scripts/w_duckdb/add_authors_attributes_to_migration_results.py --input {input}  --output {output}) 2> {log}"


rule duckdb_region_yearly_population:
    input:
        ancient(AUTHORSHIP)
    output:
        POPULATION
    log:
        'logs/POPULATION.log'
    shell:
        "(python workflow/scripts/w_duckdb/region_yearly_population.py --input {input}  --output {output}) 2> {log}"

# population calculated by given author attribute (among productivity, age, and field of science)
rule duckdb_region_yearly_population_by_attribute:
    input:
        ancient(AUTHORSHIP),
        SOME_OF_AUTHOR_ATTRIBUTES
    output:
        POPULATION_ATTRIBUTE
    log:
        POPULATION_ATTRIBUTE_LOG
    shell:
        "(python workflow/scripts/w_duckdb/region_yearly_population_by_attribute.py --input {input} --DISAGGREGATION {wildcards.disagr_level}  --output {output}) 2> {log}"

# additional analysis on multiple affiliation authors etc
rule duckdb_multiple_affiliations_per_paper_year:
    input:
        ancient(AUTHORSHIP),
    output:
        PAPER_LEVEL_MULT_AUTHOR
    log:
        'logs/PAPER_LEVEL_MULT_AUTHOR.log'
    shell:
        "(python workflow/scripts/w_duckdb/multiple_affiliations_per_paper_year.py --input {input}  --output {output}) 2> {log}"


rule duckdb_multiple_affiliations_per_author_career_year:
    input:
        ancient(AUTHORSHIP),
        INTERNAL,
        INTERNATIONAL
    output:
        AUTHOR_LEVEL_MULT_AUTHOR,
        MULT_AFF_TYPOLOGY,
        MULT_AFF_TYP_DOMINANT
    log:
        'logs/AUTHOR_LEVEL_MULT_AUTHOR.log'
    shell:
        "(python workflow/scripts/w_duckdb/multiple_affiliations_per_author_career_year.py --input {input}  --output {output}) 2> {log}"


rule duckdb_multiple_affiliations_fake_and_read_example_authors:
    input:
        ancient(AUTHORSHIP)
    output:
        TOY_AUTHOR_EXAMPLE,
        TOY_AUTHOR_EXAMPLE_MODE,
        REAL_AUTHOR_EXAMPLE,
        REAL_AUTHOR_EXAMPLE_MODE
    log:
        'logs/REAL_AUTHOR_EXAMPLE_MODE.log'
    shell:
        "(python workflow/scripts/w_duckdb/example_fake_and_real_authors_w_multiple_affiliations.py --input {input}  --output {output}) 2> {log}"


rule duckdb_overall_percent_mobile_non_mobile_int_in:
    input:
        AUTHOR_ATTRIBUTES,
        ancient(AUTHORSHIP),
        INTERNAL,
        INTERNATIONAL
    output:
        OVERALL_MOBILE_NON_MOBILE
    log:
        'logs/OVERALL_MOBILE_NON_MOBILE.log'
    shell:
        "(python workflow/scripts/w_duckdb/percentage_of_IN_INT_mobile_nonmobile_per_population.py --input {input}  --output {output}) 2> {log}"


rule typology_of_regions_by_positive_negative_nmr:
    input:
        MIGRATION_MEASURES
    output:
        NMR_TYPOLOGY_PER_REGION,
        NMR_DOMINANT_TYPOLOGY_PER_REGION_REPL_DATA
    log:
        'logs/NMR_TYPOLOGY_PER_REGION.log'
    shell:
        "(python workflow/scripts/typology_of_nmr_for_regions.py --input {input}  --output {output}) 2> {log}"





