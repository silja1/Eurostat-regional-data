#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  library(eurostat)
  library(dplyr)
  library(ggplot2)
  library(stringr)
  library(sp)
  library(plotly)
  # Data from Eurostat
  current_pop <- get_eurostat("demo_r_pjangrp3", time_format = "num", stringsAsFactors = FALSE) %>%
    filter(time == 2016& 
             sex == "T"& 
             nchar(geo) == 5&
             age == "TOTAL") %>% 
    select(-unit,-sex,-age,-time) %>% 
    rename(Current_population = values)
  
  density <- get_eurostat("demo_r_d3dens", time_format = "num", stringsAsFactors = FALSE)%>%
    filter(time == 2015& 
             nchar(geo) == 5) %>% 
    select(-unit,-time) %>% 
    rename(Population_density= values)
  
  employment <- get_eurostat("nama_10r_3empers", time_format = "num", stringsAsFactors = FALSE)%>%
    filter(time == 2014& 
             nchar(geo) == 5&wstatus=="EMP"&nace_r2=="TOTAL") %>% 
    select(-unit,-time) %>% 
    rename(Employed_persons_th= values)
  
  gdp <- get_eurostat("nama_10r_3gdp", time_format = "num", stringsAsFactors = FALSE)%>%
    filter(time == 2014& 
             nchar(geo) == 5&unit=="EUR_HAB") %>% 
    select(-unit,-time) %>% 
    rename(Gross_Domestic_Product= values)
  
  
  library(sp)
  library(rgdal)
  EU_NUTS = readOGR(dsn =  "./NUTS_2013_20M_SH/data", layer = "NUTS_RG_20M_2013")
  EU_NUTS <- spTransform(EU_NUTS, CRS("+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"))
  EU_NUTS  <- subset(EU_NUTS, STAT_LEVL_ == 3) 
  
  country <- substring(as.character(EU_NUTS$NUTS_ID), 1, 2)
  map <- c("EE", "LV", "LT", "SE")
  EU_NUTS_Swb <- EU_NUTS[country %in% map,]
  
  EU_NUTS_Swb@data = left_join(data.frame(EU_NUTS_Swb@data),current_pop,by=c("NUTS_ID"="geo"))
  EU_NUTS_Swb@data = left_join(data.frame(EU_NUTS_Swb@data),density,by=c("NUTS_ID"="geo"))
  EU_NUTS_Swb@data = left_join(data.frame(EU_NUTS_Swb@data),employment,by=c("NUTS_ID"="geo"))
  EU_NUTS_Swb@data = left_join(data.frame(EU_NUTS_Swb@data),gdp,by=c("NUTS_ID"="geo"))
  
  library(RColorBrewer)
    my.palette <- brewer.pal(n = 9, name = "Blues")
    plot_data<-EU_NUTS_Swb@data%>%
    mutate(country=substr(NUTS_ID,1,2))
    output$distPlot <- renderPlot({
    feature<-input$feature
    spplot(EU_NUTS_Swb,zcol=feature ,col.regions = my.palette, cuts = 8,main=paste0(sub("_"," ", feature)," in Sweden and Baltics on NUTS3 level"))
    
  })
  

})
