# https://andrewpwheeler.com/2020/08/31/notes-on-making-leaflet-maps-in-r/

##########################################################
#This code creates a nice leaflet map of my DBSCAN areas

library(rgdal)       #read in shapefiles
library(sp)          #spatial objects
library(leaflet)     #for creating interactive maps
library(htmlwidgets) #for exporting interactive maps

#will need to change baseLoc if replicating on your machine
baseLoc <-
  "D:\\Dropbox\\Dropbox\\Documents\\BLOG\\leaflet_R_examples\\Analysis"
setwd(baseLoc)
##########################################################

##########################################################
#Get the boundary data and DBSCAN data
boundary <-
  readOGR(dsn = "Dallas_MainArea_Proj.shp", layer = "Dallas_MainArea_Proj")
dbscan_areas <- readOGR(dsn = "db_scan.shp", layer = "db_scan")

#Now convert to WGS
DalLatLon <- spTransform(boundary, CRS("+init=epsg:4326"))
DallLine <-
  as(DalLatLon, 'SpatialLines') #Leaflet useful for boundaries to be lines instead of areas
dbscan_LatLon <- spTransform(dbscan_areas, CRS("+init=epsg:4326"))

#Quick and Dirty plot to check
plot(DallLine)
plot(dbscan_LatLon, add = TRUE, col = 'blue')
##########################################################

##########################################################
#Function for labels

#read in data
crime_stats <-
  read.csv('ClusterStats_wlen.csv', stringsAsFactors = FALSE)
dbscan_stats <- crime_stats[crime_stats$type == 'DBSCAN', ]
dbscan_stats$clus_id <-
  as.numeric(dbscan_stats$AreaStr) #because factors=False!

#merge into the dbscan areas
dbscan_LL <- merge(dbscan_LatLon, dbscan_stats)

LabFunct <- function(data, vars, labs) {
  n <- length(labs)
  add_lab <- paste0("<strong>", labs[1], "</strong>", data[, vars[1]])
  for (i in 2:n) {
    add_lab <-
      paste0(add_lab, "<br><strong>", labs[i], "</strong>", data[, vars[i]])
  }
  return(add_lab)
}

#create labels
vs <- c('AreaStr', 'val_th', 'PAI_valth_len', 'LenMile')
#Lazy, so just going to round these values
for (v in vs[-1]) {
  dbscan_LL@data[, v] <- round(dbscan_LL@data[, v], 1)
}
lb <- c('ID: ', '$ (Thousands): ', 'PAI: ', 'Street Length (Miles): ')
diss_lab <- LabFunct(dbscan_LL@data, vs, lb)

print(diss_lab[1]) #showing off just one
##########################################################

##########################################################
HotSpotMap <- leaflet() %>%
  addProviderTiles(providers$OpenStreetMap, group = "Open Street Map") %>%
  addProviderTiles(providers$CartoDB.Positron, group = "CartoDB Lite") %>%
  addPolylines(
    data = DallLine,
    color = 'black',
    weight = 4,
    group = "Dallas Boundary"
  ) %>%
  addPolygons(
    data = dbscan_LL,
    color = "blue",
    weight = 2,
    opacity = 1.0,
    fillOpacity = 0.5,
    group = "DBSCAN Areas",
    popup = diss_lab,
    highlight = highlightOptions(weight = 5, bringToFront = TRUE)
  ) %>%
  addLayersControl(
    baseGroups = c("Open Street Map", "CartoDB Lite"),
    overlayGroups = c("Dallas Boundary", "DBSCAN Areas"),
    options = layersControlOptions(collapsed = FALSE)
  )  %>%
  addScaleBar(
    position = "bottomleft",
    options = scaleBarOptions(
      maxWidth = 100,
      imperial = TRUE,
      updateWhenIdle = TRUE
    )
  )

HotSpotMap

saveWidget(HotSpotMap, "HotSpotMap.html", selfcontained = TRUE)
##########################################################
