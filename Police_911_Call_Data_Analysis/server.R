#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(jsonlite)
library(dplyr)
library(tidyr)
library(plotly)
library(shiny)
library(leaflet)


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
              
  
              #------------------------------------------------------------------
              #Validate input dates
              output$validMsg <- renderPrint({
                shiny::validate(
                  need(input$date_range[2] >= input$date_range[1], "End date cannot be earlier than Start date!")
                )
                paste("Dates selected are",input$date_range[1],"and",input$date_range[2])
              })
  
              #------------------------------------------------------------------
              # Here is the Baltimore gov json api end site https://data.baltimorecity.gov/resource/m8g9-abgb.json
              rawcalldata <- reactive({
                if  (input$date_range[2] >= input$date_range[1]) { 
                    Link <- URLencode(paste0("https://data.baltimorecity.gov/resource/m8g9-abgb.json?$where=date_trunc_ymd(calldatetime) between '",input$date_range[1],"' AND '",input$date_range[2],"'&$limit=5000000",sep=""))
                    #browser()
                    #cat(file=stderr(),"Built URL Link is ",Link)
                    data1 <- jsonlite::fromJSON(Link,flatten=T)
                }
              })
              
              # Prepare and render "Data tab"
              disData <- reactive({
                if  (input$date_range[2] >= input$date_range[1]) { 
                    head(rawcalldata(),15)
                }
              })
              
              output$displayData <- renderPrint({
                disData()
              })
              
              # Prepare and render "Plot for Calls Type"
              callsType <- reactive({
              # browser()
                if  (input$date_range[2] >= input$date_range[1]) { 
                  data2 <- rawcalldata() %>% 
                            group_by(calldesc=description) %>% 
                            summarise(callcount=n()) %>% 
                            arrange(desc(callcount))
                  data2$calldesc <- factor(data2$calldesc,levels=unique(data2$calldesc)[order(data2$callcount,decreasing=FALSE)])
                  data.frame(data2)
                }
              })
              
              output$barplot1 <- renderPlotly({
                plot_ly(head(callsType(),50),x=~callcount,y=~calldesc,type='bar')%>%
                  layout(title=paste("911 Call Types placed in Baltimore, MD (during period ",input$date_range[1]," to ",input$date_range[2]," )",sep=""),
                         margin=list(l=250,r=50,b=85,t=50,pad=2,autoexpand=TRUE),
                         yaxis=list(title="",tickfont=list(size=7)),
                         xaxis=list(title="Calls Count"))
              })  
              
              # Prepare and render "Plot for Calls Per Day"
              callsDay <- reactive({
                # browser()
                if  (input$date_range[2] >= input$date_range[1]) { 
                  data3 <- rawcalldata() %>% dplyr::group_by(calldate=lubridate::date(calldatetime)) %>% dplyr::summarise(calldaycount=n())
                }
              })
              
              output$areaplot1 <- renderPlotly({
                plot_ly(callsDay(),x=~calldate,y=~calldaycount,type='scatter',mode='lines',fill='tozeroy',fillcolor="rgba(0,0,255,0.2)")%>%
                  layout(title=paste("911 Calls placed per Day in Baltimore, MD over period ",input$date_range[1]," to ",input$date_range[2],sep=""),
                         margin=list(l=45,r=20,b=55,t=30,pad=0),
                         font=list(size=10),
                         yaxis=list(title="Calls per Day Count",tickfont=list(size=8)),
                         xaxis=list(title="Calls Count",tickfont=list(size=9),tickangle=45,tickformat="%b %d %Y"))
              })  
              
              # Prepare and render "Plot for Calls Per Hour"
              callsHour <- reactive({
                # browser()
                if  (input$date_range[2] >= input$date_range[1]) { 
                  data4 <- rawcalldata() %>% 
                            group_by(callhour=format(as.POSIXct(strptime(calldatetime,"%Y-%m-%dT%H:%M:%S",tz="")),format="%H:%M")) %>% 
                            summarise(calldaycount=n())
                }
              })
              
              output$areaplot2 <- renderPlotly({
                plot_ly(callsHour(),x=~callhour,y=~calldaycount,type='scatter',mode='lines',fill='tozeroy',fillcolor="rgba(0,255,0,0.2)") %>%
                  layout(title=paste("911 Calls placed per Hour in Baltimore, MD over period ",input$date_range[1]," to ",input$date_range[2],sep=""),
                         margin=list(l=45,r=20,b=40,t=30,pad=0),
                         font=list(size=9),
                         yaxis=list(title="Calls per Hour Count",tickfont=list(size=8)),
                         xaxis=list(title="Calls Count",tickfont=list(size=7),tickangle=45))
              })  
              
              # Prepare and render "Map Plot"
              mapcalls <- reactive({
                #browser()
                if  (input$date_range[2] >= input$date_range[1]) { 
                  data5 <- na.omit(rawcalldata()[!is.na(rawcalldata()$location.type),])
                  data6 <- tidyr::separate(data=data5,
                                           col=location.coordinates,
                                           into=c("longitude", "latitude"),
                                           sep=",",
                                           remove=FALSE)
                  data6$longitude <- as.numeric(gsub("c\\(","",data6$longitude))
                  data6$latitude <- as.numeric(gsub("\\)","",data6$latitude))
                  data.frame(data6)
                }
              })
              
              
              output$callsmap <- renderLeaflet({
                  #browser()
                  leaflet(mapcalls()) %>% 
                    addTiles() %>% 
                    addMarkers(lng=~longitude,lat=~latitude,
                               popup=paste("CallDesc:",mapcalls()$description,"<br>","Location:",mapcalls()$incidentlocation,"<br>","CallTime:",mapcalls()$calldatetime,"<br>","Recordid:",mapcalls()$recordid),
                               clusterOptions=markerClusterOptions())
              }) 
              
})
