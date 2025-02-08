## File name to use in search: prepare_migration_data_disaggregate_by_author_attributes.py ##

#### Results log and progress report ####
from tolog import lg
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
                    type = str, required = True)

args = parser.parse_args()

#lg(f"Log file is here: {os.path.join(outputs_dir, log_file_name)}")
lg(f"These items are in the environment: {dir()}")

# ============================
#### Preparing data ####
# ============================

import pandas as pd
import numpy as np
import os

# to convert country code to continent code/name
import pycountry_convert as pccon
# for mapping
import geopandas as gp


# to see more pandas columns & not to use scientific notation
pd.set_option('max_colwidth',100)
pd.set_option('display.float_format', '{:.2f}'.format)

# ============================
#### Functions ####
# ============================

def iso2_2_name(iso2_2use): 
    try: 
        country_name = pccon.country_alpha2_to_country_name(iso2_2use)
    except:
        # Timor-Leste has problems
        if iso2_2use == 'TP':
            try:
                country_name = pccon.country_alpha2_to_country_name('TL')
            except:
                country_name = "NO_COUNTRY"
        # Kosovo has problems
        if iso2_2use == 'XK':
            try:
                country_name = 'Kosovo'
            except:
                country_name = "NO_COUNTRY"
        else:
            country_name = "NO_COUNTRY"
        
    return country_name

def iso2_2_continent(iso2_2use): 
    try: 
        continent = pccon.country_alpha2_to_continent_code(iso2_2use)
    except:
        # Timor-Leste has problems
        if iso2_2use == 'TL':
            try:
                continent = pccon.country_alpha2_to_continent_code('TP')
            except:
                continent = "NO_CONTINENT"
        else:
            continent = "NO_CONTINENT"
        
    return continent

def continent_code_2_name(continent_2use): 
    try: 
        continent = pccon.convert_continent_code_to_continent_name(continent_2use)
    except:
        continent = "NO_CONTINENT"
        
    return continent

def name_2_iso3(name_2use): 
    try: 
        iso_a3 = pccon.country_name_to_country_alpha3(name_2use)
    except:
        # Kosovo has problems
        if name_2use == 'Kosovo':
            iso_a3 = "KOS"
        elif name_2use == 'N. Cyprus':
            iso_a3 = "CYP"
        else:
            iso_a3 = "NO_COUNTRY"
        
    return iso_a3


# ============================
#### Read ROR region names added to Scopus ####
# ============================

# geonames region names to use on plots
region_name_codes = (pd.read_csv(args.input[0])
                    [['geonames_admin1_code', 'geonames_admin1_ascii_name']]
)


# ============================
#### Mode-based approach: Analysing data of mode-country/region ####
# ============================

region_y_pop = pd.read_parquet(args.input[1])

international_province = pd.read_parquet(args.input[2])

internal_province = pd.read_parquet(args.input[3])

# ============================
#### Disaggregate migration measures by discipline, academic age, or productivity  ####
# ============================

# depending on the disaggregation measure used, take that variable from authors' attributes table and use it below in group-by calls to disaggregate by it 
if args.DISAGGREGATION == 'PRODUCTIVITY':
    lg(f"Disaggregating: {args.DISAGGREGATION}")
    DISAGGREGATION_COLUMN = 'prod_cat'
elif args.DISAGGREGATION == 'AGE':
    lg(f"Disaggregating: {args.DISAGGREGATION}")
    DISAGGREGATION_COLUMN = 'academic_age_cat'
elif args.DISAGGREGATION == 'DISCIPLINE':
    lg(f"Disaggregating: {args.DISAGGREGATION}")
    DISAGGREGATION_COLUMN = 'fieldOfScience'


# ============================
#### REGION INTERNATIONAL ####
# ============================

international_province['out_y_flow'] = international_province.groupby(['move_year', 'from', DISAGGREGATION_COLUMN])['author_id'].transform('nunique')
international_province['in_y_flow'] = international_province.groupby(['move_year', 'to', DISAGGREGATION_COLUMN])['author_id'].transform('nunique')

# drop duplicates & join with yearly population data
international_province_out = international_province[['from', 'move_year', DISAGGREGATION_COLUMN, 'out_y_flow']].drop_duplicates()
international_province_in = international_province[['to', 'move_year', DISAGGREGATION_COLUMN, 'in_y_flow']].drop_duplicates()
international_province_nmr = international_province_in.merge(international_province_out, how='outer', left_on=['to', 'move_year', DISAGGREGATION_COLUMN], right_on=['from', 'move_year', DISAGGREGATION_COLUMN])

# fill NAs with 0 for calculations
international_province_nmr[['in_y_flow', 'out_y_flow']] = international_province_nmr[['in_y_flow', 'out_y_flow']].fillna(0)

# add net flow
international_province_nmr['net_y_flow'] = international_province_nmr['in_y_flow'] - international_province_nmr['out_y_flow']

# join with yearly population of scholars
international_province_nmr_to_join = region_y_pop.merge(international_province_nmr, right_on=['move_year', 'to', DISAGGREGATION_COLUMN], left_on=['pubyear', 'geonames_admin1_code', DISAGGREGATION_COLUMN], how='left')
# calculate yearly NMR (yearly net_flow / yearly pop) * 1000
international_province_nmr_to_join['nmr'] = (international_province_nmr_to_join['net_y_flow'] / international_province_nmr_to_join['y_pop']) * 1000

# MEI = 100 * sum(abs(inflow - outflow)) / sum(inflow + outflow)
international_province_nmr_to_join['abs_inout'] = abs(international_province_nmr_to_join['in_y_flow'] - international_province_nmr_to_join['out_y_flow'])
international_province_nmr_to_join['sum_inout'] = international_province_nmr_to_join['in_y_flow'] + international_province_nmr_to_join['out_y_flow']

# fill out region and year NA values with their population (e.g., a region in a year has scholars, but no one moves)
# region names
international_province_nmr_to_join['to'] = (
    international_province_nmr_to_join['to']
    .fillna(international_province_nmr_to_join['from'])
    .fillna(international_province_nmr_to_join['geonames_admin1_code'])
)
# year
international_province_nmr_to_join['move_year'] = (
    international_province_nmr_to_join['move_year']
    .fillna(international_province_nmr_to_join['pubyear'])
)


# add N of population of scholars (i.e., exposure) based on N of incoming/outgoing scholars
# I was already calculating it based on each year and N of unique author_id, rename
international_province_nmr_to_join['pop_y_in_and_out'] = international_province_nmr_to_join['sum_inout']

# ============================
#### REGION INTERNAL ####
# ============================

internal_province['out_y_flow'] = internal_province.groupby(['move_year', 'from', DISAGGREGATION_COLUMN])['author_id'].transform('nunique')
internal_province['in_y_flow'] = internal_province.groupby(['move_year', 'to', DISAGGREGATION_COLUMN])['author_id'].transform('nunique')

# drop duplicates & join with yearly population data
internal_province_out = internal_province[['from', 'move_year', DISAGGREGATION_COLUMN, 'out_y_flow']].drop_duplicates()
internal_province_in = internal_province[['to', 'move_year', DISAGGREGATION_COLUMN, 'in_y_flow']].drop_duplicates()
internal_province_nmr = internal_province_in.merge(internal_province_out, how='outer', left_on=['to', 'move_year', DISAGGREGATION_COLUMN], right_on=['from', 'move_year', DISAGGREGATION_COLUMN])

# fill NAs with 0 for calculations
internal_province_nmr[['in_y_flow', 'out_y_flow']] = internal_province_nmr[['in_y_flow', 'out_y_flow']].fillna(0)

# add net flow
internal_province_nmr['net_y_flow'] = internal_province_nmr['in_y_flow'] - internal_province_nmr['out_y_flow']

# join with yearly population of scholars
internal_province_nmr_to_join = region_y_pop.merge(internal_province_nmr, right_on=['move_year', 'to', DISAGGREGATION_COLUMN], left_on=['pubyear', 'geonames_admin1_code', DISAGGREGATION_COLUMN], how='left')
# calculate yearly NMR (yearly net_flow / yearly pop) * 1000
internal_province_nmr_to_join['nmr'] = (internal_province_nmr_to_join['net_y_flow'] / internal_province_nmr_to_join['y_pop']) * 1000

# MEI = 100 * sum(abs(inflow - outflow)) / sum(inflow + outflow)
internal_province_nmr_to_join['abs_inout'] = abs(internal_province_nmr_to_join['in_y_flow'] - internal_province_nmr_to_join['out_y_flow'])
internal_province_nmr_to_join['sum_inout'] = internal_province_nmr_to_join['in_y_flow'] + internal_province_nmr_to_join['out_y_flow']

# fill out region and year NA values with their population (e.g., a region in a year has scholars, but no one moves)
# region names
internal_province_nmr_to_join['to'] = (
    internal_province_nmr_to_join['to']
    .fillna(internal_province_nmr_to_join['from'])
    .fillna(internal_province_nmr_to_join['geonames_admin1_code'])
)
# year
internal_province_nmr_to_join['move_year'] = (
    internal_province_nmr_to_join['move_year']
    .fillna(internal_province_nmr_to_join['pubyear'])
)


# add N of population of scholars (i.e., exposure) based on N of incoming/outgoing scholars
# I was already calculating it based on each year and N of unique author_id, rename
internal_province_nmr_to_join['pop_y_in_and_out'] = internal_province_nmr_to_join['sum_inout']


lg('#'*50)
lg(f"Reading data and reshaping it finished!")


# ============================
#### Exporting CSV files for Maciej to use in stat models ####
# ============================

# To allow him to do models on the mutual effect between internal and international migration
# I will export 1 set of data:
# 1) before applying threshold so that he has all the data


# 1) data before applying threshold, join internal/international, choose needed columns, export
without_threshold = (international_province_nmr_to_join
                     [['to', 'move_year', DISAGGREGATION_COLUMN, 'in_y_flow', 'out_y_flow', 'net_y_flow', 'y_pop', 'nmr','abs_inout', 'sum_inout', 'pop_y_in_and_out']]
                     .rename(columns={
                            'to':'region',
                            'move_year':'year',
                            'y_pop':'y_pop_INT',
                            'in_y_flow':'in_y_flow_INT',
                            'out_y_flow':'out_y_flow_INT',
                            'net_y_flow':'net_y_flow_INT',
                            'nmr':'nmr_INT',
                            'abs_inout':'abs_inout_INT', 
                            'sum_inout':'sum_inout_INT',
                            'pop_y_in_and_out':'pop_y_in_and_out_INT'
                            })
)

# internal
without_threshold = (without_threshold
                     .merge(
                        internal_province_nmr_to_join
                        [['to', 'move_year', DISAGGREGATION_COLUMN, 'in_y_flow', 'out_y_flow', 'net_y_flow', 'y_pop', 'nmr','abs_inout', 'sum_inout', 'pop_y_in_and_out']]
                        .rename(columns={
                            'to':'region',
                            'move_year':'year',
                            'y_pop':'y_pop_IN',
                            'in_y_flow':'in_y_flow_IN',
                            'out_y_flow':'out_y_flow_IN',
                            'net_y_flow':'net_y_flow_IN',
                            'nmr':'nmr_IN',
                            'abs_inout':'abs_inout_IN', 
                            'sum_inout':'sum_inout_IN',
                            'pop_y_in_and_out':'pop_y_in_and_out_IN'
                            }),
                            how='outer',
                            on=['region', 'year', DISAGGREGATION_COLUMN]
                     )
                    .assign(country_2letter_code= lambda x: x.region.str.split('.').str[0]
                    )
                    .merge(region_name_codes, how='left', left_on='region', right_on='geonames_admin1_code')
)

##### ADD NEEDED COLUMNS FOR MACIEJ #####
# to add:
# a) continent_name           
# b) country_2letter_code     
# c) country_name             
# d) iso_a3  
without_threshold['continent_code'] = without_threshold['country_2letter_code'].map(lambda a: iso2_2_continent(a))
without_threshold['continent_name'] = without_threshold['continent_code'].map(lambda a: continent_code_2_name(a))
without_threshold['country_name'] = without_threshold['country_2letter_code'].map(lambda a: iso2_2_name(a))
without_threshold['iso_a3'] = without_threshold['country_name'].map(lambda a: name_2_iso3(a))

# fill numeric columns with "0" instead of NaN for Maciej to use
# select numeric columns
numeric_columns = without_threshold.select_dtypes(include=['number']).columns
# fill 0 to all NaN 
without_threshold[numeric_columns] = without_threshold[numeric_columns].fillna(0)

# export to csv
(without_threshold
    .reset_index(drop=True)
    .to_csv(args.output, index_label='row_number')
)

lg('#'*50)
lg('Prepared data with NMR and other measures is exported!')
lg(f"Example rows: {without_threshold.tail()}")
