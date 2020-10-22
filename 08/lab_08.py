# ## Setup

# **Load packages**

import pandas as pd
import matplotlib.pyplot as plt
import geopandas as gp
import pyarrow
# %matplotlib inline

# **Load data**

accidents = pd.read_feather('data/accidents.feather')
abbrevs = pd.read_csv('data/state_abbrevs.csv')

us_states = gp.read_file('/Users/abhijit/Downloads/tl_2019_us_state.shp')
us_counties = gp.read_file('/Users/abhijit/Downloads/tl_2019_us_county.shp')


# **Data  munging**

us_counties = (us_counties
              .merge(us_states[['STATEFP','NAME']], how='left',
                    left_on='STATEFP',right_on='STATEFP')
              .rename(columns = {'NAME_x':'county_name','NAME_y':'state_name'}))
us_counties = us_counties.to_crs(epsg=4326)

accidents['year'] = pd.DatetimeIndex(accidents['start_time']).year
accidents['month'] = pd.DatetimeIndex(accidents['start_time']).month
accidents_19 = accidents[accidents.year==2019]
accidents.shape

# ## Plotting accidents by state

by_state = (accidents_19.state
     .value_counts().reset_index()
     .merge(abbrevs, how='left', left_on='index', right_on='Abbreviation')
     .merge(us_states, how='left', left_on='US.State', right_on='NAME')
     )

by_state = gp.GeoDataFrame(by_state)

by_state.plot();

by_state.plot(column='state');

by_state.plot(column='state',
             cmap='plasma');

by_state.plot(column='state',
             cmap='plasma',
             legend=True);

from mpl_toolkits.axes_grid1 import make_axes_locatable
fig, ax= plt.subplots(1,1)
divider = make_axes_locatable(ax)

cax = divider.append_axes('right', size='5%', pad=0.1)

by_state.plot(column='state',
             cmap='plasma',
             legend=True,
             ax=ax, 
             cax=cax);


fig, ax = plt.subplots(1,1)
by_state.plot(column='state',
             cmap='plasma',
             legend=True,
             ax = ax,
             legend_kwds={'label': "Accidents by state",
                         "orientation" : "horizontal"});


# ## Dot map

acc_19_md = accidents_19.query('state=="MD"')
acc_19_md = gp.GeoDataFrame(acc_19_md, 
                           geometry=gp.points_from_xy(acc_19_md.start_lng,
                                                      acc_19_md.start_lat,
                                                     crs=4326))

# _Using transparency_

fig, ax = plt.subplots(1,1)
acc_19_md.plot(ax = ax, column='severity', alpha=0.3, s = 1);
us_counties.query('state_name=="Maryland"').plot(ax=ax,color='white', 
                                                 edgecolor='black', alpha=0.2);


# _Changing layers_

fig, ax = plt.subplots(1,1)
us_counties.query('state_name=="Maryland"').plot(ax=ax,color='white', 
                                                 edgecolor='black')
acc_19_md.plot(ax = ax, column='severity', alpha=0.3, s = 1,
              cmap = 'YlOrBr',
               legend=True);


