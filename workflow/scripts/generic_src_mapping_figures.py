## File name to use in search: generic_src_mapping_figures.py ##

import pandas as pd
import os
import plotnine as gg
# for mapping
import geopandas as gp
#### Results log and progress report ####
from tolog import lg

# %matplotlib inline # in case using jupyter lab/notebooks for plots to be shown

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
parser.add_argument("-i", "--input", help = "Input file to use", type = str, required = True, nargs='+')
parser.add_argument("-mig", "--MEASURE_MAPPED", help = "Parameters to use in plotting", type = str, required = True)
parser.add_argument("-migsys", "--MIGRATION_SYSTEM", help = "Parameters to use in plotting", type = str, required = True)
parser.add_argument("-geo", "--GEO_REGION", help = "Parameters to use in plotting", type = str, required = True)
parser.add_argument("-tme", "--TIME_SPAN", help = "Parameters to use in plotting", type = str, required = True)
parser.add_argument("-dis", "--DISAGGREGATION", help = "Author attribute to disaggregate migration with", type = str, required = False)
parser.add_argument("-var", "--VAR_CATEGORY", help = "Author attribute's current category to disaggregate migration with", type = str, required = False)
parser.add_argument("-o", "--output", help = "Output data path", type = str, required = True)

args = parser.parse_args()

#lg(f"Log file is here: {os.path.join(outputs_dir, log_file_name)}")
lg(f"These items are in the environment: {dir()}")

# ============================
#### Preparing data ####
# ============================

# ============================
#### Things to reuse multiple times (e.g., color palette) ####
# ============================

# (from red-yellow-green palette: RdYlGn, https://loading.io/color/feature/RdYlGn-9/)
RdYlGn_4maps = ['#d7d7d2', # for missing (NAs)
                '#d73027', # for lowest negative value (darkred)
                '#f46d43', 
                '#fdae61', 
                '#fee08b', 
                '#ffffbf', # for 0 or balanced flow (yellow)
                '#d9ef8b',
                '#a6d96a',
                '#66bd63', 
                '#1a9850' # for the highest positive value (darkgreen)
                ]

lg(f"Arguments received from command line: \n {args}")

# ============================
#### Read data prepared for mapping ####
# ============================

# world country boundaries
world = gp.read_parquet(args.input[0])

# world provinces/state boundaries
world_states_joined = gp.read_parquet(args.input[1])


lg('#'*50)
lg(f"Reading data from {args.input[0]} AND {args.input[1]}")
lg('#'*50)
lg('Data is imported!')

# ============================
#### Generic mapping script (geopandas) ####
# ============================

# generic IF statement for column that is being mapped and time to use in titles
# a generic year range to use
if args.TIME_SPAN == '20122017':
    years2use = "2012-2017"
elif args.TIME_SPAN == '19982017':
    years2use = "1998-2017"
elif args.TIME_SPAN == '20002005':
    years2use = "2000-2005"
elif args.TIME_SPAN == '20062011':
    years2use = "2006-2011"


# NOTE, this procedure uses the LONG format table with all categories of the chosen attribute to disaggregate, then below for each category of that variable, one figure is exported.

# depending on the disaggregation measure used, take that variable from authors' attributes and use it below in group-by calls to disaggregate by it 
lg(f"Disaggregating by: {args.DISAGGREGATION}")

if args.DISAGGREGATION == 'PRODUCTIVITY':
    DISAGGREGATION_COLUMN = 'prod_cat'
    title_part = 'N. pub: '
elif args.DISAGGREGATION == 'AGE':
    DISAGGREGATION_COLUMN = 'academic_age_cat'
    title_part = 'Status: '
elif args.DISAGGREGATION == 'DISCIPLINE':
    DISAGGREGATION_COLUMN = 'fieldOfScience'
    title_part = 'Field: '
elif args.DISAGGREGATION is None:
    lg("NOT Disaggregating by author attributes!")
    titlefontsize = 15

# NMR here
if args.MIGRATION_SYSTEM == 'INTIN' and args.MEASURE_MAPPED == 'NMR':
    column2map = "nmr_INT_IN_sum_region"
    lg(f"Mapping this column: {column2map}")
    if args.DISAGGREGATION is None:
        title2use = f"Subnational net migration rates per 1,000 scholars, {years2use}"
    else:
        title2use = f"Subnational net migration rates per 1,000 scholars, {years2use}, {title_part}{args.VAR_CATEGORY}"
        titlefontsize = 10
elif args.MIGRATION_SYSTEM == 'IN' and args.MEASURE_MAPPED == 'NMR':
    column2map = f"nmr_{args.MIGRATION_SYSTEM}_sum_region"
    lg(f"Mapping this column: {column2map}")
    if args.DISAGGREGATION is None:
        title2use = f"Internal net migration rates per 1,000 scholars, {years2use}"
    else:
        title2use = f"Internal net migration rates per 1,000 scholars, {years2use}, {title_part}{args.VAR_CATEGORY}"
        titlefontsize = 10
elif args.MIGRATION_SYSTEM == 'INT' and args.MEASURE_MAPPED == 'NMR':
    column2map = f"nmr_{args.MIGRATION_SYSTEM}_sum_region"
    lg(f"Mapping this column: {column2map}")
    if args.DISAGGREGATION is None:
        title2use = f"International net migration rates per 1,000 scholars, {years2use}"
    else:
        title2use = f"International net migration rates per 1,000 scholars, {years2use}, {title_part}{args.VAR_CATEGORY}"
        titlefontsize = 10
# MEI here
elif args.MIGRATION_SYSTEM == 'INTIN' and args.MEASURE_MAPPED == 'MEI':
    column2map = "mei_INT_IN_sum_region"
    lg(f"Mapping this column: {column2map}")
    if args.DISAGGREGATION is None:
        title2use = f"Subnational migration effectiveness per 100 scholars, {years2use}"
    else:
        title2use = f"Subnational migration effectiveness per 100 scholars, {years2use}, {title_part}{args.VAR_CATEGORY}"
        titlefontsize = 10
elif args.MIGRATION_SYSTEM == 'IN' and args.MEASURE_MAPPED == 'MEI':
    column2map = f"mei_{args.MIGRATION_SYSTEM}_sum_region"
    lg(f"Mapping this column: {column2map}")
    if args.DISAGGREGATION is None:
        title2use = f"Internal migration effectiveness per 100 scholars, {years2use}"
    else:
        title2use = f"Internal migration effectiveness per 100 scholars, {years2use}, {title_part}{args.VAR_CATEGORY}"
        titlefontsize = 10
elif args.MIGRATION_SYSTEM == 'INT' and args.MEASURE_MAPPED == 'MEI':
    column2map = f"mei_{args.MIGRATION_SYSTEM}_sum_region"
    lg(f"Mapping this column: {column2map}")
    if args.DISAGGREGATION is None:
        title2use = f"International migration effectiveness per 100 scholars, {years2use}"
    else:
        title2use = f"International migration effectiveness per 100 scholars, {years2use}, {title_part}{args.VAR_CATEGORY}"
        titlefontsize = 10
# IMP (mearuse of migration importance) here
elif args.MIGRATION_SYSTEM == 'IN' and args.MEASURE_MAPPED == 'INFLOW':
    column2map = "IMP_IN_inflow"
    lg(f"Mapping this column: {column2map}")
    if args.DISAGGREGATION is None:
        title2use = f"Internal in-flows as percentage of total, {years2use}"
    else:
        title2use = f"Internal in-flows as percentage of total, {years2use}, {title_part}{args.VAR_CATEGORY}"
        titlefontsize = 10
elif args.MIGRATION_SYSTEM == 'IN' and args.MEASURE_MAPPED == 'OUTFLOW':
    column2map = "IMP_IN_outflow"
    lg(f"Mapping this column: {column2map}")
    if args.DISAGGREGATION is None:
        title2use = f"Internal out-flows as percentage of total, {years2use}"
    else:
        title2use = f"Internal out-flows as percentage of total, {years2use}, {title_part}{args.VAR_CATEGORY}"
        titlefontsize = 10


# check if data has any rows for the disaggregation variable's category or not
if args.DISAGGREGATION:
    world_states_joined = world_states_joined[world_states_joined[DISAGGREGATION_COLUMN] == args.VAR_CATEGORY]
    lg('data filtered based on disaggregation column!')
elif args.DISAGGREGATION is None:
    lg('No disaggregation happens, using the whole data!')
    DISAGGREGATION_COLUMN = None

if ~world_states_joined.empty:
    lg(f"Disaggregation column in use is: {DISAGGREGATION_COLUMN}")
    lg(f"Disaggregation category in use is: {args.VAR_CATEGORY}")
    lg(f"DF NOT empty; Few rows of data: \n {world_states_joined.tail()}")

    # for thisout in args.output:
    lg(f"The output in Python script is: {args.output}")
    if args.GEO_REGION == 'WORLD' and args.MEASURE_MAPPED == 'NMR':
        lg('Theme used WORLD, NMR')
        # define the same range of colors for all NMR maps to be comparable

        # assign colors (from palette defined on top of script: RdYlGn)
        world_states_joined['fill_color2use'] = RdYlGn_4maps[0] # assume missing (NA), gray color

        world_states_joined.loc[(world_states_joined[column2map] < -1000), 'fill_color2use'] = RdYlGn_4maps[1]

        world_states_joined.loc[(world_states_joined[column2map] < -100) & (world_states_joined[column2map] >= -1000), 'fill_color2use'] = RdYlGn_4maps[2]

        world_states_joined.loc[(world_states_joined[column2map] < -10) & (world_states_joined[column2map] >= -100), 'fill_color2use'] = RdYlGn_4maps[3]

        world_states_joined.loc[(world_states_joined[column2map] < 0) & (world_states_joined[column2map] >= -10), 'fill_color2use'] = RdYlGn_4maps[4]

        world_states_joined.loc[world_states_joined[column2map] == 0 , 'fill_color2use'] = RdYlGn_4maps[5]

        world_states_joined.loc[(world_states_joined[column2map] > 0) & (world_states_joined[column2map] <= 10), 'fill_color2use'] = RdYlGn_4maps[6]

        world_states_joined.loc[(world_states_joined[column2map] > 10) & (world_states_joined[column2map] <= 100), 'fill_color2use'] = RdYlGn_4maps[7]

        world_states_joined.loc[(world_states_joined[column2map] > 100) & (world_states_joined[column2map] <= 1000), 'fill_color2use'] = RdYlGn_4maps[8]

        world_states_joined.loc[(world_states_joined[column2map] > 1000), 'fill_color2use'] = RdYlGn_4maps[9]


        plot2save = (gg.ggplot()
        + gg.geom_map((world_states_joined), gg.aes(fill='fill_color2use'), size=0, color=None, show_legend=True)
        + gg.labs(title=title2use, fill='')
        + gg.scale_fill_identity(guide='legend', 
                                breaks=[RdYlGn_4maps[9], RdYlGn_4maps[8], RdYlGn_4maps[7], RdYlGn_4maps[6],RdYlGn_4maps[5], RdYlGn_4maps[4], RdYlGn_4maps[3], RdYlGn_4maps[2], RdYlGn_4maps[1], RdYlGn_4maps[0]], 
                                labels=[
                                        '> 1000', 
                                        '({}, {}]'.format(100, 1000), 
                                        '({}, {}]'.format(10, 100), 
                                        '({}, {}]'.format(0, 10), 
                                        '0', 
                                        '[{}, {})'.format(-10, 0), 
                                        '[{}, {})'.format(-100, -10), 
                                        '[{}, {})'.format(-1000, -100), 
                                        '< -1000', 
                                        'No data'
                                        ])
        + gg.geom_map(world, fill=None, size=0.08, alpha=0.000, color='#8A8A8A', linetype='dashdot', show_legend=False)
        + gg.coord_cartesian(xlim=(-12000000, 15000000), ylim=(-5400000, 7800000))
        + gg.theme_void()
        + gg.theme(
            legend_position=(-0.01,0),  # Position of the legend
            legend_direction='vertical',  # Direction of the legend items
            legend_text=gg.element_text(weight='bold', size=8),  # Legend text style
            legend_title=gg.element_text(weight='bold', size=10, linespacing=1.25),  # Legend title style
            legend_key_spacing=1,  # Spacing around legend keys
            legend_key_spacing_x=1,  # Horizontal spacing around legend keys
            legend_key_spacing_y=0,  # Vertical spacing around legend keys
            legend_key_size=12,  # Size of the legend keys
            legend_key_width=15,  # Width of the legend keys
            legend_key_height=50,  # Height of the legend keys
            legend_box_margin=5,  # Margin around the legend box
            plot_title=gg.element_text(ha='left', size=titlefontsize),  # Plot title style
            figure_size=(7, 3.5)  # Size of the figure
        )
        + gg.guides(color=gg.guide_legend(ncol=1))
        )


        gg.ggplot.save(plot2save, args.output, dpi=500, limitsize=False)

    elif args.GEO_REGION == 'EU' and args.MEASURE_MAPPED == 'NMR':
        lg('Theme used EU, NMR')
        
        # define the same range of colors for all NMR maps to be comparable

        # assign colors (from palette defined on top of script: RdYlGn)
        world_states_joined['fill_color2use'] = RdYlGn_4maps[0] # assume missing (NA), gray color

        world_states_joined.loc[(world_states_joined[column2map] < -1000), 'fill_color2use'] = RdYlGn_4maps[1]

        world_states_joined.loc[(world_states_joined[column2map] < -100) & (world_states_joined[column2map] >= -1000), 'fill_color2use'] = RdYlGn_4maps[2]

        world_states_joined.loc[(world_states_joined[column2map] < -10) & (world_states_joined[column2map] >= -100), 'fill_color2use'] = RdYlGn_4maps[3]

        world_states_joined.loc[(world_states_joined[column2map] < 0) & (world_states_joined[column2map] >= -10), 'fill_color2use'] = RdYlGn_4maps[4]

        world_states_joined.loc[world_states_joined[column2map] == 0 , 'fill_color2use'] = RdYlGn_4maps[5]

        world_states_joined.loc[(world_states_joined[column2map] > 0) & (world_states_joined[column2map] <= 10), 'fill_color2use'] = RdYlGn_4maps[6]

        world_states_joined.loc[(world_states_joined[column2map] > 10) & (world_states_joined[column2map] <= 100), 'fill_color2use'] = RdYlGn_4maps[7]

        world_states_joined.loc[(world_states_joined[column2map] > 100) & (world_states_joined[column2map] <= 1000), 'fill_color2use'] = RdYlGn_4maps[8]

        world_states_joined.loc[(world_states_joined[column2map] > 1000), 'fill_color2use'] = RdYlGn_4maps[9]


        plot2save = (gg.ggplot()
        + gg.geom_map((world_states_joined.query('continent_code == "EU"')), 
                    gg.aes(fill='fill_color2use'), size=0.04, color=None, show_legend=True)
        + gg.labs(title="")
        + gg.scale_fill_identity()
        + gg.geom_map(world.query('continent == "Europe"'), fill=None, size=0.08, alpha=0.000, color='#8A8A8A', linetype='dashdot', show_legend=False)
        + gg.coord_cartesian(xlim=(-700000, 2000000), ylim=(3500000, 6500000))
        + gg.theme_void()
        + gg.theme(legend_position='none',plot_title=gg.element_blank(), figure_size=(5, 5))
        )
        gg.ggplot.save(plot2save, args.output, dpi=500, limitsize=False)


    elif args.GEO_REGION == 'WORLD' and (args.MEASURE_MAPPED == 'MEI' or args.MEASURE_MAPPED == 'INFLOW' or args.MEASURE_MAPPED == 'OUTFLOW'):
        lg('Theme used WORLD, MEI or IMP')

        # assign colors (from palette defined on top of script: RdYlGn)
        world_states_joined['fill_color2use'] = RdYlGn_4maps[0] # assume missing (NA), gray color

        # colors from: https://rpubs.com/mjvoss/psc_viridis
        # from 100 (highest score, yellow in virdis: #fde725) to lowest score 0 (#440154)

        world_states_joined.loc[(world_states_joined[column2map] == 100), 'fill_color2use'] = '#fde725'

        world_states_joined.loc[(world_states_joined[column2map] < 100) & (world_states_joined[column2map] >= 90), 'fill_color2use'] = '#bddf26'

        world_states_joined.loc[(world_states_joined[column2map] < 90) & (world_states_joined[column2map] >= 80), 'fill_color2use'] = '#7ad151'

        world_states_joined.loc[(world_states_joined[column2map] < 80) & (world_states_joined[column2map] >= 70), 'fill_color2use'] = '#44bf70'

        world_states_joined.loc[(world_states_joined[column2map] < 70) & (world_states_joined[column2map] >= 60), 'fill_color2use'] = '#22a884'

        world_states_joined.loc[(world_states_joined[column2map] < 60) & (world_states_joined[column2map] >= 50), 'fill_color2use'] = '#21918c'

        world_states_joined.loc[(world_states_joined[column2map] < 50) & (world_states_joined[column2map] >= 40), 'fill_color2use'] = '#2a788e'

        world_states_joined.loc[(world_states_joined[column2map] < 40) & (world_states_joined[column2map] >= 30), 'fill_color2use'] = '#355f8d'

        world_states_joined.loc[(world_states_joined[column2map] < 30) & (world_states_joined[column2map] >= 20), 'fill_color2use'] = '#414487'

        world_states_joined.loc[(world_states_joined[column2map] < 20) & (world_states_joined[column2map] > 0), 'fill_color2use'] = '#482475'

        world_states_joined.loc[(world_states_joined[column2map] == 0), 'fill_color2use'] = '#440154'

        plot2save = (gg.ggplot()
        + gg.geom_map((world_states_joined), gg.aes(fill='fill_color2use'), size=0, color=None, show_legend=True)
        + gg.labs(title=title2use, fill='')
        + gg.scale_fill_identity(guide='legend', 
                                breaks=['#fde725', '#bddf26', '#7ad151', '#44bf70',
                                        '#22a884', '#21918c', '#2a788e', '#355f8d', 
                                        '#414487', '#482475', '#440154', RdYlGn_4maps[0]], 
                                labels=[
                                        '100', 
                                        '[{}, {})'.format(90, 100), 
                                        '[{}, {})'.format(80, 90), 
                                        '[{}, {})'.format(70, 80), 
                                        '[{}, {})'.format(60, 70), 
                                        '[{}, {})'.format(50, 60), 
                                        '[{}, {})'.format(40, 50), 
                                        '[{}, {})'.format(30, 40), 
                                        '[{}, {})'.format(20, 30), 
                                        '[{}, {})'.format(0, 20), 
                                        '0', 
                                        'No data'
                                        ])
        + gg.geom_map(world, fill=None, size=0.08, alpha=0.000, color='#8A8A8A', linetype='dashdot', show_legend=False)
        + gg.coord_cartesian(xlim=(-12000000, 15000000), ylim=(-5400000, 7800000))
        + gg.theme_void()
        + gg.theme(
            legend_position=(-0.01,-0.20),  # Position of the legend
            legend_direction='vertical',  # Direction of the legend items
            legend_text=gg.element_text(weight='bold', size=6),  # Legend text style
            legend_title=gg.element_blank(),  # Legend title style
            legend_key_spacing=1,  # Spacing around legend keys
            legend_key_spacing_x=1,  # Horizontal spacing around legend keys
            legend_key_spacing_y=0,  # Vertical spacing around legend keys
            legend_key_size=12,  # Size of the legend keys
            legend_key_width=15,  # Width of the legend keys
            legend_key_height=50,  # Height of the legend keys
            legend_box_margin=5,  # Margin around the legend box
            plot_title=gg.element_text(ha='left', size=titlefontsize),  # Plot title style
            figure_size=(7.5, 3.5)  # Size of the figure
        )
        + gg.guides(color=gg.guide_legend(ncol=1))
        )

        gg.ggplot.save(plot2save, args.output, dpi=500, limitsize=False)
        
    elif args.GEO_REGION == 'EU' and (args.MEASURE_MAPPED == 'MEI' or args.MEASURE_MAPPED == 'INFLOW' or args.MEASURE_MAPPED == 'OUTFLOW'):
        lg('Theme used EU, MEI or IMP')

        # assign colors (from palette defined on top of script: RdYlGn)
        world_states_joined['fill_color2use'] = RdYlGn_4maps[0] # assume missing (NA), gray color

        # colors from: https://rpubs.com/mjvoss/psc_viridis
        # from 100 (highest score, yellow in virdis: #fde725) to lowest score 0 (#440154)

        world_states_joined.loc[(world_states_joined[column2map] == 100), 'fill_color2use'] = '#fde725'

        world_states_joined.loc[(world_states_joined[column2map] < 100) & (world_states_joined[column2map] >= 90), 'fill_color2use'] = '#bddf26'

        world_states_joined.loc[(world_states_joined[column2map] < 90) & (world_states_joined[column2map] >= 80), 'fill_color2use'] = '#7ad151'

        world_states_joined.loc[(world_states_joined[column2map] < 80) & (world_states_joined[column2map] >= 70), 'fill_color2use'] = '#44bf70'

        world_states_joined.loc[(world_states_joined[column2map] < 70) & (world_states_joined[column2map] >= 60), 'fill_color2use'] = '#22a884'

        world_states_joined.loc[(world_states_joined[column2map] < 60) & (world_states_joined[column2map] >= 50), 'fill_color2use'] = '#21918c'

        world_states_joined.loc[(world_states_joined[column2map] < 50) & (world_states_joined[column2map] >= 40), 'fill_color2use'] = '#2a788e'

        world_states_joined.loc[(world_states_joined[column2map] < 40) & (world_states_joined[column2map] >= 30), 'fill_color2use'] = '#355f8d'

        world_states_joined.loc[(world_states_joined[column2map] < 30) & (world_states_joined[column2map] >= 20), 'fill_color2use'] = '#414487'

        world_states_joined.loc[(world_states_joined[column2map] < 20) & (world_states_joined[column2map] > 0), 'fill_color2use'] = '#482475'

        world_states_joined.loc[(world_states_joined[column2map] == 0), 'fill_color2use'] = '#440154'

        plot2save = (gg.ggplot()
        + gg.geom_map((world_states_joined.query('continent_code == "EU"')), 
                    gg.aes(fill='fill_color2use'), size=0.02, color=None, show_legend=True)
        + gg.labs(title="")
        + gg.scale_fill_identity()
        + gg.geom_map(world.query('continent == "Europe"'), fill=None, size=0.04, alpha=0.000, color='#8A8A8A', linetype='dashdot', show_legend=False)
        + gg.coord_cartesian(xlim=(-700000, 2000000), ylim=(3500000, 6500000))
        + gg.theme_void()
        + gg.theme(legend_position='none',plot_title=gg.element_blank(), figure_size=(5, 5))
        )

        gg.ggplot.save(plot2save, args.output, dpi=500, limitsize=False)

    else:
        lg('Something is wrong, check!')

    lg('#'*50)
    lg(f'Figure {args.output} is exported.')
else:
    lg(f"DF WAS EMPTY; CHECK WHAT HAPPENED?!")

