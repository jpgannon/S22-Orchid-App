

### PACKAGES ###

# install.packages("ggmap")
# install.packages("ggplot2")

library(ggmap)
library(ggplot2)


### Read-ins ###

# https://drive.google.com/file/d/1oK8zHk3mFquaIYnxLtRSKbGzNtN3aqU1/view?usp=sharing
id <- "1oK8zHk3mFquaIYnxLtRSKbGzNtN3aqU1"
GPS_DataRAW <- read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id))

names(GPS_DataRAW)[1] <- 'lat'


### Mapping ###

#failed googlemap basemap
#hubbardMap <- get_map(location = c(lon = -71.72, lat = 43.93), zoom = 10)

ggplot(GPS_DataRAW, aes(lon, lat)) +
  geom_point()
