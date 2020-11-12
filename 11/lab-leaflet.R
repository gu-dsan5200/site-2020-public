# https://www.earthdatascience.org/courses/earth-analytics/get-data-using-apis/leaflet-r/


library(dplyr)
library(ggplot2)
library(rjson)
library(jsonlite)
library(leaflet)
library(RCurl)


r_birthplace_map <- leaflet() %>%
  addTiles() %>%  # use the default base map which is OpenStreetMap tiles
  addMarkers(lng=174.768, lat=-36.852,
             popup="The birthplace of R")
r_birthplace_map

base_url <- "https://data.colorado.gov/resource/j5pc-4t32.json?"
full_url <- paste0(base_url, "station_status=Active",
            "&county=BOULDER")
water_data <- getURL(URLencode(full_url))

water_data_df <- rjson::fromJSON(water_data) %>%
  flatten(recursive = TRUE) # remove the nested data frame

# turn columns to numeric and remove NA values
water_data_df <- water_data_df %>%
  mutate_at(vars(amount, location.latitude, location.longitude), funs(as.numeric)) %>%
  filter(!is.na(location.latitude))
