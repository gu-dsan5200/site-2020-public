# ---
# jupyter:
#   jupytext:
#     formats: ipynb,Rmd,py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.4.2
#   kernelspec:
#     display_name: Python 3
#     language: python
#     name: python3
# ---

# %% [markdown]
# # Week 11 Laboratory: Interactive graphics using plotly
#
# ## Introduction
#
# [Plotly](https://www.plotly.com) provides a Javascript library, `plotly.js`, for creating interactive graphics in a web browser. It is built on top of [d3.js](https://d3js.org) with a simpler API, and is released under the MIT license as a free and open source project. 
#
# Plotly provides wrappers for both R (`library(plotly)`) and Python (`import plotly.express as px`) packages to use plotly.js from each language. 

# %% [markdown]
# ## R and Plotly
#
# In this lab we may get to the lower level plotly API, but the main driver for plotly in R is its ability to "automatically" convert a `ggplot` object into plotly using the function `ggplotly`. For example
#
# ```r
# library(plotly)
# library(ggplot)
# plt <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species))+ geom_point()
# ggplotly(plt)
# ```
#

# %% jupyter={"source_hidden": true}
from IPython.display import IFrame, HTML
IFrame('plotly_r.html', width=600, height=500)

# %% [markdown]
# There is a plotly-specific API that we'll get into later

# %% [markdown]
# ## Python and Plotly
#
# The main entry point into Plotly from Python is the package Plotly Express, which provides a simplified API for creating Plotly graphics in Python

# %%
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px
import plotly.io as pio

#pio.templates.default = 'presentation'


# %% [markdown]
# #### Scatter plots

# %% [markdown]
# Scatter plots are created using `px.scatter`. We'll be using the _penguins_ dataset that is also available in R.

# %%
penguins = sns.load_dataset('penguins')
penguins.head()

# %%
fig = px.scatter(data_frame=penguins, x = 'bill_length_mm', y = 'body_mass_g', 
                width=600, height=400)
fig.update_layout(hovermode='closest')
fig.show()

# %% [markdown]
# We can add strata to this using colors or shapes

# %%
fig = px.scatter(data_frame=penguins, x='bill_length_mm', y = 'body_mass_g', color = 'species',
                width=800, height=600)
fig.show()

# %% [markdown]
# You can also add variables that should appear in the tooltips as you hover over a point with your mouse

# %%
fig = px.scatter(data_frame=penguins, x='bill_length_mm', y = 'body_mass_g', color = 'species', hover_data = ['species', 'island','sex'],
                width=800, height=600)
fig.show()

# %% [markdown]
# For stratified plots like this, you can click on an item in the legend to toggle whether that stratum appears or not. Try it out!!

# %% [markdown]
# You can also annotate the graph with appropriate titles and axes labels

# %%
fig = px.scatter(data_frame=penguins, x='bill_length_mm', y = 'body_mass_g', color = 'species', hover_data = ['species', 'island','sex'],
                 width=800, height=600,
                labels = dict(bill_length_mm="Bill length (mm)", body_mass_g = "Body mass (g)", species='Species'),
                title = "Palmer Penguins")
fig.show()

# %% [markdown]
# You can also specify which variables to include in the hover text, as well as do some formatting

# %%
fig = px.scatter(data_frame=penguins, x='bill_length_mm', y = 'body_mass_g', color = 'species', 
                labels = dict(bill_length_mm="Bill length (mm)", body_mass_g = "Body mass (g)", species='Species'),
                 width=800, height=600,
                title = "Palmer Penguins")
fig.show()

# %% [markdown]
# #### Line plots and time series

# %% [markdown]
# You can generate line plots, stratified line plots and spaghetti plots using Plotly

# %%
gap = px.data.gapminder()
df = gap.query('continent=="Oceania"')
fig = px.line(df, x = 'year', y = 'lifeExp', color = 'country',
             width=800, height=600,
             labels = dict(lifeExp = 'Life expectancy', year='Year'))

fig.show()

# %%
df = gap.query("continent != 'Asia'")
fig = px.line(df, x = 'year', y = 'lifeExp', color = 'continent', line_group = 'country', hover_name='country', 
              height=800, width=800,
              template='presentation',
             labels = dict(lifeExp = 'Life expectancy', year='Year'))
fig.show()

# %% [markdown]
# ### Facets

# %% [markdown]
# Plotly supports facets with pretty much similar syntax as seaborn, except that plotly uses `color` instead of `hue`

# %%
fig = px.line(data_frame = gap, x = 'year', y = 'lifeExp', color = 'country', facet_col='continent', facet_col_wrap=3,
             width=1000, height=500).update_layout(showlegend=False)
fig.show()

# %% [markdown]
# ### Categorical variables

# %% [markdown]
# #### Bar plots

# %%
tips = px.data.tips()
tips.head()

# %%
px.bar(tips, x = 'day', y = 'total_bill',
      width=600, height=600)

# %%
px.bar(tips, x = 'day', y = 'total_bill',
       category_orders={
           'day': ['Thur','Fri','Sat','Sun']
       },
      width=600, height=600)

# %%
px.bar(tips, x = 'day', y = 'total_bill', color='smoker', barmode='group',
       category_orders={
           'day': ['Thur','Fri','Sat','Sun']
       },
      width=600, height=600)

# %%
px.bar(tips, x = 'day', y = 'total_bill', color='smoker', barmode='group', facet_col='sex',
       category_orders={
           'day': ['Thur','Fri','Sat','Sun']
       },
      width=1000, height=600)

# %%
px.bar(tips, x = 'day', y = 'total_bill', color='smoker', barmode='group', facet_col='sex',
       category_orders={
           'day': ['Thur','Fri','Sat','Sun'],
           'sex': ['Male', 'Female'],
           'smoker': ['Yes','No']
       },
      width=1000, height=600)

# %% [markdown]
# ## Statistical plots
#
# ### Histograms and frequency barplots
#
# If you have continuous data you might want to look at a histogram or a density plot to understand the distribution of your data

# %%
tips = px.data.tips()
px.histogram(tips, x='total_bill', nbins=100, histnorm='probability density',
            color_discrete_sequence=['indianred'],
            width=800, height=600)

# %%
px.histogram(tips, x='total_bill', color='sex',
            width=800, height=600)

# %%
px.histogram(tips, x='total_bill', color='sex', marginal='box', # or 'rug' or 'violin'
            width=800, height=600)

# %% [markdown]
# For a categorical variable, the `px.histogram` function produces a frequency bar plot

# %%
tips.columns

# %%
px.histogram(tips, x='day',
            category_orders={'day':['Thur','Fri','Sat','Sun']},
            width=800, height=600)

# %%
(px.histogram(tips, x='day',
            width=800, height=600)
 .update_xaxes(categoryorder='total ascending')) # This part is from the low-level API

# %% [markdown]
# ### Bar plots of values of one variable grouped by categories of another

# %%
(px.histogram(tips, x='day', y='tip', histfunc='avg',
             width=800, height=600)
     .update_xaxes(categoryorder='total ascending')
     .update_layout(yaxis_tickformat='$'))

# %% [markdown]
# ### Distributions of a continuous variable by a categorical variable

# %%
px.box(tips, x='day', y = 'total_bill',
         width=800, height=600)

# %%
px.violin(tips, x='day', y='total_bill',
          width=800, height=600)

# %%
px.strip(tips, x='day', y='total_bill',
        width=800, height=600)

# %%
px.box(tips, x='day', y= 'total_bill', notched=False, title='Box plot', width=800, height=600).update_layout(yaxis_tickformat='$')

# %% [markdown]
# ## 2-d plots

# %%
px.density_heatmap(tips, x='total_bill', y = 'tip',
                  marginal_x='histogram', marginal_y='histogram',
                   color_continuous_scale=px.colors.sequential.Viridis,nbinsx=50, nbinsy=50,
                   labels=dict(total_bill='Total bill', tip='Tip'),
                   title = 'Joint distribution of tip and total bill',
                  width=700, height=600)

# %% [markdown]
# ## Scatterplot matrix

# %%
penguin = sns.load_dataset('penguins')
px.scatter_matrix(penguin, width=1000, height=1000)

# %%
(px.scatter_matrix(penguin,
                 dimensions = ['bill_length_mm','bill_depth_mm','flipper_length_mm','body_mass_g'],
                 color='species',
                 width=1000, height=1000,
                 labels = dict(bill_length_mm='Bill length (mm)',
                              bill_depth_mm = 'Bill depth (mm)',
                              flipper_length_mm = 'Flipper length (mm)',
                              body_mass_g = 'Body mass (g)'))
     .update_traces(diagonal_visible=False))

# %% [markdown]
# ## Parallel coordinates plot

# %%
penguin['species'] = penguin.species.astype('category')
penguin['species_id']=penguin.species.cat.codes

# %%
px.parallel_coordinates(penguin,
                        color='species_id',
            color_continuous_scale=px.colors.diverging.Tealrose)

# %%
px.parallel_categories(penguin.drop('species_id', axis=1))

# %% [markdown]
# #  Maps

# %%
from urllib.request import urlopen
import json
with urlopen('https://raw.githubusercontent.com/plotly/datasets/master/geojson-counties-fips.json') as response:
    counties = json.load(response)


# %%
counties['features'][0]

# %%
df = pd.read_csv("https://raw.githubusercontent.com/plotly/datasets/master/fips-unemp-16.csv",
                   dtype={"fips": str})
df.head()

# %%
px.choropleth(df, geojson=counties, locations='fips', color='unemp', color_continuous_scale=px.colors.sequential.Viridis, range_color=(0,12), scope='usa', labels = {'unemp': 'Unemployment rate'})

# %%
import geopandas as gpd
geo_df = gpd.read_file(gpd.datasets.get_path('nybb')).to_crs('EPSG:4326')

# %%
px.choropleth(geo_df, 
             geojson=geo_df.geometry,
             locations=geo_df.index,
             color='Shape_Leng', 
             hover_name = 'BoroName').update_geos(fitbounds='locations', visible=False)

# %%
df = px.data.gapminder().query("year==2007")
fig = px.choropleth(df, locations="iso_alpha",
                    color="lifeExp", # lifeExp is a column of gapminder
                    hover_name="country", # column to add to hover information
                    color_continuous_scale=px.colors.sequential.Plasma)
fig.show()

# %% [markdown]
# # Machine learning plots

# %%
px.scatter(tips, x='total_bill', y='tip', trendline='lowess', trendline_color_override='darkblue', width=600, height=600)

# %%
import numpy as np
import plotly.graph_objects as go
from sklearn.linear_model import LinearRegression

X = tips.total_bill.values.reshape(-1,1)
model=LinearRegression()
model.fit(X, tips.tip)

# %%
x_range=np.linspace(X.min(), X.max(), 100)
y_range = model.predict(x_range.reshape(-1,1))

px.scatter(tips, x='total_bill',y='tip',opacity=0.65, width=600, height=600).add_traces(go.Scatter(x=x_range, y=y_range, name='Regression Fit'))

# %%
