#install.packages("googlesheets4")
#install.packages("leaflet.providers")
#install.packages("DT")

library(shiny)
library(leaflet)
library("googlesheets4")
library("DT")


#MAKE SURE THE GOOGLE SHEETS PERMISSIONS ARE CHANGED TO "READABLE BY ANYONE WITH LINK"
gs4_deauth()

#reads data from google sheets
parking <- read_sheet("https://docs.google.com/spreadsheets/d/1tMqjQqi3NKxpOhHTp9JcWYGMEhGMWmAUsw8L6n_hiUE/edit#gid=1185719056")
orchid <- read_sheet("https://docs.google.com/spreadsheets/d/1Celap5Y1edXb2xly_9HDc9R7hdPIjZ8qPNwxh59PryM/edit?usp=sharing")

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
        addMarkers(lng = orchid$lon,
                         lat = orchid$lat,
                         popup = orchid$orchid_id)
    
    
    # outputs a table
    output$orch = DT::renderDataTable(orchid[1:5], filter = "top", server = FALSE)
    
    # output$x4 = renderPrint({
    #   s = input$x12_rows_selected
    # }) 

})
