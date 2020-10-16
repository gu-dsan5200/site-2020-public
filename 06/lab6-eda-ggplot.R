library(tidyverse)
# system.time() values were calculated on 2016 
# MacBook Pro (15-inch, 2016)
# 2.9 GHz Quad-Core Intel Core i7
# 16 GB 2133 MHz LPDDR3
#os       macOS Catalina 10.15.6      
# system   x86_64, darwin17.0          


set.seed(1000)
circle <- tibble(x = runif(10000, -1, 1),
                 y = runif(10000, -1, 1)) %>% 
  mutate(dist = sqrt((x^2) + (y^2))) %>% 
  mutate(quadrant = ifelse(x >= 0,
                           ifelse(y >= 0, "I", "IV"),
                           ifelse(y >= 0, "II", "III")),
         angle = atan(y/x) / (pi / 180),
         angle = case_when(
           quadrant == "I" ~ angle,
           quadrant == "II" ~ 180 + angle,
           quadrant == "III" ~ 180 + angle,
           quadrant == "IV" ~ 360 + angle
         ),
         in_unit_circle = dist <= 1,
         in_pacman = angle >= 30 & angle <= 330)
)

ggplot(circle) +
  geom_point(aes(x = x, y = y)) +
  coord_equal()


circle %>% 
  filter(in_unit_circle) %>% 
  ggplot() +
  geom_point(aes(x = x, y = y)) +
  coord_equal()

  


#' Instead of mapping an aesthetic property to a variable, you can set it to a single value by specifying it in the layer parameters. We map an aesthetic to a variable (e.g., aes(colour = cut)) or set it to a constant (e.g., colour = "red"). If you want appearance to be governed by a variable, put the specification inside aes(); if you want override the default size or colour, put the value outside of aes().
The following plots are created with similar code, but have rather different outputs. The second plot maps (not sets) the colour to the value ‘darkblue’. This effectively creates a new variable containing only the value ‘darkblue’ and then scales it with a colour scale. Because this value is discrete, the default colour scale uses evenly spaced colours on the colour wheel, and since there is only one value this colour is pinkish.

head(luv_colours)

ggplot(luv_colours, aes(x =u, y = v)) +
  geom_point(aes(color = col)) +
  scale_color_identity() +
  coord_equal()



data_url <- "https://bigdatateaching.blob.core.windows.net/public/us-traffic-accidents/US_Accidents_June20.csv"
raw <- read_csv(data_url)

# Parsed with column specification:
# cols(
#   .default = col_character(),
#   TMC = col_double(),
#   Severity = col_double(),
#   Start_Time = col_datetime(format = ""),
#   End_Time = col_datetime(format = ""),
#   Start_Lat = col_double(),
#   Start_Lng = col_double(),
#   End_Lat = col_logical(),
#   End_Lng = col_logical(),
#   `Distance(mi)` = col_double(),
#   Number = col_double(),
#   Weather_Timestamp = col_datetime(format = ""),
#   `Temperature(F)` = col_double(),
#   `Wind_Chill(F)` = col_double(),
#   `Humidity(%)` = col_double(),
#   `Pressure(in)` = col_double(),
#   `Visibility(mi)` = col_double(),
#   `Wind_Speed(mph)` = col_double(),
#   `Precipitation(in)` = col_double(),
#   Amenity = col_logical(),
#   Bump = col_logical()
#   # ... with 11 more columns
# )
# See spec(...) for full column specifications.
# |=============================================================================| 100% 1265 MB
# Warning: 2069844 parsing failures.
#     row     col           expected    actual                                                                                                file
# 2478819 End_Lat 1/0/T/F/TRUE/FALSE 40.11206  'https://bigdatateaching.blob.core.windows.net/public/us-traffic-accidents/US_Accidents_June20.csv'
# 2478819 End_Lng 1/0/T/F/TRUE/FALSE -83.03187 'https://bigdatateaching.blob.core.windows.net/public/us-traffic-accidents/US_Accidents_June20.csv'
# 2478820 End_Lat 1/0/T/F/TRUE/FALSE 39.86501  'https://bigdatateaching.blob.core.windows.net/public/us-traffic-accidents/US_Accidents_June20.csv'
# 2478820 End_Lng 1/0/T/F/TRUE/FALSE -84.04873 'https://bigdatateaching.blob.core.windows.net/public/us-traffic-accidents/US_Accidents_June20.csv'
# 2478821 End_Lat 1/0/T/F/TRUE/FALSE 39.10209  'https://bigdatateaching.blob.core.windows.net/public/us-traffic-accidents/US_Accidents_June20.csv'
# ....... ....... .................. ......... ........................................................... [... truncated]

#echo = TRUE

col_mapping <- cols(
  ID = col_character(),
  Source = col_character(),
  TMC = col_double(),
  Severity = col_double(),
  Start_Time = col_datetime(format = ""),
  End_Time = col_datetime(format = ""),
  Start_Lat = col_double(),
  Start_Lng = col_double(),
  End_Lat = col_double(),
  End_Lng = col_double(),
  `Distance(mi)` = col_double(),
  Description = col_character(),
  Number = col_double(),
  Street = col_character(),
  Side = col_character(),
  City = col_character(),
  County = col_character(),
  State = col_character(),
  Zipcode = col_character(),
  Country = col_character(),
  Timezone = col_character(),
  Airport_Code = col_character(),
  Weather_Timestamp = col_datetime(format = ""),
  `Temperature(F)` = col_double(),
  `Wind_Chill(F)` = col_double(),
  `Humidity(%)` = col_double(),
  `Pressure(in)` = col_double(),
  `Visibility(mi)` = col_double(),
  Wind_Direction = col_character(),
  `Wind_Speed(mph)` = col_double(),
  `Precipitation(in)` = col_double(),
  Weather_Condition = col_character(),
  Amenity = col_logical(),
  Bump = col_logical(),
  Crossing = col_logical(),
  Give_Way = col_logical(),
  Junction = col_logical(),
  No_Exit = col_logical(),
  Railway = col_logical(),
  Roundabout = col_logical(),
  Station = col_logical(),
  Stop = col_logical(),
  Traffic_Calming = col_logical(),
  Traffic_Signal = col_logical(),
  Turning_Loop = col_logical(),
  Sunrise_Sunset = col_character(),
  Civil_Twilight = col_character(),
  Nautical_Twilight = col_character(),
  Astronomical_Twilight = col_character()
)

system.time(
raw <- read_csv(data_url,
                col_types = col_mapping)
)
 #   user  system elapsed 
 # 66.985  11.341  87.882 

raw %>% glimpse()

# clean names
library(janitor)
acc <- raw %>% clean_names()            
  
library(skimr)
# creates a skim_df
system.time(
  skim_summary <- skim(raw)
)
#   user  system elapsed 
# 76.394  11.119  88.403 

# change tmc to character, remove turning loop, country
acc <- acc %>% 
  mutate(tmc = as.character(tmc))

system.time(
skim_summary <- acc %>% 
  select(-id, -tmc, -country, -turning_loop) %>% 
  skim()
)
 #   user  system elapsed 
 # 80.489  12.404  96.708 

library(visdat)

system.time(
vis_dat(acc, warn_large_data = F)
)
# too slow for large datasets


# Visualizing Summaries

# lets make a bar plot to show the values of n_missing for all variables
skim_summary %>% 
  ggplot() +
  geom_bar(aes(x = skim_variable,
               y = n_missing))


# ugh, error... why?

skim_summary %>% 
  ggplot() +
  geom_bar(aes(x = skim_variable,
               y = n_missing), 
           stat = "identity")

skim_summary %>% 
  arrange(desc(n_missing)) %>% 
  ggplot() +
  geom_bar(aes(x = skim_variable, 
               y = n_missing), 
           stat = "identity")

skim_summary %>% 
  ggplot() +
  geom_bar(aes(x = reorder(skim_variable, -n_missing), 
               y = n_missing),
           stat = "identity")


skim_summary %>% 
  ggplot() +
  geom_bar(aes(x = reorder(skim_variable, -n_missing), 
               y = n_missing,
               fill = skim_type),
           stat = "identity") +
  scale_fill_brewer(palette = "Set1") +
  facet_grid(skim_type ~ ., drop = T)
#b (binned), c (continuous), d (discrete)

skim_summary %>% 
  ggplot() +
  geom_bar(aes(x = reorder(skim_variable, -n_missing), 
               y = n_missing,
               fill = skim_type),
           stat = "identity") +
  scale_fill_brewer(palette = "Set1") +
  facet_grid(. ~ skim_type, drop = F)



skim_summary %>% 
  ggplot() +
  geom_bar(aes(x = reorder(skim_variable, -n_missing), 
               y = n_missing,
               fill = skim_type),
           stat = "identity") +
  scale_fill_viridis_d(option = "plasma")
#b (binned), c (continuous), d (discrete)





# Let's focus on the quantitative variables
acc %>% 
  select(-id, -tmc, -country, -turning_loop) %>% 
  select_if(is.numeric)






# Accidents per hour




library(tableone)
system.time(
table_one <- CreateTableOne(data = raw)
)
#   user  system elapsed 
# 89.507   9.241  99.622 



skim_summary
