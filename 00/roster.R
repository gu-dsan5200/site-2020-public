# Creating roster data and framework for 
# randomized data selection by student

library(pacman)
p_load(char = c('tidyverse', 'here', 'readxl'))

roster <- read_excel('~/Downloads/2020-08-25T1152_Grades-ANLY-503-01.xlsx') %>% 
  slice(-1) %>% 
  janitor::clean_names() %>% 
  filter(student !='Test Student') %>% 
  extract(section, 'section', regex='ANLY-503-(\\d{2})') %>% 
  select(student, sis_user_id, section) %>% 
  mutate(email = paste0(sis_user_id, '@georgetown.edu'))

