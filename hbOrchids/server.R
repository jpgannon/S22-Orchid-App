#install.packages("googlesheets4")
#install.packages("leaflet.providers")
#install.packages("DT")

library(shiny)
library(leaflet)
library("googlesheets4")
library("DT")



# Define server logic required to draw a map, calculate best paths
shinyServer(function(input, output) {

    #creates the basemap
    output$mapPlot <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$Esri.WorldTopoMap) %>% #sets basemap
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
