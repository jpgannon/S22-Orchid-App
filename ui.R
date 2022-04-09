#install.packages(leaflet)
#install.packages("googlesheets4")
#install.packages("shinythemes")
#install.packages("shinyjs")

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

#MAKE SURE THE GOOGLE SHEETS PERMISSIONS ARE CHANGED TO "READABLE BY ANYONE WITH LINK"
gs4_deauth()

#reads data from google sheets
orchid <- read_sheet("https://docs.google.com/spreadsheets/d/1Celap5Y1edXb2xly_9HDc9R7hdPIjZ8qPNwxh59PryM/edit?usp=sharing")
id <- "1bjt4aQPfbz1rzFeDeF3cKsrLvbuHDfA4"
# https://docs.google.com/spreadsheets/d/1tMqjQqi3NKxpOhHTp9JcWYGMEhGMWmAUsw8L6n_hiUE/edit?usp=sharing
parking <- read_sheet("https://docs.google.com/spreadsheets/d/1tMqjQqi3NKxpOhHTp9JcWYGMEhGMWmAUsw8L6n_hiUE/edit?usp=sharing")
GPS_DataRAW <- read_sheet(sprintf("https://docs.google.com/spreadsheets/d/1NfWv1cDVkh9sQYBmEr3FzMCyZ6mJ4k7JzkHNXD5Ti4Y/edit?usp=sharing", id))
GPSData <- na.omit(GPS_DataRAW) 
gps_loc <- GPSData 

#### Cleaning ###

# import hubbard brook 10m dem
# hbDEM_name <- "hbef_10mdem.tif"
# hbDEM <- raster(hbDEM_name)

### Define UI for application maps orchid paths ####
shinyUI(fluidPage(
  
  navbarPage("Orchid Path Finder", id = "inTabSet", theme = shinytheme("flatly"),
             
             #Routes Page
             tabPanel("Routes", value = "routes",
                      #section 1
                      fluidRow(
                        column(6, 
                               
                               wellPanel(
                                 h3('Filter Orchids'),
                                 
                                 #server side attempt
                                 uiOutput('visitGroups'),
                                 uiOutput('site'),
                                 
                                 #buttons
                                 actionButton("addSelected", "Add Selected"),
                                 actionButton("addAll", "Add All"),
                                 actionButton('removeSelected', 'Remove Selected'),
                                 actionButton('clearList', 'Clear All'),
                                 div(style="display:inline-block; float:right",disabled(actionButton("generate", "Generate")))
                                 
                                 
                                 
                               )
                        )
                      ),
                      
                      #section 2
                      fluidRow(
                        # Orchid table
                        column(
                          6, h3('Orchids'), 
                          hr(),
                          DT::dataTableOutput('orch')
                        ),
                        # Filtered orchids table
                        column(6, h3('Selected Orchids'),
                               hr(),
                               #filtered selections
                               DT::dataTableOutput('addedToList')
                        ),
                        
                      )
                      
                      
             ),
             #Results page
             tabPanel("Results", value = "results",
                      leafletOutput(outputId = "tMap", height = 1000),
                      #outputs the map
                      
                      # Plot a map with the data and overlay the optimal path
                      fluidRow(
                        useShinyjs(),
                        extendShinyjs(text = jsCode, functions = c("winprint")),
                        actionButton("printPage", "Print Current Page")
                      ),
                      fluidRow(
                        
                        h3('Visit Order'), 
                        hr(), 
                        DT::dataTableOutput('visitOrder'))
                      
                      
                      
             ),
             tabPanel("About", value = "about",
                      navlistPanel("The Application",
                                   tabPanel("Tutorial",  
                                            HTML("<b> 1. Select Visit Group and Site from the filters </b> <br> </b> <br>
                                   
                                        <b> 2. Click on the orchids that you want to select </b> <br> </b> <br>
                                       
                                        <b> 3. To select all orchids, hit the 'Add All' button </b> <br>
                                        To only select some orchids, choose the add selected button </b> <br> </b> <br>
                                       
                                        <b> 4. Once the orchids are selected, click the 'Generate' button to view the map </b> <br>
                                        If the desired orchids are incorrect, use the 'Remove Selected' or 'Clear All' filters </b> <br> </b> <br>
                                       
                                        <b> 5. The 'Generate' button will automatically take you to the 'Results' tab </b> <br>
                                        You can also view the 'Results' tab by clicking on it at the top of the screen. </b> <br> </b> <br>
                                       
                                        <b> 6. View the map and have fun visiting the orchids! </b> <br>
                                        Note: You can print the map using the 'Print Current Page' button.
                                         
                                        "),
                                            
                                   ),
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