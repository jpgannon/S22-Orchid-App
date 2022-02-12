#install.packages(leaflet)

library(shiny)
library(leaflet)




# Define UI for application maps orchid paths
shinyUI(fluidPage(

    # Application title
    titlePanel("Orchid Path Finder"),
  
    #outputs the map
    leafletOutput("mapPlot")
   
    
    
))
