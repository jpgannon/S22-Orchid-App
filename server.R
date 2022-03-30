#install.packages("googlesheets4")
#install.packages("leaflet.providers")
#install.packages("DT")
#install.packages('tidyverse')

library(shiny)
library(leaflet)
library("googlesheets4")
library("DT")
library("tidyverse")
library("shinyjs")
library("googlesheets4")
library("shinythemes")
library(ggmap)
library(ggplot2)
library(raster)
library(sf)
library(dplyr)
library(tidyr)
library(TSP)
library(tidyverse)
library(rgdal)

gs4_deauth()
GPS_DataRAW <- read_sheet("https://docs.google.com/spreadsheets/d/1NfWv1cDVkh9sQYBmEr3FzMCyZ6mJ4k7JzkHNXD5Ti4Y/edit?usp=sharing")


# Define server logic required to draw a map, calculate best paths
shinyServer(function(input, output, session) {
  #making reactive orchid table 
  filterData = reactiveVal(GPS_DataRAW)
  addedToList = reactiveVal(data.frame()) # Gannon suspects that this is empty. Not sure how the filtering is passed.
  
  
  #subset visitgroup 
 
  #table creation
  filtered_orchid <- reactive({
    # res <- filterData() %>% 
    #   dplyr::select(orchid, orchid_associated, visit_grp, site,   Location_description, lat, lon) 
    # 
    # if (input$visitGroups != '') {
    #   res <- res %>% filter(visit_grp == input$visitGroups)
    # }
    # 
    # if(input$site != ''){
    #   res <- res %>% filter(site == input$site)
    # }
    # 
    # res 
    
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
  output$tMap <- renderLeaflet({
    l <- testPath %>%
      leaflet() %>%
      addTiles() %>%
      addPolylines(~lon, ~lat) %>%
      addPolygons(data=hbCont, 
                  fillOpacity = .2,
                  color = "grey") %>%
      addCircleMarkers(
        ~lon,
        ~lat,
        popup = ~orchid,
        label = ~id_order,
        radius = 5,
        fillColor = 'red',
        fillOpacity = 0.5,
        stroke = FALSE 
      ) %>%
      setView(lng = -71.746866, lat = 43.942395, zoom = 13)
  })
  
  ### Mapping ###
  
  # Import contour map: https://portal.edirepository.org/nis/mapbrowse?scope=knb-lter-hbr&identifier=91
  # hbCont <- vect('hbef_contusgs/hbef_contusgs.shp')
  hbCont <- st_read('hbef_contusgs/hbef_contusgs.shp')
  
  hbCont <- st_transform(hbCont, '+proj=longlat +datum=WGS84')
  
  # import hubbard brook 10m dem
  hbDEM_name <- "hbef_10mdem.tif"
  hbDEM <- raster(hbDEM_name)
  
  #testSub <- reactiveVal(data.frame())
  
  ##################### BUTTON ACTIONS
  #generate button
  observeEvent(input$generate, {
    updateNavbarPage(session, "inTabSet",
                     selected = "results")
    
    #testSub <- addedToList()
    #testSub <- filter(gps_loc, visit_grp == 2.5)
    
    ### Distance ###
    
    # Distance matrix
    dist_mat <- 
      dist(
        addedToList() %>% dplyr::select(lat, lon), # (swap back to 'lon, lat' when resolved) swapped to check if addedToList is empty/broken. Missing error received regardless of lat/lon position in select function.
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
    testPath <- addedToList() %>%
      mutate(id_order = order(as.integer(path)))
    
    ## Close the loop
    
    # Add new row with first orchid coords
    testPath <- testPath %>%
      arrange(id_order) %>%
      add_row(lat = as.double(testPath[testPath$id_order == 1, 7]), lon = as.double(testPath[testPath$id_order == 1, 8]))
    
    # Set as last point  
    testPath[nrow(testPath), 11] <- testPath[nrow(testPath) - 1, 11] + 1
    
    
    
  })
  
  #add to list button
  observeEvent(input$addAll, {
    addedToList(rbind(addedToList(),
                      filterData() %>% filter(orchid %in% filtered_orchid()$orchid) %>%
                        dplyr::select(orchid, visit_grp, site, Location_description, lat, lon) %>% distinct() ))
    
  })
  
  #clear list button 
  observeEvent(input$clearList, {
    addedToList(NULL)
  })
  
  
  
  ####################
  
  #filters
  observeEvent(input$visitGroups, {
    updateSelectizeInput(session, 'visitGroups', choices = c(Choose = '', sort(GPS_DataRAW$visit_grp)), selected = input$visitGroups, server = TRUE)
    
  })
  
  observeEvent(input$site, {
    updateSelectizeInput(session, 'site', choices = c(Choose = '', sort(GPS_DataRAW$site)), selected = input$site, server = TRUE)
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
  
  })

  