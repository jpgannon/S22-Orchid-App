### PACKAGES ###

library(ggmap)
library(ggplot2)
library(leaflet)
library(raster)
library(sf)
library(dplyr)
library(tidyr)
library(TSP)
library(tidyverse)
library(rgdal)
library(googlesheets4)


### Read-ins ###

gs4_deauth()

# https://drive.google.com/file/d/1bjt4aQPfbz1rzFeDeF3cKsrLvbuHDfA4/view?usp=sharing
id <- "1bjt4aQPfbz1rzFeDeF3cKsrLvbuHDfA4"
GPS_DataRAW <- read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id))

# https://docs.google.com/spreadsheets/d/1tMqjQqi3NKxpOhHTp9JcWYGMEhGMWmAUsw8L6n_hiUE/edit?usp=sharing
parking <- read_sheet("https://docs.google.com/spreadsheets/d/1tMqjQqi3NKxpOhHTp9JcWYGMEhGMWmAUsw8L6n_hiUE/edit?usp=sharing")

# import hubbard brook 10m dem
hbDEM <- raster("hbef_10mdem.tif")


#### Cleaning ###

# select orchids without elevation
coordless <- GPS_DataRAW %>%
  filter(!is.na(lat)) %>%
  filter(!is.na(lon)) %>%
  filter(is.na(ele)) %>%
  select(lat, lon)

# swap lat and lon column positions
coordless <- coordless[,c(2, 1)]


# convert coordless to spatialPoints
coordlessSP <- SpatialPoints(coordless, proj4string = CRS("+proj=longlat +datum=WGS84"))


# find elevation of points in coordlessSP
coordlessEle <- raster::extract(hbDEM, coordlessSP)


# convert coordlessEle to data frame
coordlessDF <- cbind(coordlessEle)


# update GPS_DataRaw with coordlessDF ?
# OR
# update google sheet with coordlessDF ?


GPSData <- na.omit(GPS_DataRAW) 

gps_loc <- GPSData 

#subset visitgroup 
testSub <- gps_loc %>%
  filter(visit.grp == 1)


### Distance ###

#library(TSP)
# Distance matrix
dist_mat <- 
  dist(
    testSub %>% select(lon, lat),
    method = 'euclidean'
  )

# Initialize the TSP object
tsp_prob <- TSP(dist_mat)

### Model ###

# TSP solver
tour <-
  solve_TSP(
    tsp_prob,
    method = 'two_opt',
    control = list(rep = 16)
  )

# Optimal path
path <- names(tour)


# Prepare the data for plotting
testPath <- testSub %>%
  mutate(id_order = order(as.integer(path)))

## Close the loop

# Add new row with first orchid coords
testPath <- testPath %>%
  arrange(id_order) %>%
  add_row(lat = as.double(testPath[testPath$id_order == 1, 7]), lon = as.double(testPath[testPath$id_order == 1, 8]))

# Set as last point  
testPath[nrow(testPath), 11] <- testPath[nrow(testPath) - 1, 11] + 1

### Mapping ###

# Import contour map: https://portal.edirepository.org/nis/mapbrowse?scope=knb-lter-hbr&identifier=91
#hbCont <- vect('hbef_contusgs/hbef_contusgs.shp')
hbCont <- st_read('hbef_contusgs/hbef_contusgs.shp')

hbCont <- st_transform(hbCont, '+proj=longlat +datum=WGS84')

# Plot a map with the data and overlay the optimal path
pMap <- leaflet() %>%
  addTiles() %>% 
  addPolylines(data=hbCont, 
              fillOpacity = .01,
              color = "grey") %>%
  addCircleMarkers(data=testPath, 
                   ~lon,
                   ~lat,
                   popup = ~orchid,
                   label = ~id_order,
                   radius = 7,
                   fillColor = 'red',
                   fillOpacity = 0.5,
                   stroke = FALSE) %>%
  addPolylines(data=testPath,
               ~lon,
               ~lat)
  
pMap

