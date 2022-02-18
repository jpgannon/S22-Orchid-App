#install.packages(leaflet)
#install.packages("googlesheets4")


library(shiny)
library(leaflet)
library("googlesheets4")



# Define UI for application maps orchid paths
shinyUI(fluidPage(

    # Application title
    titlePanel("Orchid Path Finder"),

    fluidRow(
      column(9, verbatimTextOutput('x4')),
      
      
      #outputs a table, can make multiple selections
      column(
        3, h3('Parking Locations (placeholder)'), hr(),
        DT::dataTableOutput('x12')
      )
      
    ),
    
    hr(), #adds horizontal spacing
    
    #outputs the map1
    
    leafletOutput("mapPlot")
))
