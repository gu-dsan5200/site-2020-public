library(tidyverse)
library(janitor)
library(lubridate)
library(sf)
library(sf)
library(tidyverse)
library(tigris)
library(tidycensus)
options(tigris_use_cache=TRUE)
options(tigris_class="sf")
fips_state='24'; fips_county='031'
state_county <- tigris::counties(state = fips_state)
county <- state_county %>% filter(COUNTYFP == fips_county)


md_crime <- read_csv('~/Downloads/Crime.csv')
md_crime <- md_crime %>% clean_names() %>% 
  mutate(start_date_time = as_datetime(start_date_time,
                                       format="%m/%d/%Y %H:%M:%S %p")) %>% 
  mutate(year = year(start_date_time))
md_crime_19 <- md_crime %>% filter(year==2018) %>% 
  mutate(longitude = na_if(longitude,0),
         latitude = na_if(latitude, 0)) %>% 
  filter(!is.na(latitude)) %>% 
  st_as_sf(coords=c('longitude','latitude'), crs=4326, remove=FALSE )

library(USAboundaries)
md_map <- us_counties(states='MD')

ggplot()+
  geom_sf(data=md_map, aes(geometry=geometry))+
  geom_sf(data=md_crime_19)
  geom_density_2d(data = md_crime_19, 
                  aes(x = longitude, y = latitude))
