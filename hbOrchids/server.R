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

gs4_deauth()
orchid <- read_sheet("https://docs.google.com/spreadsheets/d/1Celap5Y1edXb2xly_9HDc9R7hdPIjZ8qPNwxh59PryM/edit?usp=sharing")

# Define server logic required to draw a map, calculate best paths
shinyServer(function(input, output, session) {
  
  
  
  #making reactive orchid table 
  filterData = reactiveVal(orchid %>% mutate(key = 1:nrow(orchid)))
  addedToList = reactiveVal(data.frame())
  
  filtered_orchid <- reactive({

    #if(is.na(input$site) == FALSE | is.na(input$visitGroups) == FALSE ){

      res <- filterData() %>% filter(site == input$site | is.na(input$site))
      res <- res %>% filter(visit_grp == input$visitGroups | is.na(input$visitGroups))
      
      # if(is.na(input$site) == TRUE & is.na(input$visitGroups) == TRUE ){
      #   res <- filterData()
    #}

    #rename columns
    res_names <- res %>%   
      rename("Orchid ID" = orchid_id,
             "Associated Orchid(s)" = orchid_associated,
             "Site" = site,
             "Visit Group" = visit_grp,
             "Location Description" = Location_description
             )
    res_names
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
      setView(lng = -71.746866, lat = 43.942395, zoom = 13)  %>% #sets location
      addMarkers(lng = orchid$lon,
                 lat = orchid$lat,
                 label = orchid$orchid_id)
  })
  
  # #plots points, reactively?
  # observe({
  #     req(input$tab_being_displayed == 'results')
  #     leafletProxy("mapPlot", data = orchid) %>%
  #         clearMarkers() %>% #clear previous markers
  #         addMarkers()
  # })
  
  ##################### BUTTON ACTIONS
  #generate button
  observeEvent(input$generate, {
    updateNavbarPage(session, "inTabSet",
                     selected = "results")
  })
  
  #add to list button
  observeEvent(input$addAll, {
    addedToList(rbind(addedToList(),
                      filterData() %>% filter(key %in% filtered_orchid()$key) %>%
                        select(orchid_id, site, visit_grp, Location_description) %>% distinct() ))
    
    #filterData(filterData() %>% filter(!key %in% filtered_orchid()$key))
  })
  
  #clear list button
  observeEvent(input$clearList, {

    addedToList(NULL)
    # addedToList
  })
  

  
  ####################
  
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
