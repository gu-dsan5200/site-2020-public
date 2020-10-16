library(readr)

original <- read_delim("05/data/dataset1.tds", delim = "\t")

original$NAME

library(dplyr)
library(tidyr)
cleaned_data <- original %>% 
  separate(NAME, 
           c("name", "bp", "mf", "systematic_name", "number"),
           sep = "\\|\\|")


cleaned_data <- original %>% 
  separate(NAME, 
           c("name", "bp", "mf", "systematic_name", "number"),
           sep = "\\|\\|") %>% 
  # mutate_each(funs(trimws), name:systematic_name)
  mutate(across(name:systematic_name, trimws))


cleaned_data <- original %>% 
  separate(NAME, 
           c("name", "bp", "mf", "systematic_name", "number"),
           sep = "\\|\\|") %>% 
  # mutate_each(funs(trimws), name:systematic_name)
  mutate(across(name:systematic_name, trimws)) %>% 
  select(-number, -GID, -YORF, -GWEIGHT) %>% 
  pivot_longer(G0.05:U0.3, names_to = "sample") %>% 
  separate(sample, c("nutrient", "rate"), sep = 1, convert = T)


