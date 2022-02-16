#install.packages(leaflet)
#install.packages("googlesheets4")


library(shiny)
library(leaflet)
library("googlesheets4")



# Define UI for application maps orchid paths
shinyUI(fluidPage(

    # Application title
    titlePanel("Orchid Path Finder"),
  
    #outputs the map
    leafletOutput("mapPlot"),
    
    hr(), #adds horizontal spacing
    
    #outputs a table, can make multiple selections
    column(
        6, h3('Parking Locations (placeholder)'), hr(),
        DT::dataTableOutput('x12')
    )
))
