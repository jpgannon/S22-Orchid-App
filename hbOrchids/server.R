#install.packages("googlesheets4")
#install.packages("leaflet.providers")
#install.packages("DT")

library(shiny)
library(leaflet)
library("googlesheets4")
library("DT")
library("tidyverse")

gs4_deauth()
#parking <- read_sheet("https://docs.google.com/spreadsheets/d/1tMqjQqi3NKxpOhHTp9JcWYGMEhGMWmAUsw8L6n_hiUE/edit#gid=1185719056")
orchid <- read_sheet("https://docs.google.com/spreadsheets/d/1Celap5Y1edXb2xly_9HDc9R7hdPIjZ8qPNwxh59PryM/edit?usp=sharing")

# Define server logic required to draw a map, calculate best paths
shinyServer(function(input, output, session) {
    
    #making reactive orchid table 
    filterData = reactiveVal(orchid %>% mutate(key = 1:nrow(orchid)))
    addedToList = reactiveVal(data.frame())
    
    filtered_orchid <- reactive({
        res <- orchid
        if(is.na(input$site) == FALSE | is.na(input$visitGroups) == FALSE ){
            
            res <- filterData() %>% filter(site == input$site | is.na(input$site))
            res <- filterData() %>% filter(visit_grp == input$visitGroups | is.na(input$visitGroups))
            
            # if(is.na(input$site) == TRUE & is.na(input$visitGroups) == TRUE ){
            #   res <- filterData()
        }
        res
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
    
    #BUTTON ACTIONS
    #generate button
    observeEvent(input$generate, {
        updateNavbarPage(session, "inTabSet",
                         selected = "results")
    })
    
    #add to list button
    observeEvent(input$addList, {
        addedToList(rbind(addedToList(),
                          filterData() %>% filter(key %in% filtered_orchid()$key) %>%
                              select(orchid_id) %>% distinct() ))
        
        filterData(filterData() %>% filter(!key %in% filtered_orchid()$key))
    })
    
    #updates addedToList table
    output$addedToList <- renderDataTable({
        addedToList()
    })
    
    #r doesn't support multiple outputs w/ same name, have to make a copy of the table
    output$addedToList2 <- renderDataTable({
        addedToList()
    })
    
    # outputs a table
    # output$orch = DT::renderDataTable(orchid[1:5],
    #                                   colnames = c("Orchid ID", "Associated Orchids", "Site", "Location Description", "Visit Group"),
    #                                   filter = "top", server = FALSE)
    # 
    
    
})
