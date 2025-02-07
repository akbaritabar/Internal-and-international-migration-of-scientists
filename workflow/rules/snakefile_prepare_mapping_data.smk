## File name to use in search: snakefile_prepare_mapping_data.smk ##

rule prepare_data_for_mapping:
    input:
        GEONAME_DATA,
        GEONAME_BRIDGE_TABLE,
        rules.prepare_data_for_migration.output,
        NAT_LOWRES_PROVINCES,
        NAT_LOWRES_COUNTRY
    output:
        MAPPING_DATA_COUNTRY,
        MAPPING_DATA_REGION
    log:
        MAPPING_DATA_LOG
    shell:
        "(python workflow/scripts/prepare_data_for_mapping.py --input {input} --TIME_SPAN {wildcards.time_span} --output {output}) 2> {log}"

# by author attributes
rule prepare_data_for_mapping_BY_ATTRIBUTE:
    input:
        GEONAME_DATA,
        GEONAME_BRIDGE_TABLE,
        rules.prepare_data_for_migration_BY_ATTRIBUTE.output,
        NAT_LOWRES_PROVINCES,
        NAT_LOWRES_COUNTRY
    output:
        MAPPING_DATA_COUNTRY_BY_ATTRIBUTE,
        MAPPING_DATA_REGION_BY_ATTRIBUTE
    log:
        MAPPING_DATA_BY_ATTRIBUTE_LOG
    shell:
        "(python workflow/scripts/prepare_data_for_mapping_disaggregate_by_author_attributes.py --input {input} --TIME_SPAN {wildcards.time_span} --DISAGGREGATION {wildcards.disagr_level} --output {output}) 2> {log}"
