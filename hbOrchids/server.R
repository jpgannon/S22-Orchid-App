#install.packages("googlesheets4")
#install.packages("leaflet.providers")
#install.packages("DT")

library(shiny)
library(leaflet)
library("googlesheets4")
library("DT")

#read parking lot google sheet
parking <- read_sheet("https://docs.google.com/spreadsheets/d/1tMqjQqi3NKxpOhHTp9JcWYGMEhGMWmAUsw8L6n_hiUE/edit#gid=1185719056")

# Define server logic required to draw a map, calculate best paths
shinyServer(function(input, output) {

    #creates the basemap
    output$mapPlot <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$Esri.NatGeoWorldMap) %>% #sets basemap
            setView(lng = -71.746866, lat = 43.942395, zoom = 13)  #sets location
        })
    
    #plots points
    leafletProxy("mapPlot") %>% clearMarkers() %>%
        addMarkers(lng = parking$lon,
                         lat = parking$lat,
                         popup = parking$parking)
    
    # outputs a table
    output$x12 = DT::renderDataTable(parking,  filter = 'top', server = FALSE)
    
    
    
    values <- reactiveValues()
    values <- reactive(input$x12_rows_selected)

})
