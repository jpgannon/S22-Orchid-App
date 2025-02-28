library(shiny)
library(leaflet)
library("googlesheets4")
library("shinythemes")
library("shinyjs")
library(ggmap)
library(ggplot2)
library(raster)
library(sf)
library(dplyr)
library(tidyr)
library(TSP)
library(tidyverse)
library(rgdal)


jsCode <- 'shinyjs.winprint = function(){window.print();}'

#### Read-ins ###

# MAKE SURE THE GOOGLE SHEETS PERMISSIONS ARE CHANGED TO "READABLE BY ANYONE WITH LINK"
gs4_deauth()

# reads data from google sheets
# orchid <- read_sheet( ORCHID SHEET GOES HERE )

# parking <- read_sheet( PARKING SHEET GOES HERE )
# GPS_DataRAW <- read_sheet(sprintf( ORCHID SHEET GOES HERE ))
GPSData <- na.omit(GPS_DataRAW) 
gps_loc <- GPSData 


### Define UI for application maps orchid paths ####
shinyUI(fluidPage(
  
  navbarPage("Orchid Path Finder", id = "inTabSet", theme = shinytheme("flatly"),
             
             # Routes Page
             tabPanel("Routes", value = "routes",
                      # Top section: Filters, buttons, instructions
                      fluidRow(
                        column(6, 
                               
                               wellPanel(
                                 h3('Filter Orchids'),
                                 
                                 # Drop down input selections
                                 uiOutput('visitGroups'),
                                 uiOutput('site'),
                                 
                                 # Buttons
                                 actionButton("addSelected", "Add Selected",  style="color: #fff; background-color: #202b3d; border-color: #121721"),
                                 actionButton("addFiltered", "Add Filtered",  style="color: #fff; background-color: #202b3d; border-color: #121721"),
                                 actionButton('removeSelected', 'Remove Selected', style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                                 actionButton('removeAll', 'Remove All', style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                                 div(style="display:inline-block; float:right",disabled(actionButton("generate", "Generate", style="color: #fff; background-color: #202b3d; border-color: #121721")))
                                 
                                 
                                 
                               )
                        ),
                        column(6, 
                               HTML("<b> 1. Select Visit Group and Site from the filters </b> <br> </b> <br>
                                   
                                        <b> 2. Click on the orchids to select </b> <br> </b> <br>
                                       
                                        <b> 3. To add all filtered orchids, hit the 'Add Filtered' button. To add only selected orchids, click the 'Add Selected' button </b> <br>
                                         If the desired orchids are incorrect, use the 'Remove Selected' or 'Remove All' buttons </b> <br> </b> <br>
                                       
                                        <b> 4. Once the orchids are added, click the 'Generate' button to view the map </b> <br>
                                        The 'Generate' button will automatically take you to the 'Results' tab </b> <br> </b> <br>
                                       
                                        <b> 5. View the map and have fun visiting the orchids! </b> <br>
                                        Note: You can print the map using the 'Print Current Page' button. 
                                    ")
                        )
                      ),
                      
                      # Bottom section - All Orchids and Orchids to Visit table 
                      fluidRow(
                        # Orchid table
                        column(
                          6, h3('All Orchids'), 
                          hr(),
                          DT::dataTableOutput('orch')
                        ),
                        # Filtered orchids table
                        column(6, h3('Orchids to Visit'),
                               hr(),
                               #filtered selections
                               DT::dataTableOutput('addedToList')
                        ),
                        
                      )
                      
                      
             ),
             # Results page
             tabPanel("Results", value = "results",
                      leafletOutput(outputId = "tMap", height = 1000),
                      # outputs the map
                      
                      # Plot a map with the data and overlay the optimal path
                      fluidRow(
                        useShinyjs(),
                        extendShinyjs(text = jsCode, functions = c("winprint")),
                        actionButton("printPage", "Print Current Page")
                      ),
                      fluidRow(
                        
                        h3('Visit Order'),
                        hr(),
                        # DT::dataTableOutput('visitOrder'))
                        # verbatimTextOutput("pathOrderList", placeholder = FALSE))
                        textOutput("pathOrderList"),
                        
                        # Adds blank space to bottom of the page 
                        hr(style = "border-top: 1px solid #FFFFFF;"),
                        hr(style = "border-top: 1px solid #FFFFFF;"),
                        hr(style = "border-top: 1px solid #FFFFFF;"),
                        hr(style = "border-top: 1px solid #FFFFFF;")
                        
                      )
                      
                      
                      
                      
             ),
             tabPanel("About", value = "about",
                      navlistPanel("The Application",
                                   tabPanel("Background",
                                            HTML(" <b> Orchid Background </b> <br>
                                               Orchids are one of the two largest families of flowering plants, with over 25,000 species.
                                 At the Hubbard Brook Ecosystem Study, scientist Nat Cleavitt studies the growth of round leaved
                                 orchids in the Hubbard Brook Experimental Forest. Round leaved orchids are sensitive and susceptible
                                 to population declines, which makes them excellent indicators of ecosystem health. Individual orchids
                                 are measured over several years, with their leaf area, damage by herbivores or pathogens, and growth
                                 stage being recorded. </b> <br> </b> <br>
                                               
                                               <b> Objective </b> <br>
                                               Our objective is to create an application to generate optimal paths for visiting selected orchids.
                                 Cleavitt has logged over 1000 orchids in the Hubbard Brook Experimental Forest and needs to know the
                                 best route she should travel in order to save transit time and increase productivity.
                                               
                                               
                                               ")
                                            
                                            
                                            
                                   ),
                                   tabPanel("Developer Notes",
                                            HTML ("<b> Meet the Developers </b> <br>
                                                  This app was created by four Environmental Data Science Majors at Virginia Tech:
                                                  Arthur Cheung, Erin Kyle, Kira Lee, and Scott Braatz. We would like to thank Dr.
                                                  JP Gannon for his guidance throughout the semester to create this app. We hope that
                                                  this app can help the scientists at Hubbard Brook navigate to the orchids that they are
                                                  looking for! </b> <br>
                                                  </b> <br>
                                                 
                                                  <b> Learn More! </b> <br>
                                                  Hubbard Brook Website: https://hubbardbrook.org/ </b> <br>
                                                  Application Report: </b> <br>
                                                  </b> <br>
                                                 
                                                  <b> View our Map Data </b> <br>
                                                  Contour map: https://portal.edirepository.org/nis/mapbrowse?scope=knb-lter-hbr&identifier=91 </b> <br>
                                                 
                                                  "),
                                            
                                            
                                   )  
                      )
             )
  )
)
)