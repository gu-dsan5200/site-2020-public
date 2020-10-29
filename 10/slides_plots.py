#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 28 01:50:28 2020

@author: abhijit
"""


import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdate
import matplotlib.ticker as mtick
import seaborn as sns
import pyplot_themes as themes
from statsmodels.nonparametric.smoothers_lowess import lowess

themes.theme_ucberkeley()
#%%

d = pd.read_csv('data/line_plot_ex.csv')
d['date'] = d.date.astype('datetime64')

# Easier to work with wide data 
d1 = d.pivot(index='date', columns='company', values='price').reset_index()
low1 = lowess(d1.GD, d1.date, frac=0.1)
low2 = lowess(d1.MSFT, d1.date, frac=0.1)
d1['GD_smooth'] = low1[:,1]
d1['MSFT_smooth'] = low2[:,1]

#%%
fig, ax = plt.subplots(1,1,figsize=(10,5))
ax.xaxis.set_major_formatter(mdate.DateFormatter('%b, %Y'))
ax.yaxis.set_major_formatter(mtick.StrMethodFormatter('${x:.0f}'))
d1.plot(x='date', y = 'GD', color = 'blue', kind='scatter', ax=ax, label='GD')
d1.plot(x='date', y = 'MSFT', color='orange', kind='scatter', ax=ax, label='MSFT')
ax.set_ylabel('Price')
ax.legend(loc='upper left', ncol=2, edgecolor='lightblue', title='Company')
plt.show()


#%%
fig, ax = plt.subplots(1,1,figsize=(10,5))
ax.xaxis.set_major_formatter(mdate.DateFormatter('%b, %Y'))
ax.yaxis.set_major_formatter(mtick.StrMethodFormatter('${x:.0f}'))
d1.plot(x='date', y = 'GD', color = 'blue', kind='line', ax=ax, label='GD')
d1.plot(x='date', y = 'MSFT', color='orange', kind='line', ax=ax, label='MSFT')
ax.set_ylabel('Price')
ax.legend(loc='upper left', ncol=2, edgecolor='lightblue', title='Company')
plt.show()

#%%
fig, ax = plt.subplots(1,1,figsize=(10,5))
ax.xaxis.set_major_formatter(mdate.DateFormatter('%b, %Y'))
ax.yaxis.set_major_formatter(mtick.StrMethodFormatter('${x:.0f}'))
d1.plot(x='date', y = 'GD', color = 'blue', kind='scatter', alpha=0.3, ax=ax)
d1.plot(x='date', y = 'MSFT', color='orange', kind='scatter', alpha=0.3, ax=ax)
d1.plot(x='date', y = 'GD_smooth', color = 'blue', kind='line', ax=ax, 
    linewidth=5, label='GD')
d1.plot(x='date', y = 'MSFT_smooth', color='orange', kind='line', ax=ax, 
    linewidth=5, label='MSFT')
ax.set_ylabel('Price')
ax.legend(loc='upper left', ncol=2, edgecolor='lightblue', title='Company')
#ax.get_legend().remove()
plt.show()

#%%

covid = pd.read_csv('data/covid_plot_data.csv').fillna(0)
covid['date'] = covid.date.astype('datetime64')
covid.drop('highlight', axis=1, inplace=True)
covid1=(covid
     .pivot(index='date', columns='id', values='deaths')
     .reset_index())
countries = covid1.columns[2:]
highlight_countries = ['USA','GBR','SWE','JPN']
fig, ax = plt.subplots(1,1, figsize=(10,5))
ax.xaxis.set_major_formatter(mdate.DateFormatter('%b, %Y'))
for u in countries:
    if u in set(highlight_countries):
        covid1.plot(x='date', y=u, color = 'orange', ax=ax)
    else:
        covid1.plot(x='date', y=u, color='lightgrey', ax=ax)

ax.get_legend().remove()
ax.set_xlabel('')
plt.show()

#plt.yscale('log')

#%% Area plot

import world_bank_data as wb

wbd = wb.get_series('NY.GDP.MKTP.KD.ZG', date='2000:2019', id_or_value='id', simplify_index=True).reset_index()
jpn_data = wbd[wbd.Country=='JPN']

jpn_data.plot(x = 'Year', y = 'NY.GDP.MKTP.KD.ZG', 
    kind='line')

jpn_data.plot(x='Year', y='NY.GDP.MKTP.KD.ZG',
    kind='area', stacked=False, legend=False)

#%% Streamgraph

covid2 = covid.groupby(id)
covid2['daily'] = covid2.deaths - covid2.deaths.shift(1)
