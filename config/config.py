## File name to use in search: config.py ##

# ===========
## Author details ##
# ===========

# Script's author:      Aliakbar Akbaritabar
# Version:              2024-12-29
# Email:                akbaritabar@demogr.mpg.de
# GitHub:               https://github.com/akbaritabar
# Website:              https://www.demogr.mpg.de/en/about_us_6113/staff_directory_1899/aliakbar_akbaritabar_4098/

# Script for replication of analysis and figures from paper "Global subnational estimates of migration of scientists reveal large disparities in internal and international flows"
# Manuscript authors: Aliakbar Akbaritabar, Maciej Danko, Xinyi Zhao, Emilio Zagheni

# ===========
## Imports ##
# ===========
# shortcut for path join function
from os.path import join as ojn
from os import getcwd

# ===========
## Folders ##
# ===========

# TODO NOTE modify this according to the project folder
PROJECT_DIR = getcwd()

# An if condition to define if scratch drive should be used (during development) or the manuscript's folder (once finalized) to include figures in text
# TODO NOTE modify this according to the intended results/figures folder
SCRATCH_DRIVE = [False, True][1]

if SCRATCH_DRIVE:
    OUTPUTS_DIR = ojn(PROJECT_DIR, 'results')
else:
    # MANUSCRIPT FIGURES DIR
    MANUSCRIPT_DIR = ojn('U:\\', 'nc', 'w', 'mpidr', 'subnational', 'outputs')
    OUTPUTS_DIR = ojn(MANUSCRIPT_DIR, 'results')

INPUTS_DIR = ojn(PROJECT_DIR, 'resources')
LOGS_DIR = ojn(PROJECT_DIR, 'logs')
VIS_DIR = ojn(OUTPUTS_DIR, 'figures')
TABS_DIR = ojn(OUTPUTS_DIR, 'tables')

# Migration-event identification results
MIGRATION_DATA = ojn(INPUTS_DIR, 'migration')

# ===========
## Raw Scopus data ##
# ===========

## RAW SCOPUS DATA Folder ## NOTE licensed information, not sharable
RAW_SCP_DIR = ojn('G:\\', 'ali', 'scp_rp_2020')
OUTSIDE_NEXTCLOUD_DIR = ojn('U:\\', 'dataOutNC', 'scp_rp_2020')
# processed Scopus data, NOTE licensed information, not sharable
SCP_PROCESSED_DIR = ojn(INPUTS_DIR, 'scp_processed')

# NOTE these are large-scale authorship data prepared using Scopus records
# processing using these as input are marked with "ancient()" to be repeated
# only if absolutely necessary as these are computationally expensive to rerun

AUTHORSHIP = ojn(RAW_SCP_DIR, 'scp_rp_2020_authorship_orgs_1st_ROR.parquet')

# processed Scopus data, NOTE, still includes licensed information
AUTHORS_TABLE = ojn(SCP_PROCESSED_DIR, '20241230_scp_rp_2020_authors_table.parquet')
SOME_OF_AUTHOR_ATTRIBUTES = ojn(SCP_PROCESSED_DIR, '20241230_scp_rp_2020_authors_table_with_discipline.parquet')
AUTHOR_ATTRIBUTES = ojn(SCP_PROCESSED_DIR, '20241230_scp_rp_2020_authors_with_all_attributes.parquet')
# licensed information, not sharable
SCP_CLASSIFICATIONS = ojn(OUTSIDE_NEXTCLOUD_DIR, 'scp_rp_2020_classifications')
OECD_FIELDS = ojn(OUTSIDE_NEXTCLOUD_DIR, 'OECD_FIELDS_SCP2020.csv')

# Previous version of internal and international migration results to be processed and used, NOTE includes author information, not sharable
INTERNAL_PREV = ojn(MIGRATION_DATA, '3_intranational_mobility_province.csv')
INTERNATIONAL_PREV = ojn(MIGRATION_DATA, '2_international_mobility_province.csv')

# ===========
## Raw data for this project ##
# ===========

# migration measures, mode-based method

INTERNAL = ojn(MIGRATION_DATA, 'internal_mobility_province.parquet')
INTERNATIONAL = ojn(MIGRATION_DATA, 'international_mobility_province.parquet')

# data downloaded or prepared for mapping and joins
MAPPING_RAW_DATA = ojn(INPUTS_DIR, 'mapping')

NAT_LOWRES_COUNTRY = ojn(MAPPING_RAW_DATA, 'naturalearth_lowres', 'naturalearth_lowres.shp')
NAT_LOWRES_PROVINCES = ojn(MAPPING_RAW_DATA, 'ne_10m_admin_1_states_provinces.geojson')
GEONAME_BRIDGE_TABLE = ojn(MAPPING_RAW_DATA, 'Bridge_table_from_GeoNames.parquet')
GEONAME_DATA = ojn(MAPPING_RAW_DATA, 'geonames.csv')
GEONAME_REGION_RECODE = ojn(MAPPING_RAW_DATA, 'geonames_region_names_2_recode.csv')

# ===========
## Parameters ##
# ===========

TIME_SPAN = ['20122017', '19982017', '20002005', '20062011']
GEO_REGION = ['WORLD', 'EU']
MEASURE_MAPPED = ['NMR', 'MEI']
MIGRATION_SYSTEM = ['IN', 'INT', 'INTIN']
DISAGGREGATION = ['PRODUCTIVITY', 'AGE', 'DISCIPLINE']
FIG_EXT = ['png', 'pdf'][0] # figure format to save

# author attributes categories to use for disaggregation
VAR_CATEGORY_PROD = ['10-20', '21-50', '51-100', 'Below-10', '101-200', 'Above-200']
VAR_CATEGORY_AGE = ['Late-career', 'Mid-career', 'Early-career']
VAR_CATEGORY_DISC = ['Agr-Eng-Nat', 'Hum-Soc', 'Med-Heal', 'No-Disc']

# For subnational regions IN and INT NMR line plot figure
CODE2USE = ['US', 'UA', 'IT', 'MX', 'FR', 'DE']
CODE2USE2 = ['USA', 'UKR', 'ITA', 'MEX', 'FRA', 'DEU']
N_LARGEST_COUNTRIES = [10, 20]
SIZE2WRAP1 = [None]
SIZE2WRAP2 = [None]

# ===========
## Processed data ##
# ===========

# Population of subnational regions
POPULATION = ojn(OUTPUTS_DIR, f'pop_yearly_{TIME_SPAN[1]}.parquet')
# region's disaggregated populations by author attributes
POPULATION_ATTRIBUTE = ojn(OUTPUTS_DIR, 'attr_pop_yearly_{disagr_level}.parquet')
POPULATION_ATTRIBUTE_LOG = ojn(LOGS_DIR, 'lg_attr_pop_{disagr_level}.log')

MIGRATION_MEASURES = ojn(
    OUTPUTS_DIR, 
    f"migr_{TIME_SPAN[1]}.csv")

MIGRATION_MEASURES_BY_ATTRIBUTE = ojn(
    OUTPUTS_DIR, 
    "attr_migr_{disagr_level}.csv")

MIGRATION_MEASURES_BY_ATTRIBUTE_LOG = ojn(
    LOGS_DIR, 
    "lg_migr_{disagr_level}.log")

# state and country level mapping data
MAPPING_DATA_COUNTRY = ojn(
    OUTPUTS_DIR,
    "country_map_{time_span}.parquet"
)

MAPPING_DATA_REGION = ojn(
    OUTPUTS_DIR,
    "region_map_{time_span}.parquet"
)

MAPPING_DATA_LOG = ojn(
    LOGS_DIR,
    "lg_cntreg_map_{time_span}.log"
)

# for all attributes
MAPPING_DATA_COUNTRY_BY_ATTRIBUTE = ojn(
    OUTPUTS_DIR,
    "atr_cnt_map_{time_span}_{disagr_level}.parquet"
)
MAPPING_DATA_REGION_BY_ATTRIBUTE = ojn(
    OUTPUTS_DIR,
    "atr_reg_map_{time_span}_{disagr_level}.parquet"
)
MAPPING_DATA_BY_ATTRIBUTE_LOG = ojn(
    LOGS_DIR,
    "lg_attr_cntreg_map_{time_span}_{disagr_level}.log"
)

# ===========
## Visualization files/figures ##
# ===========

# NMR Map figures, 2012-2017
# general output for all NMR and MEI figures
NMR_AND_MEI_MAPS = ojn(
    VIS_DIR,
    "map1_{geo_region}_{time_span}_{measure_mapped}_{migration_system}.png"
)
NMR_AND_MEI_MAPS_LOG = ojn(
    LOGS_DIR,
    "plt_map_{geo_region}_{time_span}_{measure_mapped}_{migration_system}.log"
)

########## BY AUTHOR ATTRIBUTES ##########
# NOTE disaggregated by author attributes
NMR_AND_MEI_MAPS_DISAGGREGATED_ATTRIBUTE = ojn(
    VIS_DIR,
    "m_attr_{geo_region}_{time_span}_{measure_mapped}_{migration_system}_{disagr_level}_{disagr_catpair}.png"
)
NMR_AND_MEI_MAPS_DISAGGREGATED_ATTRIBUTE_LOG = ojn(
    LOGS_DIR,
    "plt_attr_mp_{geo_region}_{time_span}_{measure_mapped}_{migration_system}_{disagr_level}_{disagr_catpair}.log"
)

# ============================
#### multiple affiliations visualization + descriptive tables ####
# ============================

PAPER_LEVEL_MULT_AUTHOR = ojn(VIS_DIR, 'publication_level_mult_affiliations.png')

AUTHOR_LEVEL_MULT_AUTHOR = ojn(VIS_DIR, 'author_level_mult_affiliations.png')

# descriptive tables for authors' career level analysis
MULT_AFF_TYPOLOGY = ojn(TABS_DIR, 'descriptive_table_multiple_affiliation_typologies.tex')

MULT_AFF_TYP_DOMINANT = ojn(TABS_DIR, 'descriptive_table_multiple_affiliation_dominant_type_per_author.tex')

# Toy authorship and filling examples
TOY_AUTHOR_EXAMPLE = ojn(TABS_DIR, 'descriptive_table_example_filled.tex')

TOY_AUTHOR_EXAMPLE_MODE = ojn(TABS_DIR, 'descriptive_table_example_filled_mode_method.tex')

REAL_AUTHOR_EXAMPLE = ojn(TABS_DIR, 'descriptive_table_example_real_author.tex')

REAL_AUTHOR_EXAMPLE_MODE = ojn(TABS_DIR, 'descriptive_table_example_real_author_mode_method.tex')

OVERALL_MOBILE_NON_MOBILE = ojn(TABS_DIR, 'descriptive_table_overall_mobile_nonmobile.tex')

NMR_TYPOLOGY_PER_REGION = ojn(TABS_DIR, 'descriptive_table_NMR_typologies.tex')
NMR_DOMINANT_TYPOLOGY_PER_REGION_REPL_DATA = ojn(OUTPUTS_DIR, 'NMR_dominant_typology_per_region.csv')

# NMR figure for subnational regions of a country
NMR_REGION_LINE_PLOT_ONE_COUNTRY = ojn(
    VIS_DIR,
    "regions_NMR_IN_INT_{code2use}_{size2wrap1}_{size2wrap2}.png"
)
NMR_REGION_LINE_PLOT_ONE_COUNTRY_LOG = ojn(
    LOGS_DIR,
    "plt_reg_NMR_IN_INT_{code2use}_{size2wrap1}_{size2wrap2}.log"
)

# CMI figure for subnational regions of a country
CMI_REGION_LINE_PLOT_ONE_COUNTRY = ojn(
    VIS_DIR,
    "regions_CMI_IN_INT_{code2use}_{size2wrap1}_{size2wrap2}.png"
)
CMI_REGION_LINE_PLOT_ONE_COUNTRY_LOG = ojn(
    LOGS_DIR,
    "plt_reg_CMI_IN_INT_{code2use}_{size2wrap1}_{size2wrap2}.log"
)

CMI_INTERNAL_LINE_PLOT_ONE_COUNTRY = ojn(
    VIS_DIR,
    "country_CMI_IN_{code2use}.png"
)
CMI_INTERNAL_LINE_PLOT_ONE_COUNTRY_LOG = ojn(
    LOGS_DIR,
    "plt_cnt_CMI_IN_{code2use}.log"
)

CMI_INTERNAL_LINE_PLOT_MULT_COUNTRIES = ojn(
    VIS_DIR,
    "top_{ncountry}_countries_CMI_IN.png"
)
CMI_INTERNAL_LINE_PLOT_MULT_COUNTRIES_LOG = ojn(
    LOGS_DIR,
    "plt_{ncountry}_cnt_CMI_IN.log"
)

MIGR_IMPORTANCE_IN_INT_LINE_PLOT_MULT_COUNTRIES = ojn(
    VIS_DIR,
    "top_{ncountry}_countries_MIGR_RELATIVE_IMPORTANCE.png"
)
MIGR_IMPORTANCE_IN_INT_LINE_PLOT_MULT_COUNTRIES_LOG = ojn(
    LOGS_DIR,
    "plt_{ncountry}_MIGR_REL_IMP.log"
)


# aggregated NMR, i.e., ANMR, for 500+ pop countries
ANMR_REGION_LINE_PLOT_ONE_COUNTRY = ojn(VIS_DIR, 'selected_countries_ANMR_regions_international_internal_plus5000pop_countries.pdf')
