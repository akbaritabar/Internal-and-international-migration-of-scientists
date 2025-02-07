## File name to use in search: subnational_regions_anmr_500plus_line_plots.py ##

# Python script that use DuckDB and SQL script for data processing/reshaping


import pandas as pd
import numpy as np
# to visualize
import plotnine as gg
# for log (10^3 etc) labels
from mizani.labels import label_number

# to see more pandas columns & not to use scientific notation
pd.set_option('max_colwidth',100)
pd.set_option('display.float_format', '{:.2f}'.format)

# a brief function to color annotation on figure based on negative/positive
def color_func(s):
    return ['#d73027' if value < 0 else '#1a9850' for value in s]


# ============================
#### Results log and progress report ####
# ============================

# to keep record of events
import logging

# save log report here
logging.basicConfig(level=logging.INFO,
     format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")

# define a shortcut for logging function and its "info" method
lg = logging.info

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
#### Read data and visualize ####
# ============================

data = pd.read_csv(args.input[0])

lg(f"Data read from '{args.input[0]}'")
lg(f"A few rows: '{data.tail()}'")

# limit data to 1998-2017 (inclusive)
data = data[(data.year > 1997) & (data.year < 2018)]

lg(f"Description of years in data: '{data.year.describe()}'")

# ============================
#### ANMR line plots for chosen countries (those with 5000+ population) ####
# ============================

# [ ] TODO: check why North America is not there? NA is filtered?
# [ ] TODO: check if country population threshold is working, why some countries are changed like Romania and Serbia switched?
# [ ] TODO: Revise country names and use the "proper name" (shorter) from other script
# [ ] TODO: are all years right? Why Kendall correlation changed for countries? Could this only be effect of more data/scholars here? 
# [ ] TODO: could you remove extra rows and do it at country level? take needed columns, country, continent, etc and repeat.

# a list of countries with with 5k+ scholars
# data['avg_pop'] = data.groupby('region')['y_pop_INT'].mean()

plus_5000_countries = list(data[data.y_pop_INT > 5000].region.unique())


# replicate ANMR figure for 5k+ scholars per year
# calculate and add ANMR columns
INTdt = (
    data
    [data.country_2letter_code.notnull()]
    .groupby(['year', 'country_2letter_code'])
    [['year', 'country_2letter_code', 'abs_inout_INT', 'y_pop_INT']]
    .apply(lambda x: 100 * (0.5 * sum(x['abs_inout_INT'] / sum(x['y_pop_INT']))))
    .reset_index()
    .rename(columns={0:'anmr_y_INT'})
    [['country_2letter_code', 'year', 'anmr_y_INT']]
)

INdt = (
    data
    [data.country_2letter_code.notnull()]
    .groupby(['year', 'country_2letter_code'])
    [['year', 'country_2letter_code', 'abs_inout_IN', 'y_pop_IN']]
    .apply(lambda x: 100 * (0.5 * sum(x['abs_inout_IN'] / sum(x['y_pop_IN']))))
    .reset_index()
    .rename(columns={0:'anmr_y_IN'})
    [['country_2letter_code', 'year', 'anmr_y_IN']]
)

data = (data
        .merge(INTdt, how='left', on=['country_2letter_code', 'year'])
        .merge(INdt, how='left', on=['country_2letter_code', 'year'])
)

# calculate a correlation between internal and international ANMR to use on figure
anmr_correlation_res = (
    data
    .query('`region` == @plus_5000_countries')
    .sort_values(by=['region', 'year'])
    .groupby('region')
    [['anmr_y_INT','anmr_y_IN']]
    # change correlation method here to kendall or spearman
    .corr(method='kendall')
    .reset_index()
    .drop_duplicates(subset='region')
    .rename(columns={'anmr_y_IN':'correlation'})
    [['region', 'correlation']]
    .sort_values(by=['correlation'])
)

fig2save = (
    gg.ggplot((data.query('`region` == @plus_5000_countries')
    .merge(anmr_correlation_res, how='left', on='region')
    .assign(corr_round = lambda x: np.round(x.correlation, decimals=2))
    )) +
    gg.geom_line(gg.aes('year', 'anmr_y_INT'), color='red') +
    gg.geom_smooth(gg.aes('year', 'anmr_y_INT'), linetype="dashed", color='#ffcccb') +
    gg.geom_line(gg.aes('year', 'anmr_y_IN'), color='blue') +
    gg.geom_smooth(gg.aes('year', 'anmr_y_IN'), linetype="dashed", color='#95d4e8') +
    gg.geom_hline(yintercept=0, linetype="dashed", color = "black") +
    gg.geom_text(gg.aes(x=2010, y=0.02, label='corr_round', color=gg.after_scale('color_func(label)')), size=9) +
    gg.theme_classic() +
    gg.scale_y_log10() +
    gg.facet_wrap('continent_code+": "+country_name') +
    gg.labs(x="Year", y="Rate per 100 scholars (log scale)", title = 'International and Internal ANMR (countries with 5k+ scholars per year)') +
    gg.theme(panel_background=gg.element_rect(fill='gray', alpha=.1), legend_position="none",
             axis_text_x=gg.element_text(hjust=1, size=9, angle=45),
             axis_text_y=gg.element_text(hjust=1, size=10),
             axis_title_x=gg.element_text(size=10),
             axis_title_y=gg.element_text(size=10),
             strip_text_x=gg.element_text(size=7),
             figure_size=(8, 8))
)

gg.ggplot.save(fig2save, args.output[0], limitsize=False, dpi=500)


lg(f"Figure exported in: '{args.output[0]}'")



