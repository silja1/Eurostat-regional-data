#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Eurostat regional data"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       selectInput("feature", "Choose a feature:",
                   choices = (c("Current_population","Population_density","Employed_persons_th", "Gross_Domestic_Product"))
       ),
       submitButton('Submit')
       
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Plot", plotOutput("distPlot")),
        tabPanel("Help",       
                 h2("Regional level data from Eurostat databases exploration"),
                 h3("How to use the app:"),
                 p("Select a feature you want to visualize from the sidebar and press Submit."),
                 p("Please wait until graph loads, this may take a whil due to downloading data from Eurostat."),
                 h3("How the app works:"),
                 p("The app uses the 'eurostat' package to download several NUTS3 level datasets from Eurostat, matches it up to spatial polygon data for Europe and visualized the parameters")
                 )
      )
       
    )
  )
))
