

### PACKAGES ###

#tera
#stars
#whiteboxtols

library(ggmap)
library(ggplot2)
library(leaflet)
library(raster)
library(sf)
library(dplyr)
library(tidyr)
library(TSP)




### Read-ins ###

# https://drive.google.com/file/d/1bjt4aQPfbz1rzFeDeF3cKsrLvbuHDfA4/view?usp=sharing
id <- "1bjt4aQPfbz1rzFeDeF3cKsrLvbuHDfA4"
GPS_DataRAW <- read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id))


#cleaning
GPSData <- na.omit(GPS_DataRAW) 

gps_loc <- GPSData 

#subset visitgroup 
testSub <- gps_loc %>%
  filter(visit.grp == 2.5)


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
    control = list(rep = 20)
  )

# Optimal path
path <- names(tour)


# Prepare the data for plotting
testPath <- testSub %>%
  mutate(id_order = order(as.integer(path)))
# Plot a map with the data and overlay the optimal path
testPath %>%
  arrange(id_order) %>%
  leaflet() %>%
  addTiles() %>%
  addCircleMarkers(
    ~lon,
    ~lat,
    popup = ~id_order,
    label = ~id_order,
    radius = 7,
    fillColor = 'red',
    fillOpacity = 0.5,
    stroke = FALSE
  ) %>%
  addPolylines(~lon, ~lat)














##################################################

# broken 

##################################################

# library(geosphere)
# library(ompr)
# library(ompr.roi)
# library(ROI.plugin.glpk)
# library(knitr)
# library(rgdal)

# # #distance matrix
# testSub_coords <- testSub %>%
#   select(lon, lat)
# 
# distance_matrix <- data.matrix(
#   distm(testSub_coords, fun = distHaversine)
# )
# 
# rownames(distance_matrix) <- testSub$orchid
# colnames(distance_matrix) <- testSub$orchid
# 
# 
# 
# #### model ###
# n <- length(testSub$orchid)
# 
# #create a distance extraction function
# dist_fun <- function(i, j) {
#   vapply(seq_along(i), function(k) distance_matrix[i[k], j[k]], numeric(1L))
# }
# 
# model <- MILPModel() %>%
#   # we create a variable that is 1 if we travel from orchid i to j
#   add_variable(x[i, j], i = 1:n, j = 1:n,
#                type = "integer", lb = 0, ub = 1) %>%
# 
#   # a helper variable for the MTZ formulation of the tsp
#   add_variable(u[i], i = 1:n, lb = 1, ub = n) %>%
# 
#   # minimize travel distance
#   set_objective(sum_expr(colwise(dist_fun(i, j)) * x[i, j], i = 1:n, j = 1:n), "min") %>%
# 
#   # you cannot go to the same orchid
#   set_bounds(x[i, i], ub = 0, i = 1:n) %>%
# 
#   # leave each orchid
#   add_constraint(sum_expr(x[i, j], j = 1:n) == 1, i = 1:n) %>%
# 
#   # visit each orchid
#   add_constraint(sum_expr(x[i, j], i = 1:n) == 1, j = 1:n) %>%
# 
#   # ensure no subtours (arc constraints)
#   add_constraint(u[i] >= 2, i = 2:n) %>%
#   add_constraint(u[i] - u[j] + 1 <= (n - 1) * (1 - x[i, j]), i = 2:n, j = 2:n)
# 
# model
# 
# #solve the model
# result <- solve_model(model, with_ROI(solver = "glpk", verbose = TRUE)) #doesn't work -- takes 5+ hours
# 
# 
# leaflet(data = testSub) %>% addTiles() %>%
#   addMarkers(~lon, ~lat, popup = ~orchid, label = ~orchid)

<<<<<<< HEAD
#failed googlemap basemap
hubbardMap <- get_map(location = c(lon = -71.72, lat = 43.93), zoom = 10)
=======
>>>>>>> 4c8ed23f091a9d2a4c5eff6e51b08f4dcc0f4165

