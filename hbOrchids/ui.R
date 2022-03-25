#install.packages(leaflet)
#install.packages("googlesheets4")
#install.packages("shinythemes")
#install.packages("shinyjs")


library(shiny)
library(leaflet)
library("googlesheets4")
library("shinythemes")
library("shinyjs")
library("shinyWidgets")

jsCode <- 'shinyjs.winprint = function(){
window.print();
}'


#MAKE SURE THE GOOGLE SHEETS PERMISSIONS ARE CHANGED TO "READABLE BY ANYONE WITH LINK"
gs4_deauth()

#reads data from google sheets
orchidTable <- read_sheet("https://docs.google.com/spreadsheets/d/1NfWv1cDVkh9sQYBmEr3FzMCyZ6mJ4k7JzkHNXD5Ti4Y/edit?usp=sharing")


# Define UI for application maps orchid paths
shinyUI(fluidPage(
  
  navbarPage("Orchid Path Finder", id = "inTabSet", theme = shinytheme("flatly"),
             
             #Routes Page
             tabPanel("Routes", value = "routes",
                      #section 1
                      fluidRow(
                        column(6, 
                               
                               wellPanel(
                                 h3('Filters'),
                                 
                                 #dropdown filters
                                 selectInput('visitGroups', 'Select Visit Group', choices = c(Choose = '',orchidTable$visit_grp), selectize = TRUE),
                                 selectInput('site', 'Select Site', choices = c(Choose = '', orchidTable$site), multiple = TRUE, selectize = TRUE),
                                 selectInput('subsite', 'Select sub-site', choices = c(Choose = '', orchidTable$sub_site), selectize =  TRUE),
                                 
                                 #buttons
                                 actionButton("addSelected", "Add Selected"),
                                 actionButton("addAll", "Add All"),
                                 actionButton('clearList', 'Clear All'),
                                 actionButton('removeSelected', 'Remove Selected'),
                                 actionButton("generate", "Generate")
                                 
                                 # selectizeGroupUI(
                                 #   id = "orchid-filters",
                                 #   inline = TRUE,
                                 #   params = list(site = list(inputId = "site", title = "Select Site", placeholder = 'select'),
                                 #                 visit_grp = list(inputID = "visit_grp", title = "Select Visit Group(s)", placeholder = "Select")
                                 #   ),
                                 # ),
                                 
                                 
                                 
                               )
                        ),
                        
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
                        ),
                        tableOutput("table")
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
                      
             ),
             
             # tabPanel("About", value = "about",
             #          navlistPanel("The Application",
             #                       tabPanel("Tutorial", ))
             #          
             #          
             #          )
             # 
             
  )
)
)