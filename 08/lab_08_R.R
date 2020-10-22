# ## Setup

library(pacman)
p_load(char = c('arrow','tidyverse','sf','tmap','tmaptools',
                'USAboundaries','tigris','rnaturalearth','osmar',
                'lubridate'))
options(warn=-1)

accidents <- arrow::read_feather('data/accidents.feather')


# ## Data munging

accidents_19 <- accidents %>% 
  mutate(year = year(start_time),
         month = month(start_time),
         hour = hour(start_time)) %>% 
  filter(year==2019)

accidents_19_sf <- accidents_19 %>% 
  st_as_sf(coords = c('start_lng','start_lat'), 
           crs = 4326) %>% 
  rename(geom_acc = geometry)
us_map <- USAboundaries::us_states()


# ## Number of accidents by state


accidents_19 %>% count(state) %>% 
  left_join(us_map %>% select(state_abbr, geometry), by=c('state'='state_abbr')) %>% 
  ggplot()+
#  geom_sf(aes(fill=n, geometry=geometry))+
  geom_sf(aes(geometry=geometry))+
  labs(title='Number of accidents, 2019')

# ### Dot map of Maryland accidents

accidents_19 %>% 
  filter(state=='MD') %>% 
  st_as_sf(coords = c('start_lng','start_lat'), 
           crs = 4326) -> acc_19_md


ggplot(acc_19_md)+
  geom_sf(data=us_counties(states='MD'), aes(geometry=geometry))+
  geom_sf(aes(geometry=geometry, color=severity, fill=severity), 
          size=0.2, alpha=0.4) +
  theme_void()


acc_19_md <-
    acc_19_md %>% bind_cols(as.data.frame(st_coordinates(acc_19_md)))

ggplot(acc_19_md)+
  geom_sf(data=us_counties(states='MD'), aes(geometry=geometry))+
  geom_sf(aes(geometry=geometry, color=severity, fill=severity), 
          size=0.2, alpha=0.4) +
  geom_density2d(aes(x=X,y=Y), bins=30)+
  theme_void()

accidents_19 %>% 
    st_as_sf(coords = c('start_lng','start_lat'), 
           crs = 4326) %>%
    ggplot()+
    geom_sf(aes(geometry=geometry, color=severity), size=0.2, alpha=0.3)


