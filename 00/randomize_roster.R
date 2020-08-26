# Randomizing objects to roster, within section

library(pacman)
p_load(char = c('tidyverse', 'here'))
roster <- readRDS(here('00','data','roster.rds'))

roster_randomize <- function(roster, objs, seed = 2954){
  set.seed(seed)
  r <- roster %>% 
    mutate(assign = sample(objs, n(), replace=TRUE)) %>% 
    select(uid, assign) %>% 
    arrange(uid)
  return(r)
}
