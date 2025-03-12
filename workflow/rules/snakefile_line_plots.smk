rule plot_nmr_lines_in_int_subnational_regions:
    input:
        MIGRATION_MEASURES
    output:
        NMR_REGION_LINE_PLOT_ONE_COUNTRY
    log:
        NMR_REGION_LINE_PLOT_ONE_COUNTRY_LOG
    shell:
        "(python workflow/scripts/subnational_regions_nmr_line_plots.py --input {input} --code2use {wildcards.code2use} --size2wrap1 {wildcards.size2wrap1} --size2wrap2 {wildcards.size2wrap2}  --output {output}) 2> {log}"

rule plot_cmi_line_internal_one_country:
    input:
        MIGRATION_MEASURES
    output:
        CMI_INTERNAL_LINE_PLOT_ONE_COUNTRY
    log:
        CMI_INTERNAL_LINE_PLOT_ONE_COUNTRY_LOG
    shell:
        "(python workflow/scripts/country_level_cmi_line_plots.py --input {input} --code2use {wildcards.code2use} --output {output}) 2> {log}"

rule plot_cmi_line_top_X_countries:
    input:
        MIGRATION_MEASURES
    output:
        CMI_INTERNAL_LINE_PLOT_MULT_COUNTRIES
    log:
        CMI_INTERNAL_LINE_PLOT_MULT_COUNTRIES_LOG
    shell:
        "(python workflow/scripts/top_countries_cmi_line_plots_facetted.py --input {input} --ncountry2use {wildcards.ncountry} --output {output}) 2> {log}"

# Aggregated NMR line plot (ANMR), for 500+ pop countries
rule plot_anmr_lines_in_int_subnational_regions:
    input:
        MIGRATION_MEASURES
    output:
        ANMR_REGION_LINE_PLOT_ONE_COUNTRY
    log:
        'logs/ANMR_REGION_LINE_PLOT_ONE_COUNTRY.log'
    shell:
        "(python workflow/scripts/subnational_regions_anmr_500plus_line_plots.py --input {input}  --output {output}) 2> {log}"

rule plot_migration_relative_importance_line_top_X_countries:
    input:
        MIGRATION_MEASURES
    output:
        MIGR_IMPORTANCE_IN_INT_LINE_PLOT_MULT_COUNTRIES
    log:
        MIGR_IMPORTANCE_IN_INT_LINE_PLOT_MULT_COUNTRIES_LOG
    shell:
        "(python workflow/scripts/top_countries_IN_INT_migration_relative_importance_line_plots_facetted.py --input {input} --ncountry2use {wildcards.ncountry} --output {output}) 2> {log}"
