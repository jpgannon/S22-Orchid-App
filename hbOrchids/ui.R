#install.packages(leaflet)
#install.packages("googlesheets4")
#install.packages("shinythemes")

library(shiny)
library(leaflet)
library("googlesheets4")
library("shinythemes")


#MAKE SURE THE GOOGLE SHEETS PERMISSIONS ARE CHANGED TO "READABLE BY ANYONE WITH LINK"
gs4_deauth()

#reads data from google sheets
parking <- read_sheet("https://docs.google.com/spreadsheets/d/1tMqjQqi3NKxpOhHTp9JcWYGMEhGMWmAUsw8L6n_hiUE/edit#gid=1185719056")
orchid <- read_sheet("https://docs.google.com/spreadsheets/d/1Celap5Y1edXb2xly_9HDc9R7hdPIjZ8qPNwxh59PryM/edit?usp=sharing")


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
