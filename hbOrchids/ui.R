#install.packages(leaflet)
#install.packages("googlesheets4")
#install.packages("shinythemes")

library(shiny)
library(leaflet)
library("googlesheets4")
library("shinythemes")




# Define UI for application maps orchid paths
shinyUI(fluidPage(
  
  navbarPage("Orchid Path Finder", theme = shinytheme("flatly"),
             #Routes Page
             tabPanel("Routes",
                      #section 1
                      fluidRow(
                        column(6, 
                               #dropdown filters
                               wellPanel(
                                 h3('Filters'),
                                 selectInput('visitGroups', 'Select Visit Group', choices = c("",orchid$visit_grp)),
                                 selectInput('site', 'Select Site', choices = c("",orchid$site))
                               )
                        ),
                        column(3, 
                               br(), #vertical spacing
                               br(),
                               br(),
                               actionButton("selectAll", "Select All"),
                               actionButton("addList", "Add to List")),
                        column(3,
                               br(),
                               br(),
                               br(),
                               actionButton("resultsPage", "Generate"))
                      ),
                      
                      #section 2
                      fluidRow(
                        #outputs a table, can make multiple selections
                        column(
                          6, h3('Orchids'), 
                          hr(),
                          DT::dataTableOutput('orch')
                        ),
                        column(6, h3('Selected Orchids'),
                               hr(),
                               #filtered selections
                        )
                      )
                      
                      
             ),
             #Results page
             tabPanel("Results",
                      #outputs the map
                      leafletOutput("mapPlot"))
  )
  
))
