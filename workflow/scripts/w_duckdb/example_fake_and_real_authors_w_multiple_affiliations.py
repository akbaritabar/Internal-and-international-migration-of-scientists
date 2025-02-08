## File name to use in search: example_fake_and_real_authors_w_multiple_affiliations.py ##

# Python script that use DuckDB and SQL script for data processing/reshaping

# for data handling
import duckdb
import pandas as pd
# for description tables
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
#### Run DuckDB SQL script ####
# ============================

# ============================
#### multiple affiliation authors ####
# ============================

# - [ ] for multiple affiliation, first assign single or multiple affiliation to each author of a paper, then group by authors and count unique years in typology (single/multiple aff), an author having multiple years of career with multiple affiliations could be counted to find the dominant type of affiliation i.e., single or multiple for the population 

# plus ?!, bring an example authorship record in pandas like in SMD paper to show how mode based method treats multiple affiliations in a year under same or multiple papers.


################### an illustrative example of 2 authors for response letter #########

one_example = pd.DataFrame({
    'Author name': 
        ['Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1'],
    'Publication ID': 
        ['Paper 1', 'Paper 1', 'Paper 1', 'Paper 2', 'Paper 2', 'Paper 3', 'Paper 4', 'Paper 5', 'Paper 6', 'Paper 7', 'Paper 8'],
    'Affiliation': 
        ['Affiliation A', 'Affiliation B', 'Affiliation C', 'Affiliation A', 'Affiliation C', 'Affiliation A', 'Affiliation C', 'Affiliation D', 'Affiliation C', 'Affiliation E', 'Affiliation E'],
    'Region': 
        ['Region A', 'Region B', 'Region C', 'Region A', 'Region C', 'Region A', 'Region C','Region D', 'Region C', 'Region E', 'Region E'],
    'Year': [2001, 2001, 2001, 2001, 2001, 2002, 2003, 2007, 2008, 2009, 2010]
})

lg('Toy example data: ')
lg(one_example)

# after 2 year backward fill
one_example_filled = pd.DataFrame({
    'Author name': 
        ['Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1', 'Author 1'],
    'Publication ID': 
        ['Paper 1', 'Paper 1', 'Paper 1', 'Paper 2', 'Paper 2', 'Paper 3', 'Paper 4', 'Paper (filled)', 'Paper (filled)','Paper 5', 'Paper 6', 'Paper 7', 'Paper 8'],
    'Affiliation': 
        ['Affiliation A', 'Affiliation B', 'Affiliation C', 'Affiliation A', 'Affiliation C', 'Affiliation A', 'Affiliation C', 'Affiliation D (filled)', 'Affiliation D (filled)','Affiliation D', 'Affiliation C', 'Affiliation E', 'Affiliation E'],
    'Region': 
        ['Region A', 'Region B', 'Region C', 'Region A', 'Region C', 'Region A', 'Region C','Region D', 'Region D','Region D','Region C', 'Region E', 'Region E'],
    'Year': [2001, 2001, 2001, 2001, 2001, 2002, 2003, 2005, 2006, 2007, 2008, 2009, 2010]
})

lg('Toy example data, filled: ')
lg(one_example_filled)


# mode-based method
mode_based_ex = one_example.groupby(['Author name','Year']).agg(
    mode_region=pd.NamedAgg(column='Region', aggfunc=pd.Series.mode)).reset_index()

# after backward fill of 2 years
mode_based_ex_filled = one_example_filled.groupby(['Author name','Year']).agg(
    mode_region=pd.NamedAgg(column='Region', aggfunc=pd.Series.mode)).reset_index()

headers2use = ['Author name', 'Publication ID', 'Affiliation', 'Region', 'Year']

# convert to markdown (or latex) format
f = open(args.output[0], 'w')
f.write(tabulate.tabulate(one_example_filled,
                          showindex=False,
                          headers=headers2use,
                          tablefmt='latex'))
f.close()

lg(f"Table exported in: '{args.output[0]}'")

headers2use = ['Author name', 'Year', 'Mode region']

# convert to markdown (or latex) format
f = open(args.output[1], 'w')
f.write(tabulate.tabulate(mode_based_ex_filled,
                          showindex=False,
                          headers=headers2use,
                          tablefmt='latex'))
f.close()

lg(f"Table exported in: '{args.output[1]}'")

# example author with multiple affiliations in one paper
exmpl1 = 'AUTHOR-X-ID'
example_author_exmpl1 = duckdb.sql(f"""select * 
from '{args.input[0]}' 
where pubyear > 1995
and pubyear < 2021
and author_id > 10
and disamb_ror_new_id is not null
and geonames_admin1_code is not null
and author_id is not null
and org_country3 is not null
and author_id = '{exmpl1}'""").df()

lg(f"One real author extracted, ID: '{exmpl1}'")

# year 2019 as example
exmpl12019 = example_author_exmpl1[example_author_exmpl1.pubyear == 2019][['author_id', 'item_id', 'pubyear', 'geonames_admin1_code']].sort_values(by='item_id')

headers2use = ['Author ID', 'Publication ID', 'Year', 'Region']

# convert to markdown (or latex) format
f = open(args.output[2], 'w')
f.write(tabulate.tabulate(exmpl12019,
                          showindex=False,
                          headers=headers2use,
                          tablefmt='latex'))
f.close()

lg(f"Table exported in: '{args.output[2]}'")

# mode
mode_based_ex_exmpl1 = example_author_exmpl1.groupby(['author_id','pubyear']).agg(
    mode_region=pd.NamedAgg(column='geonames_admin1_code', aggfunc=pd.Series.mode)).reset_index()


headers2use = ['Author ID', 'Year', 'Mode region']

# convert to markdown (or latex) format
f = open(args.output[3], 'w')
f.write(tabulate.tabulate(mode_based_ex_exmpl1,
                          showindex=False,
                          headers=headers2use,
                          tablefmt='latex'))
f.close()

lg(f"Table exported in: '{args.output[3]}'")
