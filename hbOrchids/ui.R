#install.packages(leaflet)
#install.packages("googlesheets4")
#install.packages("shinythemes")
#install.packages("shinyjs")

library(shiny)
library(leaflet)
library("googlesheets4")
library("shinythemes")
library("shinyjs")

jsCode <- 'shinyjs.winprint = function(){
window.print();
}'


#MAKE SURE THE GOOGLE SHEETS PERMISSIONS ARE CHANGED TO "READABLE BY ANYONE WITH LINK"
gs4_deauth()

#reads data from google sheets
orchid <- read_sheet("https://docs.google.com/spreadsheets/d/1Celap5Y1edXb2xly_9HDc9R7hdPIjZ8qPNwxh59PryM/edit?usp=sharing")


# Define UI for application maps orchid paths
shinyUI(fluidPage(
  
  navbarPage("Orchid Path Finder", id = "inTabSet", theme = shinytheme("flatly"),
             # tabPanel("Introduction", value = "intro"
             #          ),
             #Routes Page
             tabPanel("Routes", value = "routes",
                      #section 1
                      fluidRow(
                        column(6, 
                               #dropdown filter
                               wellPanel(
                                 h3('Filters'),
                                 selectInput('visitGroups', 'Select Visit Group', choices = c("",orchid$visit_grp)),
                                 selectInput('site', 'Select Site', choices = c("",orchid$site)),
                                 actionButton("addSelected", "Add Selected"),
                                 actionButton("addAll", "Add All")
                               )
                        ),
                        column(3, 
                      
                               actionButton('clearList', 'Clear List'),
                               br(),
                               br(),
                               actionButton('removeSelected', 'Remove Selected')),
                        column(3,
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
                               DT::dataTableOutput('addedToList')
                        )
                      )
                      
                      
             ),
             #Results page
             tabPanel("Results", value = "results",
                      #outputs the map
                      leafletOutput("mapPlot"),
                      fluidRow(
                        column(6, h3('Selected Orchids'),
                               hr(),
                               DT::dataTableOutput('addedToList2')),
                        column(6, h3('Directions'))
                      ),
                      fluidRow(
                        useShinyjs(),
                        extendShinyjs(text = jsCode, functions = c("winprint")),
                        actionButton("printPage", "Print Current Page")
                      )
                      
             )
  )         
))
