## File name to use in search: snakefile_prepare_migration_data.smk ##

# The following rule prepares migration data for all authors
rule prepare_data_for_migration:
    input:
        GEONAME_REGION_RECODE,
        POPULATION,
        INTERNATIONAL,
        INTERNAL
    output:
        MIGRATION_MEASURES
    log:
        "logs/prepare_data_for_migration.log"
    shell:
        "(python workflow/scripts/prepare_migration_data_v2_scaled_up.py --input {input} --output {output}) 2> {log}"

# prepare by author attributes
rule prepare_data_for_migration_BY_ATTRIBUTE:
    input:
        GEONAME_REGION_RECODE,
        POPULATION_ATTRIBUTE,
        INTERNATIONAL,
        INTERNAL
    output:
        MIGRATION_MEASURES_BY_ATTRIBUTE
    log:
        MIGRATION_MEASURES_BY_ATTRIBUTE_LOG
    shell:
        "(python workflow/scripts/prepare_migration_data_disaggregate_by_author_attributes.py --input {input} --DISAGGREGATION {wildcards.disagr_level} --output {output}) 2> {log}"
