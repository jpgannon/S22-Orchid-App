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
                                 # dropdown selections
                                 selectInput('visitGroups', 'Select Visit Group', choices = NULL),
                                 selectInput('site', 'Select Site(s)', choices = NULL),
                                 
                                 #buttons
                                 #actionButton("addSelected", "Add Selected"),
                                 actionButton("addAll", "Add All"),
                                 actionButton('removeSelected', 'Remove Selected'),
                                 actionButton('clearList', 'Remove All'),
                                 actionButton("generate", "Generate")
                                 
                                 
                                 
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
             
             tabPanel("App Guide", value = "appGuide",
                      navlistPanel("The Application",
                                   tabPanel("User Guide",  h3("How to Use the App"),
                                            h4("Users can select visit groups and sites using the filters on
                                    the Select Orchid page. After the desired orchids are filtered, a table will automatically fill that has
                                    more information on the orchids. From here, the user can click on 
                                    the add all button. Once this button is clicked, the filtered orchids will populate the Selected Orchids
                                    table. Once the user has verified that these orchids are correct, click generate. This will automatically
                                    take the user to another page that shows the quickest path to travel to visit all selected orchids. The page
                                    is printable. ")
                                   ),
                                   tabPanel("Background",
                                            h4("Orchids are one of the two largest families of flowering plants, with over 25,000 species.
                                 At the Hubbard Brook Ecosystem Study, scientist Nat Cleavitt studies the growth of round leaved
                                 orchids in the Hubbard Brook Experimental Forest. Round leaved orchids are sensitive and susceptible
                                 to population declines, which makes them excellent indicators of ecosystem health. Individual orchids
                                 are measured over several years, with their leaf area, damage by herbivores or pathogens, and growth
                                 stage being recorded.

                                 Our objective is to create an application to generate optimal paths for visiting selected orchids.
                                 Cleavitt has logged over 1000 orchids in the Hubbard Brook Experimental Forest and needs to know the
                                 best route she should travel in order to save transit time and increase productivity.
")
                                   ),
                                   tabPanel("Developer Notes",
                                            h4("This app was created for Virginia Tech's 2022 Senior Capstone project for Environmental Data Science majors. This 
                                            project was managed by Dr. J.P. Gannon and the app was created by Scott Braatz, Arthur Cheung,
                                            Erin Kyle, and Kira Lee. Developed for the scientists at Hubbard Brook, we hope that this application can help people 
                                               navigate to the orchids that they are looking for.")
                                   )
                      )
                      
                      
             )
             
             
  )
)
)