#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct  8 21:12:53 2020

@author: abhijit
"""

#%% setup

import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import pyarrow as pa
import pyreadr as pr # pip install pyreadr
import requests
import seaborn as sns

#%% Download files if needed 

if os.path.exists('data/accidents.feather') is False:
    acc_url = "https://bigdatateaching.blob.core.windows.net/public/us-traffic-accidents/accidents.feather"
    myfile = requests.get(acc_url)
    open('data/accidents.feather').write(myfile.content)

if os.path.exists('data/skim_summary.rds') is False:
    acc_summ_url = "https://bigdatateaching.blob.core.windows.net/public/us-traffic-accidents/skim_summary.rds"
    myfile = requests.get(acc_summ_url)
    open('data/skim_summary.rds','wb').write(myfile.content)

#%% Read data

acc = pd.read_feather('data/accidents.feather')
skim_summary = pr.read_r('data/skim_summary.rds')[None]

#%% Data munging

acc['duration'] = acc.end_time - acc.start_time
acc['year'] = acc.start_time.dt.year
acc['hour'] = acc.start_time.dt.hour
acc['day'] =acc.start_time.dt.weekday # (0 = Monday, 7 = Sunday)
acc['weekend'] = (acc['day'] < 5)

#%%

skim_summary = skim_summary.sort_values(['skim_variable']).reset_index(drop=True)
sns.barplot(data=skim_summary, x = "skim_variable", y = 'n_missing');
plt.xticks(rotation=45, horizontalalignment='right', fontsize='small')

sns.barplot(data=skim_summary, x='skim_variable', y = 'n_missing', hue='skim_type')
plt.xticks(rotation=45, horizontalalignment='right', fontsize='small')

#%% missing data for numeric veriables in descending order

skim_numeric = skim_summary.query("skim_type=='numeric'")
skim_numeric = skim_numeric.sort_values(['n_missing'], ascending=False)
sns.barplot(data=skim_numeric, x = 'skim_variable', y = 'n_missing')
plt.xticks(rotation=45, horizontalalignment='right', fontsize='small')

#%%
from  matplotlib.ticker import PercentFormatter

acc_numeric = acc.select_dtypes(include=np.number).drop(['duration','day','year','hour'], axis=1)
pct_missing_numeric = acc_numeric.isnull().mean()
d = pd.DataFrame({'pct':pct_missing_numeric}).reset_index()
d = d.sort_values(['pct'], ascending=False)
g = sns.barplot(data=d, x = 'index', y = 'pct', color='grey')
g.axes.yaxis.set_major_formatter(PercentFormatter(1))
plt.xticks(rotation=45, horizontalalignment='right', fontsize='small')
plt.xlabel('Variable Name')
plt.ylabel('Percent')
plt.title('Percent of missing values for numerical variables')

#%%
ignore_fields = ['end_lat','end_lng','number']

d1 = d[~d['index'].isin(ignore_fields)]
g = sns.barplot(data=d1, x = 'index', y = 'pct',color='grey')
g.axes.yaxis.set_major_formatter(PercentFormatter(1))
plt.xticks(rotation=45, horizontalalignment='right', fontsize='small')
plt.xlabel('Variable Name')
plt.ylabel('Percent')
plt.ylim(0,1)
plt.title('Percent of missing values for numerical variables')

#%%

skim_summary['prop_missing'] = skim_summary.n_missing/acc.shape[0]
skim_summary = skim_summary.sort_values(['prop_missing'], ascending=False)
g = sns.catplot(data = skim_summary,
            x = "skim_variable", 
            y = 'prop_missing',
            row = 'skim_type',
            kind = 'bar',
            height=3, aspect=3)
for ax in g.axes.flat:
    ax.yaxis.set_major_formatter(PercentFormatter(1))

plt.xticks(rotation=45, horizontalalignment='right', fontsize='small')
plt.xlabel('Variable Name')
plt.ylabel('Percent')
plt.ylim(0,1)

#%%

def plot_type(d, var_type, axs):
    d = d.query('skim_type=="'+var_type+'"')
    d = d.sort_values(['prop_missing'],ascending=False)
    g = sns.barplot(data=d, x = 'skim_variable', 
                    y = 'prop_missing',color='grey',
                    ax = axs)
    g.axes.yaxis.set_major_formatter(PercentFormatter(1))


fig, axs = plt.subplots(nrows=4, ncols=1, figsize = (10,10))
fig.subplots_adjust(hspace=1.5)
for i,var in enumerate(skim_summary.skim_type.unique()):
    plot_type(skim_summary, var, axs[i])
    axs[i].set_xlabel(''); axs[i].set_ylabel('')
    axs[i].set_title(var)
    axs[i].tick_params(labelrotation=45)


#%% There is no easy or good way to do alluvial plots in Python
