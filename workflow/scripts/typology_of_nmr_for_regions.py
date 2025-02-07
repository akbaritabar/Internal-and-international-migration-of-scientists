## File name to use in search: typology_of_nmr_for_regions.py ##

# Python script that use DuckDB and SQL script for data processing/reshaping

# for data handling
import duckdb
import pandas as pd
import tabulate
#### Results log and progress report ####
from tolog import lg

# to see more pandas columns & not to use scientific notation
pd.set_option('max_colwidth',100)
pd.set_option('display.float_format', '{:.2f}'.format)

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
#### Typology of regions/countries by NMR to net receiver, sender, etc ####
# ============================

# first add a typology of net receiver, net sender, int_receiver and in sender, in_receiver and int sender using IN and INT NMR's signs (positive, negative)

# - [x] for the typology of regions, group by region, nmr_typology and count unique years, a region having more than 5 (or 10 if too many) being net sender or receiver could be listed and shared with country and continent name

data = pd.read_csv(args.input[0])

lg(f"Data read from '{args.input[0]}'")
lg(f"A few rows: '{data.tail()}'")

lg(data.columns)
# ['row_number', 'region', 'year', 'in_y_flow_INT', 'out_y_flow_INT',
#        'net_y_flow_INT', 'y_pop_INT', 'nmr_INT', 'abs_inout_INT',
#        'sum_inout_INT', 'pop_y_in_and_out_INT', 'in_y_flow_IN',
#        'out_y_flow_IN', 'net_y_flow_IN', 'y_pop_IN', 'nmr_IN', 'abs_inout_IN',
#        'sum_inout_IN', 'pop_y_in_and_out_IN', 'country_2letter_code',
#        'geonames_admin1_code', 'geonames_admin1_ascii_name', 'continent_code',
#        'continent_name', 'country_name', 'iso_a3']

data['nmr_typology'] = 'Mixed'
# net receivers, both NMR positive
data.loc[(data.nmr_INT > 0) & (data.nmr_IN > 0), 'nmr_typology'] = 'Net receiver'
# net senders, both NMR negative
data.loc[(data.nmr_INT < 0) & (data.nmr_IN < 0), 'nmr_typology'] = 'Net sender'
# INT net receivers (positive), IN net sender (negative)
data.loc[(data.nmr_INT > 0) & (data.nmr_IN < 0), 'nmr_typology'] = 'INT rec. IN sen.'
# IN net receivers (positive), INT net sender (negative)
data.loc[(data.nmr_INT < 0) & (data.nmr_IN > 0), 'nmr_typology'] = 'IN rec. INT sen.'
# both nmrs are 0 (balanced)
data.loc[(data.nmr_INT == 0) & (data.nmr_IN == 0), 'nmr_typology'] = 'Both balanced'

# add a count of OBSERVATION YEARS per region to find regions with MIN OR MAX N YEARS
data['n_years'] = data.groupby(['region'])['year'].transform('nunique')
# N of unique years a region was in that typology i.e., a net sender for 5 years
data['n_years_in_typology'] = data.groupby(['region', 'nmr_typology'])['year'].transform('nunique')
# add average population over years
data['avg_pop'] = data.groupby(['region'])['y_pop_INT'].transform('mean')


# a region's most dominant typology
region_dominant_typology = data.sort_values('n_years_in_typology', na_position="first").groupby(['region']).tail(1)[['continent_name', 'country_name', 'region', 'geonames_admin1_ascii_name', 'nmr_typology', 'n_years_in_typology', 'n_years', 'y_pop_INT']]


# For regions with minimum N years to use, group by and count
MIN_N_Y = 5
MIN_N_Y_TYPOLOGY = 10
# NOT_INTERESTING_TYPES = ['Both balanced', 'Mixed', 'INT rec. IN sen.']
MIN_Y_POP = 200

summarized_dominant_typology = (region_dominant_typology
    [
     (region_dominant_typology['n_years'] >= MIN_N_Y) &
     (region_dominant_typology['n_years_in_typology'] >= MIN_N_Y_TYPOLOGY) &
    #  (~region_dominant_typology['nmr_typology'].isin(NOT_INTERESTING_TYPES)) &
     (region_dominant_typology['y_pop_INT'] >= MIN_Y_POP) 
    ]
    .sort_values(['nmr_typology', 'continent_name', 'country_name'])
    .groupby(['nmr_typology', 'continent_name'])
    [['nmr_typology', 'continent_name', 'country_name', 'geonames_admin1_ascii_name',  'n_years_in_typology', 'n_years', 'y_pop_INT']]
    .head(n=3)
)

headers2use = ['Typology', 'Continent', 'Country', 'Region name', 'N y. in typ.', 'N obs. y.', 'Population']

# convert to markdown (or latex) format
f = open(args.output[0], 'w')
f.write(tabulate.tabulate(summarized_dominant_typology,
                          showindex=False,
                          headers=headers2use,
                          tablefmt='latex',
                          floatfmt=',.0f',
                          intfmt=","))
f.close()

lg(f"Table of results exported in: '{args.output[0]}'")

(region_dominant_typology
    [['nmr_typology', 'continent_name', 'country_name', 'geonames_admin1_ascii_name',  'n_years_in_typology', 'n_years', 'y_pop_INT']]
    .reset_index(drop=True)
    .to_csv(args.output[1], index_label='row_number')
)

lg(f"Replication data of dominant typology per region exported in: '{args.output[1]}'")
