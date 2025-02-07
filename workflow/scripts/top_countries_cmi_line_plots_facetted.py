## File name to use in search: subnational_regions_nmr_line_plots.py ##

# Python script that use DuckDB and SQL script for data processing/reshaping


import pandas as pd
# to visualize
import plotnine as gg
# for log (10^3 etc) labels
from mizani.labels import label_number
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
parser.add_argument("-i", "--input", help = "Input file to use", type = str, required = True, nargs='+')
parser.add_argument("-nc3", "--ncountry2use", help = "Number of countries with largest population of scholars to plot", type = int, required = False)
parser.add_argument("-o", "--output", help = "Output data path", type = str, required = False, nargs='+')

args = parser.parse_args()

lg(f"Arguments received from command line: \n {args}")


# ============================
#### Read data and visualize ####
# ============================

data = pd.read_csv(args.input[0])

lg(f"Data read from '{args.input[0]}'")
lg(f"A few rows for US.CA: '{data[data.region == 'US.CA'][['country_name', 'iso_a3', 'year', 'sum_inout_IN', 'y_pop_IN', 'sum_inout_INT', 'y_pop_INT']].sort_values(by='year')}'")

# limit years in data to only 1998-2017 (both inclusive)
data = data.loc[(data.year > 1997) & (data.year < 2018)]

# edit some country names
data.loc[data.iso_a3 == 'TWN', 'country_name'] = 'Taiwan'
data.loc[data.iso_a3 == 'IRN', 'country_name'] = 'Iran'
data.loc[data.iso_a3 == 'RUS', 'country_name'] = 'Russia'
data.loc[data.iso_a3 == 'KOR', 'country_name'] = 'South Korea'

lg("Country names corrected!")

# limit to largest countries in 2017 based on population
# N of largest countries equal to the number given in "ncountry2use"
list_countries_top_pop = (
    data
    [(data.year == 2017)]
    .groupby('iso_a3')
    ['y_pop_IN']
    .sum()
    .reset_index()
    .sort_values(by='y_pop_IN', ascending=False)
    .head(n=args.ncountry2use)
    .iso_a3
    .unique()
    )

lg(f"Selected countries to plot: '{list_countries_top_pop}'")


# add CMI (Crude Migration Intensity) for a region in a year
data_IN = (
    data
    [(data['iso_a3'].notnull()) & (data.iso_a3.isin(list_countries_top_pop))]
    .groupby(['country_name', 'iso_a3', 'year'])
    [['country_name', 'iso_a3', 'year', 'sum_inout_IN', 'y_pop_IN']]
    .apply(lambda x: (100 * x.sum_inout_IN.sum()) / x.y_pop_IN.sum())
    .reset_index()
    .rename(columns={0:'cmi_y_internal'})
)

lg(data_IN[data_IN.iso_a3 == 'USA'].head(n=50))
lg('#'*50)
lg(data_IN.loc[0])


# ============================
#### Internal line plots for CMI of chosen country ####
# ============================

# a function for plots of countries
def country_ploting(dt2use=None, internal_y2plot=None, ylabel2use=None, ncountry2use=0):

    fig2save = (
            gg.ggplot(dt2use) +
            gg.geom_line(gg.aes('year', internal_y2plot), color='blue') +
            gg.geom_smooth(gg.aes('year', internal_y2plot), linetype="dashed", color='#95d4e8') +
            gg.geom_hline(yintercept=0, linetype="dashed", color = "black") +
            gg.theme_classic() +
            gg.labs(title=f"Crude Migration Intensity of the {str(ncountry2use)} largest countries", x="Year", y=ylabel2use) +
            gg.facet_wrap('country_name') +
            gg.theme(panel_background=gg.element_rect(fill='gray', alpha=.1), legend_position="bottom",
                    axis_text_x=gg.element_text(hjust=1, size=10, angle=45),
                    axis_text_y=gg.element_text(hjust=1, size=10),
                    axis_title_x=gg.element_text(size=10),
                    axis_title_y=gg.element_text(size=10),
                    strip_text_x=gg.element_text(size=8),
                    figure_size=(8, 8))
    )

    gg.ggplot.save(fig2save, args.output[0], limitsize=False, dpi=500)


# plot using the provided command line arguments
country_ploting(dt2use=data_IN, internal_y2plot="cmi_y_internal", ylabel2use="Rate per 100 scholars", ncountry2use=args.ncountry2use)

lg(f"Figure exported in: '{args.output[0]}'")
