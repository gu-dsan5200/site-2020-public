library(pacman)
p_load(char = c('arrow','tidyverse','sf','tmap','tmaptools',
                'USAboundaries','tigris','rnaturalearth','osmar'))

d1 <- arrow::read_feather('data/accidents.feather')
