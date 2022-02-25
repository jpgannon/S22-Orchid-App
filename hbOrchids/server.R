#install.packages("googlesheets4")
#install.packages("leaflet.providers")
#install.packages("DT")

library(shiny)
library(leaflet)
library("googlesheets4")
library("DT")
library("tidyverse")

gs4_deauth()
parking <- read_sheet("https://docs.google.com/spreadsheets/d/1tMqjQqi3NKxpOhHTp9JcWYGMEhGMWmAUsw8L6n_hiUE/edit#gid=1185719056")
orchid <- read_sheet("https://docs.google.com/spreadsheets/d/1Celap5Y1edXb2xly_9HDc9R7hdPIjZ8qPNwxh59PryM/edit?usp=sharing")

# Define server logic required to draw a map, calculate best paths
shinyServer(function(input, output, session) {
  
  filterData = reactiveVal(orchid %>% mutate(key = 1:nrow(orchid)))
  addedToList = reactiveVal(data.frame())
  
  filtered_orchid <- reactive({
    res <- filterData() %>% filter(site >= input$site)
    res <- filterData() %>% filter(visit_grp >= input$visitGroups)
    
    res
  })
  
  
  #creates the basemap
  output$mapPlot <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Esri.WorldTopoMap) %>% #sets basemap
      setView(lng = -71.746866, lat = 43.942395, zoom = 13)  %>% #sets location
      addMarkers(lng = orchid$lon,
                 lat = orchid$lat,
                 popup = orchid$orchid_id)
  })
  
  # #plots points
  # leafletProxy("mapPlot") %>% clearMarkers() %>%
  #   addMarkers(lng = orchid$lon,
  #              lat = orchid$lat,
  #              popup = orchid$orchid_id)
  
  #button actions
  observeEvent(input$generate, {
    updateNavbarPage(session, "inTabSet",
                     selected = "results")
  })
  
  
  
  # outputs a table
  output$orch = DT::renderDataTable(orchid[1:5], 
                                    colnames = c("Orchid ID", "Associated Orchids", "Site", "Location Description", "Visit Group"),
                                    filter = "top", server = FALSE)
  
  
  
})
