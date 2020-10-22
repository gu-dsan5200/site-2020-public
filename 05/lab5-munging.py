import pandas as pd

original = pd.read_table("data/dataset1.tds", sep="\t")

original[['name','bp','mf','systematic_name','number']] =\
    original['NAME'].str.split('\\|\\|',expand=True)

tidy_gene = 