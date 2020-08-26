# Randomizing objects to roster, within section

library(pacman)
p_load(char = c('tidyverse', 'here'))
roster <- readRDS(here::here('00','data','roster.rds'))

#' roster_randomize: randomizing objects among students
#' 
#' This function takes a roster of students, where 
#' the IDs are stored in the column `uid`, and randomly
#' assigns an object from a list of objects to each student
#'
#' @param roster A data.frame containing the IDs of students
#' @param objs A vector of object names
#' @param seed Optional specification of the seed of the random number generator
#'
#' @return A data.frame containing the IDs of students and their assigned object
#' @export
#'
#' @examples
#' roster_randomize(roster, c('dat1','dat2','dat3))
roster_randomize <- function(roster, objs, seed = 2954){
  require(dplyr)
  set.seed(seed)
  r <- roster %>% 
    mutate(assign = sample(objs, n(), replace=TRUE)) %>% 
    select(uid, assign) %>% 
    arrange(uid)
  return(r)
}
