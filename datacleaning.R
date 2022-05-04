rm(list = ls())

library(sf)
library(ggplot2)
library(dplyr)
library(magrittr)
library(zoo)
library(tidyr)

gps <- OrchidGPS_updated[, c(1,2,3,4,8,9)]
gps$orchid_associated <- paste(gps$combine1, gps$combine2)
gps <- gps[,c(1,2,3,4,7)]
gps$orchid_associated <- as.character(gps$orchid_associated)

#determines where duplicate gps data is:
counts <- gps %>% group_by(orchid_associated) %>% summarize(num = length(orchid_associated)) #orc 25, 264, 94
#delete 1 of the rows of duplicated gps (keep most recent data)
which(gps$orchid_associated == 'ORC 25') #keep data from 2020
gps <- gps[-c(57),]
which(gps$orchid_associated == 'ORC 264') #keep data from 2016
gps <- gps[-c(62),]
which(gps$orchid_associated == 'ORC 94') #keep data from 2018
gps <- gps[-c(139),]


location <- OrchidLocation[ , c(2:6)]
names(location)[names(location) == 'assoc. orchid'] <- 'orchid_associated'
location$orchid_associated <- as.character(location$orchid_associated)
location$orchid_associated = sub("\\..*", "", location$orchid_associated)
location$orchid_associated <- sub("^", "ORC ", location$orchid_associated)
joined_data1 <- left_join(location, gps, by = 'orchid_associated') #joined_data1 is by orchid associated 

location$orchid <- as.character(location$orchid)
location$orchid = sub("\\..*", "", location$orchid)
location$orchid <- sub("^", "ORC ", location$orchid)
joined_data2 <- left_join(location, gps, by = c("orchid" = "orchid_associated")) #joined_data2 is by orchid 

joined_data <- joined_data1
joined_data$lat <- ifelse(is.na(joined_data$lat), joined_data2$lat, joined_data$lat)
joined_data$lon <- ifelse(is.na(joined_data$lon), joined_data2$lon, joined_data$lon)
joined_data$ele <- ifelse(is.na(joined_data$ele), joined_data2$ele, joined_data$ele)
joined_data$time <- ifelse(is.na(joined_data$time), joined_data2$time, joined_data$time)
joined_data$orchid <- sub("^", "ORC ", joined_data$orchid)

#clean up - common names of groups when inconsistent 
joined_data$site[ joined_data$site == "VW27 EAST grp" ] <- "VW27 East"
joined_data$site[ joined_data$site == "B-line 13" ] <- "B-Line 13"
joined_data$site[ joined_data$site == "VW304 grp" ] <- "VW304 group"
joined_data$site[ joined_data$site == "VW305 group" ] <- "VW305"
joined_data$site[ joined_data$site == "Paradise Bk" ] <- "Paradise Brook"
joined_data$site[ joined_data$site == "B-LINE 9, POST 107 GRP" ] <- "B-Line 9, post 107"
joined_data$site[ joined_data$site == "B-line13, post 239" ] <- "B-Line 13, post 239"
joined_data$site[ joined_data$site == "B-line9, post 107" ] <- "B-Line 9, post 107"
joined_data$site[ joined_data$site == "Bline 13, plot 240" ] <- "B-Line 13, plot 240"
joined_data$site[ joined_data$site == "Bline 9 or 10" ] <- "B-Line 10"
joined_data$site[ joined_data$site == "BLINE13, EASTEND; ON EAST SIDE OF RD" ] <- "B-Line 13"
joined_data$site[ joined_data$site == "BB-LOW; 45m N OF VW306" ] <- "BB-Low"
joined_data$site[ joined_data$site == "Bline13, post 209" ] <- "B-Line 13, post 209"
joined_data$site[ joined_data$site == "BLINE13, POST 209" ] <- "B-Line 13, post 209"
joined_data$site[ joined_data$site == "BLINE13, POST 222" ] <- "B-Line 13, post 222"
joined_data$site[ joined_data$site == "Bline13, post 229" ] <- "B-Line 13, post 229"
joined_data$site[ joined_data$site == "BLINE13, POST 236" ] <- "B-Line 13, post 236"
joined_data$site[ joined_data$site == "Bline13, post 241" ] <- "B-Line 13, post 241"
joined_data$site[ joined_data$site == "Bline5, also VW9" ] <- "B-Line 5, also VW 9"
joined_data$site[ joined_data$site == "Bline5, post 11" ] <- "B-Line 5, post 11"
joined_data$site[ joined_data$site == "Bline5, post 38" ] <- "B-Line 5, post 38"
joined_data$site[ joined_data$site == "Bline5, post 40" ] <- "B-Line 5, post 40"
joined_data$site[ joined_data$site == "B-line 5, post 34" ] <- "B-Line 5, post 34"
joined_data$site[ joined_data$site == "B-line 9, post 103" ] <- "B-Line 9, post 103"
joined_data$site[ joined_data$site == "Bline9, post 107" ] <- "B-Line 9, post 107"
joined_data$site[ joined_data$site == "B-line 9, post 107" ] <- "B-Line 9, post 107"
joined_data$site[ joined_data$site == "Bline9, post 110" ] <- "B-Line 9, post 110"
joined_data$site[ joined_data$site == "BLINE9, POST 91" ] <- "B-Line 9, post 91"
joined_data$site[ joined_data$site == "Bline9, post 95" ] <- "B-Line 9, post 95"
joined_data$site[ joined_data$site == "BLINE9, POST 97" ] <- "B-Line 9, post 97"
joined_data$site[ joined_data$site == "B-line 9" ] <- "B-Line 9"
joined_data$site[ joined_data$site == "BLINE9, POST117, DOWNSLOPE OF A9" ] <- "B-Line 9, post 117"
joined_data[114, 4] = 'DOWNSLOPE OF A9'
joined_data$site[ joined_data$site == "BB-Low;" ] <- "BB-Low"
joined_data$site[ joined_data$site == "BB-low" ] <- "BB-Low"
joined_data$site[ joined_data$site == "btwn VW57 and 27" ] <- "VW 27, Near VW 57"
joined_data$site[ joined_data$site == "Near Flux Tower Rd" ] <- "Flux tower rd"
joined_data$site[ joined_data$site == "NH Demo area" ] <- "NH Demo"
joined_data$site[ joined_data$site == "NH Demo Plot" ] <- "NH Demo"
joined_data$site[ joined_data$site == "NH Demo; Bline 10" ] <- "NH Demo, Bline 10"
joined_data$site[ joined_data$site == "NH Demo, Bline 10" ] <- "NH Demo, B-Line 10"
joined_data$site[ joined_data$site == "NH Demo, Bline 17" ] <- "NH Demo, B-Line 17"
joined_data$site[ joined_data$site == "VW 312 parking" ] <- "VW 312, parking"
joined_data$site[ joined_data$site == "VW 312, (SW or SE?) of plot" ] <- "VW 312 SW of plot"
joined_data$site[ joined_data$site == "VW 312, west of plot" ] <- "VW 312, W of plot"
joined_data$site[ joined_data$site == "VW 312, south" ] <- "VW 312, S of plot"
joined_data$site[ joined_data$site == "VW 312 SW of plot" ] <- "VW 312, SW of plot"
joined_data$site[ joined_data$site == "VW 312, North" ] <- "VW 312, N of plot"
joined_data$site[ joined_data$site == "VW 334, West" ] <- "VW 334, W of plot"
joined_data$site[ joined_data$site == "VW 57 vicinity" ] <- "VW 57"
joined_data$site[ joined_data$site == "VW1, west of plot" ] <- "VW 1, W of plot"
joined_data$site[ joined_data$site == "VW1grp" ] <- "VW 1"
joined_data$site[ joined_data$site == "VW217" ] <- "VW 217"
joined_data$site[ joined_data$site == "VW217, NE QUAD" ] <- "VW 217, NE QUAD"
joined_data$site[ joined_data$site == "VW217; 278M WEST BY GPS" ] <- "VW 217, 278M WEST BY GPS"
joined_data$site[ joined_data$site == "VW217; GPS NEEDED" ] <- "VW 217, GPS NEEDED"
joined_data$site[ joined_data$site == "VW234" ] <- "VW 234"
joined_data$site[ joined_data$site == "VW236" ] <- "VW 236"
joined_data$site[ joined_data$site == "VW236 NE grp" ] <- "VW 236, NE"
joined_data$site[ joined_data$site == "VW236; PARKING" ] <- "VW 236, PARKING"
joined_data$site[ joined_data$site == "VW27" ] <- "VW 27"
joined_data$site[ joined_data$site == "VW27 East" ] <- "VW 27, East"
joined_data$site[ joined_data$site == "VW27 grp" ] <- "VW 27"
joined_data$site[ joined_data$site == "VW27 north" ] <- "VW 27, North"
joined_data$site[ joined_data$site == "VW27 vicinity" ] <- "VW 27"
joined_data$site[ joined_data$site == "VW27-28" ] <- "VW 27, Near VW 28"
joined_data$site[ joined_data$site == "VW201-202, ON LINE" ] <- "VW 201, Near VW 202"
joined_data$site[ joined_data$site == "VW234-233;" ] <- "VW 234, Near VW 233"
joined_data$site[ joined_data$site == "VW234-233" ] <- "VW 234, Near VW 233"
joined_data$site[ joined_data$site == "VW27east" ] <- "VW 27, East"
joined_data$site[ joined_data$site == "VW27EAST" ] <- "VW 27, East"
joined_data$site[ joined_data$site == "VW27grp" ] <- "VW 27"
joined_data$site[ joined_data$site == "VW27GRP" ] <- "VW 27"
joined_data$site[ joined_data$site == "VW27west" ] <- "VW 27, West"
joined_data$site[ joined_data$site == "VW29" ] <- "VW 29"
joined_data$site[ joined_data$site == "VW29 east" ] <- "VW 29, East"
joined_data$site[ joined_data$site == "VW29 East" ] <- "VW 29, East"
joined_data$site[ joined_data$site == "VW29-28" ] <- "VW 29, Near VW 28"
joined_data$site[ joined_data$site == "VW299" ] <- "VW 299"
joined_data$site[ joined_data$site == "VW299 vicinity" ] <- "VW 299"
joined_data$site[ joined_data$site == "VW304 group" ] <- "VW 304"
joined_data$site[ joined_data$site == "VW305" ] <- "VW 305"
joined_data$site[ joined_data$site == "VW311" ] <- "VW 311"
joined_data$site[ joined_data$site == "VW312" ] <- "VW 312"
joined_data$site[ joined_data$site == "VW315-316" ] <- "VW 315, Near VW 316"
joined_data$site[ joined_data$site == "VW319 - 320 vicinity" ] <- "VW 319, Near VW 320"
joined_data$site[ joined_data$site == "VW320" ] <- "VW 320"
joined_data$site[ joined_data$site == "VW324" ] <- "VW 324"
joined_data$site[ joined_data$site == "VW329" ] <- "VW 329"
joined_data$site[ joined_data$site == "VW334" ] <- "VW 334"
joined_data$site[ joined_data$site == "VW334-ROADSIDE" ] <- "VW334, Roadside"
joined_data$site[ joined_data$site == "VW334, Roadside" ] <- "VW 334, Roadside"
joined_data$site[ joined_data$site == "VW313" ] <- "VW 313"
joined_data$site[ joined_data$site == "VW335" ] <- "VW 335"
joined_data$site[ joined_data$site == "VW343" ] <- "VW 343"
joined_data$site[ joined_data$site == "VW375" ] <- "VW 375"
joined_data$site[ joined_data$site == "VW380" ] <- "VW 380"
joined_data$site[ joined_data$site == "VW57GRP" ] <- "VW 57"
joined_data$site[ joined_data$site == "VW59 WEST RD" ] <- "VW 59, West of Rd"
joined_data$site[ joined_data$site == "W1" ] <- "W 1"
joined_data$site[ joined_data$site == "W1-HIGH" ] <- "W 1, High"
joined_data$site[ joined_data$site == "W1-HIGH; grid 52" ] <- "W 1, High, grid 52"
joined_data$site[ joined_data$site == "W1-low" ] <- "W 1, Low"
joined_data$site[ joined_data$site == "W1-Low (west)" ] <- "W 1, Low, West"
joined_data$site[ joined_data$site == "W1-low, trailside" ] <- "W 1, Low, Trailside"
joined_data$site[ joined_data$site == "W1, base" ] <- "W 1, Base"
joined_data$site[ joined_data$site == "W1, below weir" ] <- "W 1, Below Weir Rd"
joined_data$site[ joined_data$site == "W1, grid 100" ] <- "W1, grid 100"
joined_data$site[ joined_data$site == "W1, grid 155" ] <- "W 1, grid 155"
joined_data$site[ joined_data$site == "W1, grid 95" ] <- "W 1, grid 95"
joined_data$site[ joined_data$site == "W1, plot 82" ] <- "W 1, plot 82"
joined_data$site[ joined_data$site == "W1; South of (downstream of) weir" ] <- "W 1, South and Downstream of Weir Rd"
joined_data$site[ joined_data$site == "W1-Low" ] <- "W 1, Low"
joined_data$site[ joined_data$site == "W3" ] <- "W 3"
joined_data$site[ joined_data$site == "W3 above RG4" ] <- "W 3, Above RG4"
joined_data$site[ joined_data$site == "W3 High" ] <- "W 3, High"
joined_data$site[ joined_data$site == "W3 HIGH" ] <- "W 3, High"
joined_data$site[ joined_data$site == "W3 low" ] <- "W 3, Low"
joined_data$site[ joined_data$site == "W3 Low" ] <- "W 3, Low	"
joined_data$site[ joined_data$site == "W3 S of rain gauge" ] <- "W 3, South of rain gauge"
joined_data$site[ joined_data$site == "W3-High" ] <- "W 3, High"
joined_data$site[ joined_data$site == "W3-low" ] <- "W 3, Low"
joined_data$site[ joined_data$site == "W3-Low" ] <- "W 3, Low"
joined_data$site[ joined_data$site == "W3-LOW" ] <- "W 3, Low"
joined_data$site[ joined_data$site == "W3-low / mid" ] <- "W 3, Mid, Near W 3 Low"
joined_data$site[ joined_data$site == "W3-Low; S of W3 below rain gauge" ] <- "W 3, Low, South of W 3 below rain gauge"
joined_data$site[ joined_data$site == "W3-mid" ] <- "W 3, Mid"
joined_data$site[ joined_data$site == "W3-MID" ] <- "W 3, Mid"
joined_data$site[ joined_data$site == "W3-Mid (west)" ] <- "W 3, Mid, West"
joined_data$site[ joined_data$site == "W3, BABY OF Orc266" ] <- "W 3"
joined_data$site[ joined_data$site == "W5 Grid 301" ] <- "W 5, grid 301"
joined_data$site[ joined_data$site == "W5 Grid 350" ] <- "W 5, grid 350"
joined_data$site[ joined_data$site == "W5 west border" ] <- "W 5, West"
joined_data$site[ joined_data$site == "W5, grid 347" ] <- "W 5, grid 347"
joined_data$site[ joined_data$site == "W6" ] <- "W 6"
joined_data$site[ joined_data$site == "W6 trail" ] <- "W 6, Trail"
joined_data$site[ joined_data$site == "W6, grid 204	" ] <- "W 6, grid 204"
joined_data$site[ joined_data$site == "W6, west" ] <- "W 6, West"
joined_data$site[ joined_data$site == "W6, WEST" ] <- "W 6, West"
joined_data$site[ joined_data$site == "W6; grid cell 135" ] <- "W 6, grid 135"
joined_data$site[ joined_data$site == "Wedge5" ] <- "Wedge 5"
joined_data$site[ joined_data$site == "WEDGE5" ] <- "Wedge 5"
joined_data$site[ joined_data$site == "Wedge5, VW309" ] <- "Wedge 5, Near VW 309"
joined_data$site[ joined_data$site == "Wedge5, W4 Rd" ] <- "Wedge 5, Near W 4 Rd"
joined_data$site[ joined_data$site == "Wedge5; VW 309" ] <- "Wedge 5, Near VW 309"
joined_data$site[ joined_data$site == "WEDGE5; W4 TRAIL" ] <- "Wedge 5; Near W 4 Trail"
joined_data$site[ joined_data$site == "Wedge 5; Near W 4 Trail" ] <- "Wedge 5, Near W 4 Trail"
joined_data$site[ joined_data$site == "Weir Rd, Flume Rd" ] <- "Flume and Weir Rd"
joined_data$site[ joined_data$site == "West of W6" ] <- "W 6, West"
joined_data$site[ joined_data$site == "W1, grid 100" ] <- "W 1, grid 100"


#Filling in NA GPS Data:
#using nearby orchids 
joined_data <- joined_data %>%
  arrange(site) %>%
  group_by(site) %>%
  fill(lat, .direction = 'up') %>%
  fill(lat, .direction = 'down') %>%
  fill(lon, .direction = 'up') %>%
  fill(lon, .direction = 'down') %>%
  fill(ele, .direction = 'up') %>%
  fill(ele, .direction = 'down')

#ORC 1096, 1097 - row 443
joined_data[443, 6] = 43.93864
joined_data[443,7] = -71.74929

#ORC 998.0 B-Line 5, post 38 - row 29
joined_data[29, 6] = 43.94820
joined_data[29,7] = -71.74256

#ORC 841 B-Line 13, post 236 - row 14
joined_data[14, 6] = 43.94810
joined_data[14, 7] = -71.74250

#ORC 1004, 1005 - row 4
joined_data[4, 6] = 43.94414
joined_data[4, 7] = -71.73779


#Filling in NA GPS Data:
#using watershed 1 grid data and ArcGIS to collect these coordinates 

#W1, grid 100 - row 731
joined_data[731, 6] = 43.9563405
joined_data[731, 7] = -71.7284768

#W1, grid 155 - row 732
joined_data[732, 6] = 43.9547646
joined_data[732, 7] = -71.7273543

#W1, grid 95 - row 733
joined_data[733, 6] = 43.9565851
joined_data[733, 7] = -71.7282843

#W1, plot 82 - row 742
joined_data[742, 6] = 43.9570082
joined_data[742, 7] = -71.7284002

#ORC 763 - GRID 187; BOTTOM MIDDLE OF PLOT - row 884
joined_data[884, 6] = 43.9535421
joined_data[884, 7] = -71.7263523

#ORC 764 - 	GRID 175; NW CORNER (4 of these)
joined_data[885, 6] = 43.9538993
joined_data[885, 7] = -71.7277023
joined_data[886, 6] = 43.9538993
joined_data[886, 7] = -71.7277023
joined_data[887, 6] = 43.9538993
joined_data[887, 7] = -71.7277023
joined_data[888, 6] = 43.9538993
joined_data[888, 7] = -71.7277023

#Split site into Site and Sub-Site:
joined_data <- joined_data %>%
  separate(site, into = c("site", "sub-site"), sep = ",")

#check for any repeating sites 
counts2 <- joined_data %>% group_by(site) %>% summarize(num = length(site))


write.csv(joined_data, file = 'final_joined_data.csv')