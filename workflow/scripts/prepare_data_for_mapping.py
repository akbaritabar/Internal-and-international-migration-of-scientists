## File name to use in search: prepare_data_for_mapping.py ##

import pandas as pd
import os
# for mapping
import geopandas as gp
#### Results log and progress report ####
from tolog import lg

# to see more pandas columns & not to use scientific notation
pd.set_option('max_colwidth',100)
pd.set_option('display.float_format', '{:.2f}'.format)


# ============================
#### For command line arguments ####
# ============================
import argparse
parser = argparse.ArgumentParser()

# System arguments
# use ", nargs='+'" if more than one input is given, below have to choose args.input[] and list element number to use
parser.add_argument("-i", "--input", help = "Input file to use",
                    type = str, required = True, nargs='+')
parser.add_argument("-tme", "--TIME_SPAN", help = "Parameters to use in plotting", type = str, required = True)
parser.add_argument("-o", "--output", help = "Output data path",
                    type = str, required = True, nargs='+')

args = parser.parse_args()

#lg(f"Log file is here: {os.path.join(outputs_dir, log_file_name)}")
lg(f"These items are in the environment: {dir()}")

# ============================
#### Preparing data ####
# ============================

# ============================
#### Read GeoNames data (From GRID 2021) ####
# ============================

# this data has equivalence between GeoNames admin1 codes, NUTS1-3 codes, since some shape files for map come with NUTS codes
grid_geonames = pd.read_csv(args.input[0],
    usecols=['geonames_city_id', 'nuts_level1_code', 'geonames_admin1_code', 'geonames_admin1_ascii_name'],
    dtype=str)

# limit to only regions with GeoNames Admin1 codes
grid_geonames = grid_geonames[grid_geonames.geonames_admin1_code.notnull()]

# convert GeoNames colum to float
grid_geonames['geonames_city_id'] = grid_geonames['geonames_city_id'].astype(float)

# read GeoNames data dump to use a "bridging table" to find provinces with different IDs (e.g., in Spain, France, UK, ...)
# from this URL, keep only needed columns: https://download.geonames.org/export/dump/allCountries.zip
# geo_download = pd.read_csv('https://download.geonames.org/export/dump/allCountries.zip', delimiter='\t', dtype='str', names=['geonameid','name','asciiname','alternatenames','latitude','longitude','feature_class','feature_code','country_code','cc2','admin1_code','admin2_code','admin3_code','admin4_code','population','elevation','dem','timezone','modification_date'])

# exclude those locatins with "admin1 code" equal to "00" which are "unkown" in GeoNames lingua
# geo_download = geo_download[(geo_download['admin1_code'] != '00')][['geonameid', 'country_code', 'admin1_code']].dropna().reset_index(drop=True)

# write selected columns/rows to csv
# geo_download.to_csv(os.path.join(mcj_dir, 'outputs', "20230520_Bridge_table_from_GeoNames.csv"), index = False)

# read from csv
geo_download = pd.read_parquet(args.input[1])
# add a column to use for join
geo_download['region_for_join'] = geo_download['country_code'] + geo_download['admin1_code']

# join grid data with GeoNames bridge table
geo_download = geo_download.merge(grid_geonames, left_on='geonameid', right_on='geonames_city_id', how='left')

# convert GeoNames colum to float
geo_download['geonameid'] = geo_download['geonameid'].astype(float)

# ============================
#### Read Scopus data with Maciej's thresholds ####
# ============================

# a generic year range to use
if args.TIME_SPAN == '20122017':
    MIN_YEAR = 2012 - 1
    MAX_YEAR = 2017 + 1
elif args.TIME_SPAN == '19982017':
    MIN_YEAR = 1998 - 1
    MAX_YEAR = 2017 + 1
elif args.TIME_SPAN == '20002005':
    MIN_YEAR = 2000 - 1
    MAX_YEAR = 2005 + 1
elif args.TIME_SPAN == '20062011':
    MIN_YEAR = 2006 - 1
    MAX_YEAR = 2011 + 1


mcj_data = pd.read_csv(args.input[2])

# keep only needed columns for the map
mcj_data = mcj_data[['region', 'year', 'country_2letter_code',
       'geonames_admin1_code', 'geonames_admin1_ascii_name', 'continent_code',
       'continent_name', 'country_name', 'iso_a3', 'in_y_flow_IN', 'out_y_flow_IN', 'y_pop_IN', 'in_y_flow_INT', 'out_y_flow_INT', 'y_pop_INT']]

lg('#'*50)
lg(f"Reading data from {args.input[2]}")
lg('#'*50)
lg('Data is imported!')

# limit to 2012-2017 data for most recent trends
mcj_data = mcj_data.loc[(mcj_data.year > MIN_YEAR) & (mcj_data.year < MAX_YEAR)]

# NMR at sub-national region level
# International
nmr_INT_TIME_SPAN_region = (
    mcj_data
    .groupby(['iso_a3', 'region'])
    # add grouping columns that will be used in join
    [['iso_a3', 'region', 'in_y_flow_INT', 'out_y_flow_INT', 'y_pop_INT']]
    .apply(lambda x: (1000 * (x.in_y_flow_INT.sum() - x.out_y_flow_INT.sum())) / x.y_pop_INT.sum())
    .reset_index()
    .rename(columns={0:'nmr_INT_sum_region'})
)

# Internal
nmr_IN_TIME_SPAN_region = (
    mcj_data
    .groupby(['iso_a3', 'region'])
    # add grouping columns that will be used in join
    [['iso_a3', 'region', 'in_y_flow_IN', 'out_y_flow_IN', 'y_pop_IN']]
    .apply(lambda x: (1000 * (x.in_y_flow_IN.sum() - x.out_y_flow_IN.sum())) / x.y_pop_IN.sum())
    .reset_index()
    .rename(columns={0:'nmr_IN_sum_region'})
)

# Both: International and Internal
nmr_INT_IN_TIME_SPAN_region = (
    mcj_data
    .groupby(['iso_a3', 'region'])
    # add grouping columns that will be used in join
    [['iso_a3', 'region', 'in_y_flow_INT', 'out_y_flow_INT', 'in_y_flow_IN', 'out_y_flow_IN', 'y_pop_INT']]
    .apply(lambda x: (1000 * ((x.in_y_flow_INT.sum() + x.in_y_flow_IN.sum()) - (x.out_y_flow_INT.sum() + x.out_y_flow_IN.sum())) / x.y_pop_INT.sum()))
    .reset_index()
    .rename(columns={0:'nmr_INT_IN_sum_region'})
)

# MEI at sub-national region level
# the difference with NMR is that denominator is moving population, instead of all scholars
# International
mei_INT_TIME_SPAN_region = (
    mcj_data
    .groupby(['iso_a3', 'region'])
    # add grouping columns that will be used in join
    [['iso_a3', 'region', 'in_y_flow_INT', 'out_y_flow_INT', 'y_pop_INT']]
    .apply(lambda x: (100 * abs(x.in_y_flow_INT.sum() - x.out_y_flow_INT.sum())) / (x.in_y_flow_INT.sum() + x.out_y_flow_INT.sum()))
    .reset_index()
    .rename(columns={0:'mei_INT_sum_region'})
)

# Internal
mei_IN_TIME_SPAN_region = (
    mcj_data
    .groupby(['iso_a3', 'region'])
    # add grouping columns that will be used in join
    [['iso_a3', 'region', 'in_y_flow_IN', 'out_y_flow_IN', 'y_pop_IN']]
    .apply(lambda x: (100 * abs(x.in_y_flow_IN.sum() - x.out_y_flow_IN.sum())) / (x.in_y_flow_IN.sum() + x.out_y_flow_IN.sum()))
    .reset_index()
    .rename(columns={0:'mei_IN_sum_region'})
)

# Both: International and Internal
mei_INT_IN_TIME_SPAN_region = (
    mcj_data
    .groupby(['iso_a3', 'region'])
    # add grouping columns that will be used in join
    [['iso_a3', 'region', 'in_y_flow_INT', 'out_y_flow_INT', 'in_y_flow_IN', 'out_y_flow_IN']]
    .apply(lambda x: (100 * abs((x.in_y_flow_INT.sum() + x.in_y_flow_IN.sum()) - (x.out_y_flow_INT.sum() + x.out_y_flow_IN.sum()))) / (x.in_y_flow_INT.sum() + x.in_y_flow_IN.sum() + x.out_y_flow_INT.sum() + x.out_y_flow_IN.sum()))
    .reset_index()
    .rename(columns={0:'mei_INT_IN_sum_region'})
)

## add RELATIVE INTERNAL MIGRATION IMPORTANCE for a region in a year
# inflow importance
data_IN_inflow_region = (
    mcj_data
    .groupby(['iso_a3', 'region'])
    # add grouping columns that will be used in join
    [['iso_a3', 'region', 'in_y_flow_INT', 'in_y_flow_IN']]
    .apply(lambda x: (100 * x.in_y_flow_IN.sum() / (x.in_y_flow_IN.sum() + x.in_y_flow_INT.sum())))
    .reset_index()
    .rename(columns={0:'IMP_IN_inflow'})
)

lg('Importance measures calculated, few rows!')
lg('#'*50)
lg(data_IN_inflow_region[(data_IN_inflow_region.iso_a3 == 'USA')].head(n=50))
lg('#'*50)
lg(data_IN_inflow_region.loc[0])

# outflow importance
data_IN_outflow_region = (
    mcj_data
    .groupby(['iso_a3', 'region'])
    # add grouping columns that will be used in join
    [['iso_a3', 'region', 'out_y_flow_IN', 'out_y_flow_INT']]
    .apply(lambda x: (100 * x.out_y_flow_IN.sum() / (x.out_y_flow_IN.sum() + x.out_y_flow_INT.sum())))
    .reset_index()
    .rename(columns={0:'IMP_IN_outflow'})
)

lg('Importance measures calculated, few rows!')
lg('#'*50)
lg(data_IN_outflow_region[(data_IN_outflow_region.iso_a3 == 'USA')].head(n=50))
lg('#'*50)
lg(data_IN_outflow_region.loc[0])


# join the results to our data
mcj_data_joined = (mcj_data
            .merge(nmr_INT_TIME_SPAN_region, on=['iso_a3', 'region'], how='left')
            .merge(nmr_IN_TIME_SPAN_region, on=['iso_a3', 'region'], how='left')
            .merge(nmr_INT_IN_TIME_SPAN_region, on=['iso_a3', 'region'], how='left')
            .merge(mei_INT_TIME_SPAN_region, on=['iso_a3', 'region'], how='left')
            .merge(mei_IN_TIME_SPAN_region, on=['iso_a3', 'region'], how='left')
            .merge(mei_INT_IN_TIME_SPAN_region, on=['iso_a3', 'region'], how='left')
            .merge(data_IN_inflow_region, on=['iso_a3', 'region'], how='left')
            .merge(data_IN_outflow_region, on=['iso_a3', 'region'], how='left')
)

lg('Data is joined now!')
lg('#'*50)
lg(f"example rows: {mcj_data_joined.tail()}")

# ============================
#### Map based on measures (geopandas) ####
# ============================

# read geojson file of all world states/provinces to map
# data from natural earth GitHub here: https://github.com/nvkelso/natural-earth-vector/blob/master/geojson/ne_10m_admin_1_states_provinces.geojson
world_states = gp.read_file(args.input[3])

# or instead for online file: 
# url2read = "https://github.com/nvkelso/natural-earth-vector/raw/ca96624a56bd078437bca8184e78163e5039ad19/geojson/ne_10m_admin_1_states_provinces.geojson"
# world_states = gp.read_file(url2read))

# limit to only needed columns
world_states_filtered = world_states[['iso_a2', 'name', 'type_en', 'gu_a3', 'gn_id', 'gn_name', 'gn_a1_code', 'name_en', 'geometry']]

# exclude antarctica & changing map projection (if needed)
# changing to robinson (https://geocompr.robinlovelace.net/reproj-geo-data.html)
world_states_filtered = world_states_filtered[(world_states_filtered.gu_a3 != 'ATA')].to_crs("ESRI:54030")

# join with GeoNames bridge table
world_states_filtered = world_states_filtered.merge(geo_download, left_on='gn_id', right_on='geonameid', how='left')

# THIS IS DEPRECATED world countries to map their borders around sub-national regions
# world = gp.read_file(gp.datasets.get_path('naturalearth_lowres'))
# now Geopandas suggests reading the downloaded shp file
# downloaded from: "https://github.com/JetBrains/lets-plot-kotlin/tree/master/docs/examples/shp/naturalearth_lowres"
world = gp.read_file(args.input[4])

# replace some missing iso 3 letter codes
world.loc[world.name =='France', 'iso_a3'] = 'FRA'
world.loc[world.name =='N. Cyprus', 'iso_a3'] = 'CYP'
world.loc[world.name =='Norway', 'iso_a3'] = 'NOR'
world.loc[world.name =='Somaliland', 'iso_a3'] = 'SOM'
world.loc[world.name =='Kosovo', 'iso_a3'] = 'KOS'
# exclude Antarctica
world = world[(world.name != "Antarctica") & (world.name != "Fr. S. Antarctic Lands")]# changing map projection (if needed)
# changing to robinson (https://geocompr.robinlovelace.net/reproj-geo-data.html)
world = world.to_crs("ESRI:54030")

# ============================
#### Manuscript Figure 1 regions map with net migration rates INT and IN ####
# ============================

# sub-national region level and choose latest 2012-2017 years to map
mcj_data_dedup_region = mcj_data_joined.drop_duplicates(subset=['iso_a3', 'region']).reset_index()[['region', 'iso_a3', 'continent_code', 'continent_name','nmr_INT_sum_region',
       'nmr_IN_sum_region', 'nmr_INT_IN_sum_region', 'mei_INT_sum_region',
       'mei_IN_sum_region', 'mei_INT_IN_sum_region', 'IMP_IN_inflow', 'IMP_IN_outflow']]

# add a column "region_for_join" to world_states data that is GeoNamesAdmin1 code OR NUTS1 code and use it to join so that no country is missed
mcj_data_dedup_region['region_for_join'] = mcj_data_dedup_region['region']
# remove dot "." in GeoNamesAdmin1 code
mcj_data_dedup_region['region_for_join'] = mcj_data_dedup_region['region_for_join'].str.replace('.', '', regex=False)

# join region level data with the GeoNames province level geometry data and choose latest six years to map
world_states_joined = (world_states_filtered
                      .merge(mcj_data_dedup_region, left_on='region_for_join', right_on='region_for_join', how='left')
            )

# ============================
#### Export prepared data to be used in mapping ####
# ============================

# export to csv
(world
    .reset_index(drop=True)
    .to_parquet(args.output[0])
)

# export to csv
(world_states_joined
    .reset_index(drop=True)
    .to_parquet(args.output[1])
)

lg('#'*50)
lg("Files for mapping exported!")
