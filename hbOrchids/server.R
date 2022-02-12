#install.packages("googlesheets4")
#install.packages("leaflet.providers")
#install.packages("leaflet.providers")

#shiny leaflet tutorial
#https://github.com/SimonGoring/ShinyLeaflet-tutorial/blob/master/Shiny-leaflet-tutorial.Rmd

library(shiny)
library(leaflet)
library("googlesheets4")


#read parking lot google sheet
#parking <- read_sheet("https://docs.google.com/spreadsheets/d/1tMqjQqi3NKxpOhHTp9JcWYGMEhGMWmAUsw8L6n_hiUE/edit#gid=1185719056")

# Define server logic required to draw a map, calculate best paths
shinyServer(function(input, output) {

  output$mapPlot <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Stamen.Terrain) %>% #sets basemap
      setView(lng = -71.746866, lat = 43.942395, zoom = 15)  #sets location
  })
  

})
