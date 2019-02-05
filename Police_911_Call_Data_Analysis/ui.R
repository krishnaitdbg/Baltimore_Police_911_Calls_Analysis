#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(plotly)
library(shiny)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel(title = h2("Real Time Analysis of 911 Calls placed to Baltimore PD, MD", align="center")),
  br(),   br(),
  
  # Sidebar with options to select 
  sidebarLayout(
    sidebarPanel(h4("Select Options"),
                 #--------------------------------------------------------------------
                 # Add data range input for selecting from & to dates o pull json data
                 dateRangeInput("date_range", "Date range:",
                                start  = "2019-01-01",
                                end    = NULL,
                                min    = "2015-01-01",
                                max    = NULL,
                                format = "yyyy-mm-dd",
                                separator = " - "),
                 #--------------------------------------------------------------------
                 # Help text
                 helpText("Input Validation Message:"),
                 #--------------------------------------------------------------------
                 # After submitting your input values, validate them and return validation message
                 # or textOutput("validMsg")
                 verbatimTextOutput("validMsg",placeholder = FALSE),
                 #--------------------------------------------------------------------
                 # adding the data source tag to the sidebar            
                 tags$div(class="header", checked=NA,
                          tags$p("Data Source:"),
                          tags$a(href="https://data.baltimorecity.gov/Public-Safety/911-Police-Calls-for-Service/xviu-ezkt", "Open Baltimore Data Gov Site Click Here!")
                 ),br(),
                 #--------------------------------------------------------------------
                 # adding the code source tag to the sidebar            
                 tags$div(class="header", checked=NA,
                          tags$p("Code Source:"),
                          tags$a(href="https://github.com/krishnaitdbg/Baltimore_Police_911_Calls_Analysis", "Code Source Click Here!")
                 )
                ),
    mainPanel(
                  #------------------------------------------------------------------
                  # Create tab panes
                  tabsetPanel(type="tab",
                  tabPanel("Data", verbatimTextOutput("displayData")),
                  tabPanel("Plot for Calls Type", plotlyOutput("barplot1")),
                  tabPanel("Plot for Calls Per Day", plotlyOutput("areaplot1")), 
                  tabPanel("Plot for Calls Per Hour", plotlyOutput("areaplot2")),
                  tabPanel("Map Plot", leafletOutput("callsmap"))
                  )
              )
          )
))
