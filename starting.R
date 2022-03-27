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
library(sp)
library(rgeos)

### Read-ins ###

# Allow Google Sheet read without authentication 
gs4_deauth()

# Orchid Data Sheet
GPS_DataRAW <- read_sheet("https://docs.google.com/spreadsheets/d/1NfWv1cDVkh9sQYBmEr3FzMCyZ6mJ4k7JzkHNXD5Ti4Y/edit?usp=sharing")

# Parking Sheet
parking <- read_sheet("https://docs.google.com/spreadsheets/d/1tMqjQqi3NKxpOhHTp9JcWYGMEhGMWmAUsw8L6n_hiUE/edit?usp=sharing")

# import hubbard brook 10m dem
hbDEM <- raster("hbef_10mdem.tif")


GPSData <- GPS_DataRAW

gps_loc <- GPSData 


#subset visitgroup 
testSub <- gps_loc %>%
  filter(visit_grp == 2.5)


###  Parking Alg ###

# Convert parking to SpatialPoints
pDistXY <- sp::SpatialPoints(parking[,1:2])

# Convert testSub to Spatialpoints
tDistXY <- sp::SpatialPoints(testSub[,7:8])

# Nearest point distance
pDistXY$nearestDist <- apply(gDistance(tDistXY, pDistXY, byid=TRUE), 1, min)

# Create parking row
parkingSpot <- as.data.frame(pDistXY) %>%
  filter(nearestDist == min(nearestDist))

#Add ParkingSpot spotID
parkingSpot$spotID <- parking %>%
  filter(lon == parkingSpot[,3]) %>%
  select(spotID)

# Add row to complete visit pool
 visitPool <- testSub %>%
   add_row(orchid = toString(parkingSpot$spotID), lat = parkingSpot$lat, lon = parkingSpot$lon)
 

### Distance ###

#library(TSP)
# Distance matrix
dist_mat <- 
  dist(
    visitPool %>% select(lon, lat),
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

# Create path given Parking Spot as first node
path <- cut_tour(tour, cut = length(tour), exclude_cut = FALSE)


# Prepare the data for plotting
testPath <- visitPool %>%
  mutate(id_order = order(as.integer(path)))

### Close the loop ###

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
  fitBounds(lng1 = min(testPath$lon),         # Set view bounds based on testPath points
            lat1 = min(testPath$lat), 
            lng2 = max(testPath$lon), 
            lat2 = max(testPath$lat)) %>%
  addTiles() %>% 
  addMarkers(data = parkingSpot,             # Create static ParkingSpot label
             ~lon,
             ~lat,
             label = paste("ParkingSpot", parkingSpot$spotID, sep = " "),
             labelOptions = labelOptions(noHide = T)) %>%
  addPolylines(data=hbCont,                  # Add contour lines
               fillOpacity = .01,
               color = "grey") %>%
  addCircleMarkers(data=testPath,            # Plot testPath points
                   ~lon,
                   ~lat,
                   popup = ~orchid,
                   label = ~id_order,
                   radius = 8,
                   fillColor = 'red',
                   fillOpacity = 0.5,
                   stroke = FALSE) %>%
  addPolylines(data=testPath,                # Plot path
               ~lon,
               ~lat) 
pMap

# Plot a map with path, contour lines, and DEM
cMap <- leaflet() %>%
  fitBounds(lng1 = min(testPath$lon), 
            lat1 = min(testPath$lat), 
            lng2 = max(testPath$lon), 
            lat2 = max(testPath$lat)) %>%
  addTiles() %>% 
  addMarkers(data = parkingSpot,
             ~lon,
             ~lat,
             label = paste("ParkingSpot", parkingSpot$spotID, sep = " "),
             labelOptions = labelOptions(noHide = T)) %>%
  addRasterImage(hbDEM, colors = "Spectral") %>% # Add DEM layer
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
               ~lat) %>%
  addMarkers(data = parkingSpot,
             ~lon,
             ~lat,
             label = "Parking Spot") 

cMap





