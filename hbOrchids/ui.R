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
  navbarPage("Orchid Path Finder", id = "inTabSet", theme = shinytheme("flatly"),
             
             #Routes Page
             tabPanel("Routes", value = "routes",
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
                               actionButton("generate", "Generate"))
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
             tabPanel("Results", value = "results",
                      #outputs the map
                      leafletOutput("mapPlot"),
                      fluidRow(
                        column(6, h3('Selected Orchids')),
                        column(6, h3('Directions'))
                      ),
                      
             ),
             
             tabPanel("Print", value = "printResults",
                      headerPanel(title = "PDF Export"),
                      sidebarLayout(
                        sidebarPanel(
                          
                        ),
                        mainPanel(
                          tabsetPanel(type = "tab",
                                      tabPanel("pdf", tags$iframe(style = "height:400px; width:100%;scrolling = yes", src = "qlik.pdf")))
                        )
                      ))
  )
  
))
