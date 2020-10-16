library(sf)
library(tidyverse)
library(tigris)
library(tidycensus)
options(tigris_use_cache=TRUE)
options(tigris_class="sf")

fips_state='24'; fips_county='031'

acs <- get_acs("tract", table = "B15003", cache_table = TRUE,
               geometry = TRUE, state = fips_state, county = fips_county,
               year = 2017, output = "tidy")

acs <- acs %>%
  mutate(
    id = str_extract(variable, "[0-9]{3}$") %>% as.integer
  ) %>%
  # variable 1 is the "total", which is just the sum of the others
  filter(id > 1) %>%
  mutate(education =case_when(
    id %>% between(2, 16) ~ "No HS diploma",
    id %>% between(17, 21) ~ "HS, no Bachelors",
    id == 22 ~ "Bachelors",
    id > 22 ~ "Post-Bachelors"
  )) %>%
  group_by(GEOID, education) %>%
  summarise(estimate = sum(estimate))

acs_split <- acs %>%
  filter(estimate > 50) %>%
  split(.$education)

generate_samples <- function(data)
  suppressMessages(st_sample(data, size = round(data$estimate / 100)))

points <- map(acs_split, generate_samples)
points <- imap(points,
               ~st_sf(data_frame(education = rep(.y, length(.x))),
                      geometry = .x))
points <- do.call(rbind, points)

points <- points %>% group_by(education) %>% summarise()
points <- points %>%
  mutate(education = factor(
    education,
    levels = c("No HS diploma", "HS, no Bachelors",
               "Bachelors", "Post-Bachelors")))
# view how many points are in each layer
# points %>% mutate(n_points = map_int(geometry, nrow))
water <- tigris::area_water(fips_state, fips_county)
towns <- tigris::county_subdivisions(fips_state, county = fips_county)
county_roads <- tigris::roads(fips_state, fips_county)
state_county <- tigris::counties(state = fips_state)
county <- state_county %>% filter(COUNTYFP == fips_county)

town_labels <- towns %>% select(NAME) %>%
  mutate(center = st_centroid(geometry)) %>%
  as.tibble %>%
  mutate(center = map(center, ~st_coordinates(.) %>%
                        as_data_frame)) %>%
  select(NAME, center) %>% unnest()

ggplot() +
  geom_sf(data=county, fill=NA, size=0.1) +
  geom_sf(data=points, aes(color=education,fill=education), size=0.2)+
  geom_sf(data=county_roads %>% filter(RTTYP %in% c('I','S')), size=0.2, color = 'gray40')+
  scale_color_brewer(type='div', palette=4)+
  scale_fill_brewer(type='div',palette=4)+
  # ggrepel::geom_label_repel(
  #   data=town_labels,
  #   aes(x=X, y=Y, label=NAME),
  #   size=3,
  #   label.padding = unit(.1, 'lines'), alpha=0.7
  # )+
  labs(x='', y='',
       fill='Education', color = 'Education',
       title=county$NAMELSAD , subtitle='One dot equals 100 people',
       caption='American Community Survey, 2014-2018') +
  theme_light()
 ggsave(here::here('slides','lectures','img','dot_density.png'))
