# https://www.earthdatascience.org/courses/earth-analytics/get-data-using-apis/leaflet-r/


library(dplyr)
library(ggplot2)
#library(rjson)
library(jsonlite)
library(leaflet)
library(RCurl)
library(jsonlite)

r_birthplace_map <- leaflet() %>%
  addTiles() %>%  # use the default base map which is OpenStreetMap tiles
  addMarkers(lng=174.768, lat=-36.852,
             popup="The birthplace of R")
r_birthplace_map

base_url <- "https://data.colorado.gov/resource/j5pc-4t32.json?"
full_url <- paste0(base_url, "station_status=Active",
            "&county=BOULDER")
water_data <- getURL(URLencode(full_url))

water_data_df <- jsonlite::fromJSON(water_data, flatten = TRUE) 

# turn columns to numeric and remove NA values
water_data_df <- water_data_df %>%
  mutate(across(c(amount, location.latitude, location.longitude), as.numeric)) %>% 
  filter(!is.na(location.latitude))

# create leaflet map
water_locations_map <- leaflet(water_data_df) %>%
  addTiles() %>%
  addCircleMarkers(lng = ~location.longitude,
                   lat = ~location.latitude)

# Same code as above but without using pipes (we like pipes better)
water_locations_map <- leaflet(water_data_df)
water_locations_map <- addTiles(water_locations_map)
water_locations_map <- addCircleMarkers(water_locations_map, lng = ~location.longitude,
                        lat = ~location.latitude)
water_locations_map


# customize leaflet map
leaflet(water_data_df) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addMarkers(lng = ~location.longitude, lat = ~location.latitude,
             popup = ~station_name)

# Specify custom icon
url <- "http://tinyurl.com/jeybtwj"
water <- makeIcon(url, url, 24, 24)

map <- leaflet(water_data_df) %>%
  addProviderTiles("Stamen.Terrain") %>%
  addMarkers(lng = ~location.longitude, lat = ~location.latitude, icon=water,
             popup = ~paste0(station_name,
                           "<br/>Discharge: ",
                           amount))

library(htmlwidgets)
saveWidget(widget=map,
           file="water_map3.html",
           selfcontained=TRUE)


pal <- colorFactor(c("navy", "red", "green"),
                   domain = unique(water_data_df$station_type))
unique_markers_map_2 <- leaflet(water_data_df) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addCircleMarkers(
    color = ~pal(station_type),
    stroke = FALSE, fillOpacity = 0.5,
    lng = ~location.longitude, lat = ~location.latitude,
    label = ~as.character(station_type)
  )


water_data_df$station_type <- factor(water_data_df$station_type)

new <- c("red", "green","blue")[water_data_df$station_type]

icons <- awesomeIcons(
  icon = 'ios-close',
  iconColor = 'black',
  library = 'ion',
  markerColor = new
)

unique_markers_map <- leaflet(water_data_df) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addAwesomeMarkers(lng=~location.longitude, lat=~location.latitude, icon=icons,
                    popup=~station_name,
                    label=~as.character(station_name))

unique_markers_map

saveWidget(widget = unique_markers_map,
           file = "water_map_unique_markers1.html",
           selfcontained = TRUE)

