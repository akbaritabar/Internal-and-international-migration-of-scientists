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
parser.add_argument("-c2", "--code2use", help = "Country code to plot 2-letter ISO", type = str, required = False)
parser.add_argument("-s21", "--size2wrap1", help = "If figure facetting should be modified, provide nrow", type = str, required = False)
parser.add_argument("-s22", "--size2wrap2", help = "If figure facetting should be modified, provide ncol", type = str, required = False)
parser.add_argument("-o", "--output", help = "Output data path", type = str, required = False, nargs='+')

args = parser.parse_args()

lg(f"Arguments received from command line: \n {args}")


# ============================
#### Read data and visualize ####
# ============================

data = pd.read_csv(args.input[0])

lg(f"Data read from '{args.input[0]}'")
lg(f"A few rows: '{data.tail()}'")

# limit years in data to only 1998-2017 (both inclusive)
data = data.loc[(data.year > 1997) & (data.year < 2018)]

# ============================
#### Internal/International line plots for subnational regions per chosen country ####
# ============================

# a function for international/internal integrated plots of countries
def country_ploting(dt2use=None, code2use='US', size2wrap1=None, size2wrap2=None, internal_y2plot=None, international_y2plot=None, ylabel2use=None):
    # create a list of regions that I know are problematic outliers and should be excluded
    if code2use == 'US':
        region2exclude = []
    elif code2use == 'IT':
        region2exclude = ['IT.19']
    elif code2use == 'FR':
        region2exclude = ['FR.94']
    elif code2use == 'MX':
        region2exclude = ['MX.12']
    elif code2use == 'UA':
        region2exclude = ['UA.01', 'UA.09', 'UA.10', 'UA.11', 'UA.12', 'UA.13', 'UA.19', 'UA.20', 'UA.27']
    else:
        region2exclude = []

    lg(f"Excluding these regions: '{region2exclude}'")

    # add a "." to country code to use in filtering regions
    code2use = code2use + '.'
    lg(f"Using this code2use to filter: '{code2use}'")

    if size2wrap1 == 'None':
        lg('Facetting panels automatically.')
        fig2save = (
                gg.ggplot((dt2use
                        [(dt2use['region'].notnull()) & (dt2use['region'].str.contains(code2use))]
                        .query('`region` != @region2exclude'))) +
                gg.geom_line(gg.aes('year', international_y2plot), color='red') +
                gg.geom_smooth(gg.aes('year', international_y2plot), linetype="dashed", color='#ffcccb') +
                gg.geom_line(gg.aes('year', internal_y2plot), color='blue') +
                gg.geom_smooth(gg.aes('year', internal_y2plot), linetype="dashed", color='#95d4e8') +
                gg.geom_hline(yintercept=0, linetype="dashed", color = "black") +
                gg.theme_classic() +
                gg.facet_wrap('geonames_admin1_ascii_name') +
                gg.labs(x="Year", y=ylabel2use) +
                gg.theme(panel_background=gg.element_rect(fill='gray', alpha=.1), legend_position="bottom",
                        axis_text_x=gg.element_text(hjust=1, size=10, angle=45),
                        axis_text_y=gg.element_text(hjust=1, size=10),
                        axis_title_x=gg.element_text(size=10),
                        axis_title_y=gg.element_text(size=10),
                        strip_text_x=gg.element_text(size=8),
                        figure_size=(10, 10))
        )
    else:
        lg('Facetting by given size.')
        fig2save = (
                gg.ggplot((dt2use
                        [(dt2use['region'].notnull()) & (dt2use['region'].str.contains(code2use))]
                        .query('`region` != @region2exclude'))) +
                gg.geom_line(gg.aes('year', international_y2plot), color='red') +
                gg.geom_smooth(gg.aes('year', international_y2plot), linetype="dashed", color='#ffcccb') +
                gg.geom_line(gg.aes('year', internal_y2plot), color='blue') +
                gg.geom_smooth(gg.aes('year', internal_y2plot), linetype="dashed", color='#95d4e8') +
                gg.geom_hline(yintercept=0, linetype="dashed", color = "black") +
                gg.theme_classic() +
                gg.facet_wrap('geonames_admin1_ascii_name', nrow=int(size2wrap1), ncol=int(size2wrap2)) +
                gg.labs(x="Year", y=ylabel2use) +
                gg.theme(panel_background=gg.element_rect(fill='gray', alpha=.1), legend_position="bottom",
                        axis_text_x=gg.element_text(hjust=1, size=10, angle=45),
                        axis_text_y=gg.element_text(hjust=1, size=10),
                        axis_title_x=gg.element_text(size=10),
                        axis_title_y=gg.element_text(size=10),
                        strip_text_x=gg.element_text(size=8),
                        figure_size=(10, 10))
        )

    gg.ggplot.save(fig2save, args.output[0], limitsize=False, dpi=500)


# plot using the provided command line arguments
country_ploting(dt2use=data, code2use=args.code2use, size2wrap1=args.size2wrap1, size2wrap2=args.size2wrap2, internal_y2plot="nmr_IN", international_y2plot="nmr_INT", ylabel2use="Rate per 1000 scholars")

lg(f"Figure exported in: '{args.output[0]}'")
