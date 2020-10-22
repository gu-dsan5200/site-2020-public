## setup
## 
library(pacman)
p_load(char = c('arrow','tidyverse','sf','tmap','tmaptools',
                'USAboundaries','tigris','rnaturalearth','osmar',
                'lubridate'))

accidents <- arrow::read_feather('data/accidents.feather')
accidents_19 <- accidents %>% 
  mutate(year = year(start_time),
         month = month(start_time),
         hour = hour(start_time)) %>% 
  filter(year==2019)

## Data munging

accidents_19_sf <- accidents_19 %>% 
  st_as_sf(coords = c('start_lng','start_lat'), 
           crs = 4326) %>% 
  rename(geom_acc = geometry)
us_map <- USAboundaries::us_states()

acc_for_maps <- accidents %>% 
  select(severity, start_time, start_lng, start_lat, 
         description, state, zipcode, timezone, weather_timestamp:weather_condition) %>% 
  left_join(us_map, by = c('state'='state_abbr'))

## Plotting slices

### Choropleth of number of accidents by state

accidents_19 %>% 
  count(state, month) %>% 
  group_by(state) %>% 
  mutate(prop = 100*n/sum(n)) %>% 
  ungroup() %>% 
  left_join(us_map, by=c('state'='state_abbr'))-> bl

ggplot(bl %>% filter(month %in% c(1,4,9,12)))+
  geom_sf(aes(geometry=geometry, fill=prop))+
  facet_wrap(~month, ncol=2)+
  scale_fill_viridis_c()

ggplot(bl %>% filter(month==6))+
  geom_sf(aes(geometry=geometry, fill=prop))

accidents_19 %>% count(state, severity) %>% 
  group_by(state) %>% 
  mutate(prop = n/sum(n)*100) %>% 
  ungroup() %>% 
  left_join(us_map, by=c('state'='state_abbr'))-> acc_severity

ggplot(acc_severity)+
  geom_sf(aes(geometry=geometry, fill = prop))+
  facet_wrap(~severity) +
  scale_fill_viridis_c()

accidents_19 %>% 
  filter(state=='MD') %>% 
  st_as_sf(coords = c('start_lng','start_lat'), 
           crs = 4326) -> acc_19_md
ggplot(acc_19_md)+
  geom_sf(data=us_counties(states='MD'), aes(geometry=geometry))+
  geom_sf(aes(geometry=geometry, color=severity, fill=severity), 
          size=0.2, alpha=0.4)


counties2 <- sf::st_read('~/Downloads/tl_2019_us_county.shp')
