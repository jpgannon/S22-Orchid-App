#rm(list = ls())
# ##

library(sf)
library(ggplot2)
library(dplyr)

#SUBSET OF DATA 
subset_data_gps <- OrchidGPS[, c(1,2,3,4,7)]
names(subset_data_gps)[names(subset_data_gps) == 'name'] <- 'orchid_associated'
subset_data_gps$orchid_associated <- as.character(subset_data_gps$orchid_associated)

subset_data_location <- OrchidLocation[ , c(2:6)]
names(subset_data_location)[names(subset_data_location) == 'assoc. orchid'] <- 'orchid_associated'
subset_data_location$orchid_associated <- as.character(subset_data_location$orchid_associated)
subset_data_location$orchid_associated = sub("\\..*", "", subset_data_location$orchid_associated)
subset_data_location$orchid_associated <- sub("^", "ORC ", subset_data_location$orchid_associated)
joined_subset_data <- left_join(subset_data_location, subset_data_gps, by = 'orchid_associated')