#color by ID

library(shiny)
library(leaflet)
library("googlesheets4")
library("DT")
library("tidyverse")
library("shinyjs")
library("shinythemes")
library(raster)
library(sf)
library(dplyr)
library(TSP)
library(rgdal)
library(sp)
library(rgeos)

gs4_deauth()
GPS_DataRAW <- read_sheet("https://docs.google.com/spreadsheets/d/1NfWv1cDVkh9sQYBmEr3FzMCyZ6mJ4k7JzkHNXD5Ti4Y/edit?usp=sharing")


# Define server logic required to draw a map, calculate best paths
shinyServer(function(input, output, session) {
  
  ### 
  # Making reactive orchid table
  filterData = reactiveVal(GPS_DataRAW)
  addedToList = reactiveVal(data.frame()) 
  
  # Table filtering logic 
  filteredOrchid <- reactive({
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
      dplyr::select(orchid, orchid_associated, visit_grp, site, sub_site, Location_description, lat, lon)
    
  })
  
  
  ### Import Maps ###
  
  # Import contour map: https://portal.edirepository.org/nis/mapbrowse?scope=knb-lter-hbr&identifier=91
  hbCont <- st_read('hbef_contusgs/hbef_contusgs.shp')
  hbCont <- st_transform(hbCont, '+proj=longlat +datum=WGS84')
  
  # Import hubbard brook 10m dem
  # hbDEM_name <- "hbef_10mdem.tif"
  # hbDEM <- raster(hbDEM_name)
  
  # Parking Sheet
  parking <- read_sheet("https://docs.google.com/spreadsheets/d/1tMqjQqi3NKxpOhHTp9JcWYGMEhGMWmAUsw8L6n_hiUE/edit?usp=sharing")
  
  
  ### Button Actions ###
  # Add Filtered button
  observeEvent(input$addFiltered, {
    addedToList(rbind(addedToList(),
                      filterData() %>% filter(orchid %in% filteredOrchid()$orchid) %>%
                        dplyr::select(orchid, orchid_associated, visit_grp, site, sub_site, Location_description, lat, lon) %>% distinct() ))
    
    enable("generate")
  })
  
  # Add Selected button 
  observeEvent(input$addSelected, {
    t = filteredOrchid() 
    if (!is.null(input$orch_rows_selected)) {
      t <- t[as.numeric(input$orch_rows_selected),]
      addedToList(rbind(addedToList(), t))
      
      shinyjs::enable("generate")
    }
    
  })
  
  # Clear list button
  observeEvent(input$clearList, {
    addedToList(NULL)
    shinyjs::disable("generate")
  })
  
  # Remove selected button
  observeEvent(input$removeSelected, {
    t = addedToList()
    if (!is.null(input$addedToList_rows_selected)) {
      t <- t[-as.numeric(input$addedToList_rows_selected),]
    }
    addedToList(t)
    
    if(nrow(addedToList()) == 0) {
      shinyjs::disable("generate")
    }
  })
  
  
  # Generate button
  # Triggers path calculations
  observeEvent(input$generate, {
    updateNavbarPage(session, "inTabSet",
                     selected = "results")
    
    ###  Parking Alg ###
    
    # Convert parking to SpatialPoints
    pDistXY <- sp::SpatialPoints(parking[,1:2])
    
    # Convert testSub to Spatialpoints
    tDistXY <- sp::SpatialPoints(addedToList()[,7:8])
    
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
    visitPool <- addedToList() %>%
      add_row(orchid = toString(parkingSpot$spotID), lat = parkingSpot$lat, lon = parkingSpot$lon)
    
    ### Pathing Alg ###
    
    # Distance matrix
    dist_mat <- 
      dist(
        visitPool %>% select(lon, lat),
        method = 'euclidean'
      )
    
    # Initialize the TSP object
    tsp_prob <- TSP(dist_mat)
    
    # Pathing model (TSP)
    tour <-
      solve_TSP(
        tsp_prob,
        method = 'two_opt',
        control = list(rep = 16)
      )
    
    # Create path given Parking Spot as first node
    path <- cut_tour(tour, cut = length(tour), exclude_cut = FALSE)
    
    
    # Create path order ID column
    testPath <- visitPool %>%
      mutate(id_order = order(as.integer(path)))
    
    ### Close the loop ###
    
    # Add new row with first orchid coords
    testPath <- testPath %>%
      arrange(id_order) %>%
      add_row(lat = as.double(testPath[testPath$id_order == 1, 7]), lon = as.double(testPath[testPath$id_order == 1, 8]))
    
    # Set as last node in path order
    testPath[nrow(testPath), 9] <- testPath[nrow(testPath) - 1, 9] + 1
    
    # Renders the testPath table for UI 
    output$visitOrder <- renderDataTable({
      testPath[-c(1,length(testPath)),] %>% 
        select(c(orchid)) 
    })
    
    # Remove last row from testPath to avoid overlapping labels
    pathOrder <- head(testPath, - 1)
    
    
    # Path order list for results page
    output$pathOrderList <- renderText({paste(as.character(pathOrder$orchid), collapse = ", ")})
    
    # Create colorpalette from pathOrder
    pal <- colorNumeric(
      palette = c("green", "red"),
      domain = pathOrder$id_order)
    
    # Creates the leaflet map
    output$tMap <- renderLeaflet({
      pMap <- leaflet() %>%
        fitBounds(lng1 = min(testPath$lon),        # Set view bounds based on testPath points
                  lat1 = min(testPath$lat), 
                  lng2 = max(testPath$lon), 
                  lat2 = max(testPath$lat)) %>%
        addTiles() %>% 
        addPolylines(data=hbCont,                  # Add contour lines
                     fillOpacity = .01,
                     color = "grey") %>%
        addCircleMarkers(data= pathOrder,          # Plot pathOrder points
                         ~lon,
                         ~lat,
                         popup = ~orchid,
                         label = ~id_order,
                         labelOptions = labelOptions(noHide = T,
                                                     direction = "top",
                                                     offset = c(0,20),
                                                     textOnly = T,
                                                     style = list("color" = "white")),
                         radius = 10,
                         color = ~pal(pathOrder$id_order),
                         fillOpacity = 10,
                         stroke = FALSE) %>%
        addPolylines(data=testPath,                # Plot path
                     ~lon,
                     ~lat) 
      pMap
      
    })
    
  })
  
  
  
  # Print page button
  observeEvent(input$printPage, {
    js$winprint()
  })
  
  
  ### Rendering UI objects ###
  
  ## FILTERS ##
  # Visit Group drop down
  output$visitGroups <- renderUI({
    selectizeInput('visitGroups', 'Select Visit Group', choices = c(All = 'All', sort(GPS_DataRAW$visit_grp)))
    
  })
  

  
  # Sites drop down
  output$site <- renderUI ({
    selectizeInput('site', 'Select Site', choices = c(All = 'All',  sort(GPS_DataRAW$site)))

  })
  
  observeEvent(input$visitGroups, {
    
    choice_site <- reactive({
      groups <- input$visitGroups
      
      filterData() %>%
        filter(visit_grp == groups) %>%
        pull(sort(site)) #%>%
      # as.character()
    })
    updateSelectizeInput(session,'site', 'Select Site', choices = c(All = 'All',  choice_site()))
  })
  
  ## TABLES ##
  # Selected Orchids table, Routes page
  output$addedToList <- renderDataTable({
    if(!is.null(addedToList())) {
      addedToList() %>%
        select(-c(lat,lon))
    } else {
      addedToList()
    }
  })
  
  # Filtered Orchid table
  output$orch <- renderDataTable({
    filteredOrchid() %>%
      select(-c(lat,lon)) 
    
  })
})