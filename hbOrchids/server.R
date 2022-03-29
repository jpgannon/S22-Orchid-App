#install.packages("googlesheets4")
#install.packages("leaflet.providers")
#install.packages("DT")
#install.packages("shinyjs")

library(shiny)
library(leaflet)
library("googlesheets4")
library("DT")
library("tidyverse")
library("shinyjs")

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

gs4_deauth()
orchidTable <- read_sheet("https://docs.google.com/spreadsheets/d/1NfWv1cDVkh9sQYBmEr3FzMCyZ6mJ4k7JzkHNXD5Ti4Y/edit?usp=sharing")



# Define server logic required to draw a map, calculate best paths
shinyServer(function(input, output, session) {
  
  #making reactive orchid table 
  filterData = reactiveVal(orchidTable)
  addedToList = reactiveVal(data.frame())
  
  filtered_orchid <- reactive({
    res <- filterData() 
    
    if(input$visitGroups == 'All') { #group is All
      if(input$site != 'All'){ #site is selected
        res <- filterData() %>% filter(site == input$site)
        print("group all, site selected")
      } else { #site is All
        print("group all, site all")
      }
      
    } else if (input$visitGroups != 'All'){ #group is selected
      if(input$site != 'All') { #site is selected
        res <- res %>% filter(visit_grp == input$visitGroups)
        res <- res %>% filter(site == input$site)
        print("group selected, site selected")
      } else { #site is All
        res <- filterData() %>% filter(visit_grp == input$visitGroups)
        print("group selected, site all")
      }
    }
    
    res %>% 
      dplyr::select(orchid, orchid_associated, visit_grp, site, sub_site, Location_description) 
    
  })
  
  
  #updates outputted orch table
  output$orch <- renderDataTable({
    res <- filtered_orchid()
    
    res
  })
  
  
  #creates the leaflet map
  output$mapPlot <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Esri.WorldTopoMap) %>% #sets basemap
      setView(lng = -71.746866, lat = 43.942395, zoom = 13)  #%>% #sets location
    # addMarkers(lng = orchidTable$lon,
    #            lat = orchidTable$lat,
    #            label = orchidTable$orchid)
  })

  ##################### BUTTON ACTIONS
  #generate button
  observeEvent(input$generate, {
    updateNavbarPage(session, "inTabSet",
                     selected = "results")
  })
  
  #add to list button
  observeEvent(input$addAll, {
    addedToList(rbind(addedToList(),
                      filterData() %>% filter(orchid %in% filtered_orchid()$orchid) %>%
                        dplyr::select(orchid, orchid_associated, visit_grp, site, sub_site, Location_description) %>% distinct() ))
    
  })
  
  #clear list button 
  observeEvent(input$clearList, {
    addedToList(NULL)
  })
  
  # add selected button
  observeEvent(input$addSelected, {
    # addedToList(rbind(addedToList(),
    #                   filterData() %>% filter(orchid %in% filtered_orchid()$orchid) %>%
    #                     dplyr::select(orchid, orchid_associated, visit_grp, site, Location_description) %>% distinct() ))
    
    # addedToList$orchid <- addedToList$orchid %>%
    #   add_row(
    #     filterData(input$filterData_rows_selected)
    #   )
    
    # t <- rbind(data.frame(input$filterData_rows_selected))
    # 
    # addedToList(t)
    
    
    
  })
  
  
  #remove selected button
  observeEvent(input$removeSelected, {
    t = addedToList()
    if (!is.null(input$addedToList_rows_selected)) {
      t <- t[-as.numeric(input$addedToList_rows_selected),]
    }
    addedToList(t)
  })

    
  
  ####################
  
  # update dropdown filters
  observeEvent(input$visitGroups, {
    updateSelectizeInput(session, 'visitGroups', choices = c(All = 'All', sort(orchidTable$visit_grp)), selected = input$visitGroups, server = TRUE)
    
  })
  
  length(orchidTable$visit_grp)
  length(sort(orchidTable$visit_grp))
  
  observeEvent(input$site, {
    updateSelectizeInput(session, 'site', choices = c(All = 'All', sort(orchidTable$site)),  selected = input$site, server = TRUE)
  })
  
  
  
  #updates addedToList table
  output$addedToList <- renderDataTable({
    addedToList()
  })
  
  #r doesn't support multiple outputs w/ same name, have to make a copy of the table for results page
  output$addedToList2 <- renderDataTable({
    addedToList()
  })
  
  #print page button
  observeEvent(input$printPage, {
    js$winprint()
  })
  
  # Parking Sheet
  parking <- read_sheet("https://docs.google.com/spreadsheets/d/1tMqjQqi3NKxpOhHTp9JcWYGMEhGMWmAUsw8L6n_hiUE/edit?usp=sharing")

  # import hubbard brook 10m dem
  hbDEM <- raster("hbef_10mdem.tif")


  #subset visitgroup
  testSub <- addedToList()


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
    dplyr::select(spotID)

  # Add row to complete visit pool
  visitPool <- testSub %>%
    add_row(orchid = toString(parkingSpot$spotID), lat = parkingSpot$lat, lon = parkingSpot$lon)


  ### Distance ###

  # Distance matrix
  dist_mat <-
    dist(
      visitPool %>% dplyr::select(lon, lat),
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
  hbCont <- st_read('hbef_contusgs/hbef_contusgs.shp')


  hbCont <- st_transform(hbCont, '+proj=longlat +datum=WGS84')

  # Plot a map with the data and overlay the optimal path
  output$tMap <- renderLeaflet({
    l <- testPath %>%
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
  })
  
})