## File name to use in search: snakefile_map_figures.smk ##

# ===========
## NMR and MEI MAPS for all time_span combinations ##
# ===========

rule plot_map_NMR_AND_MEI_MAPS:
    input:
        rules.prepare_data_for_mapping.output
    output:
        NMR_AND_MEI_MAPS
    log:
        NMR_AND_MEI_MAPS_LOG
    shell:
        "(python workflow/scripts/generic_src_mapping_figures.py --input {input} --MEASURE_MAPPED {wildcards.measure_mapped} --MIGRATION_SYSTEM {wildcards.migration_system} --GEO_REGION {wildcards.geo_region} --TIME_SPAN {wildcards.time_span} --output {output}) 2> {log}"

