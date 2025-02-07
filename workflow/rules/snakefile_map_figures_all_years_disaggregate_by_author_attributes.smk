## File name to use in search: snakefile_map_figures_all_years_disaggregate_by_author_attributes.smk ##

# ===========
## NMR MAPS Disaggregated by author attributes ##
# ===========

rule plot_map_NMR_AND_MEI_MAPS_DISAGGREGATED_ATTRIBUTE:
    input:
        rules.prepare_data_for_mapping_BY_ATTRIBUTE.output
    output:
        NMR_AND_MEI_MAPS_DISAGGREGATED_ATTRIBUTE
    log:
        NMR_AND_MEI_MAPS_DISAGGREGATED_ATTRIBUTE_LOG
    shell:
        "(python workflow/scripts/generic_src_mapping_figures.py --input {input} --MEASURE_MAPPED {wildcards.measure_mapped} --MIGRATION_SYSTEM {wildcards.migration_system} --GEO_REGION {wildcards.geo_region} --TIME_SPAN {wildcards.time_span} --DISAGGREGATION {wildcards.disagr_level} --VAR_CATEGORY {wildcards.disagr_catpair} --output {output}) 2> {log}"
