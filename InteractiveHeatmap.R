# Load required libraries
library(leaflet)
library(leaflet.extras)
library(ggplot2)
library(shiny)
library(maps)
library(mapdata)
library(dplyr)
library(zipcodeR)
library(tidyr)

data1 <- read.csv("./Leases.csv")

zipcodes <- merge(data1, zip_code_db %>% rename (zip = zipcode), by ='zip', all.X = T)
newdf <- zipcodes %>% drop_na(lat)

leaflet_density_heatmap <- function(data) {
  if (nrow(data) == 0) {
    return(
      leaflet() %>%
        addTiles() %>%
        addLabelOnlyMarkers(
          lng = 0, lat = 0,
          label = "No data available for the selected filters."
        )
    )
  }
  leaflet(data) %>%
    addTiles() %>%
    addHeatmap(
      lng = ~lng,
      lat = ~lat,
      radius = 10, 
      blur = 15,
      max = 0.5  
    ) %>%
    addProviderTiles("CartoDB.Positron")
}

ui <- fluidPage(
  titlePanel("CS Crocodiles Heatmap"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = "year",
        label = "Select Year:",
        choices = c("All", unique(newdf$year)),
        selected = "All"
      ),
      selectInput(
        inputId = "transaction_type",
        label = "Select Transaction Type:",
        choices = c("All", unique(newdf$transaction_type)),
        selected = "All"
      ),
      selectInput(
        inputId = "internal_industry",
        label = "Select Internal Industry:",
        choices = c("All", unique(newdf$internal_industry)),
        selected = "All"
      ),
    ),
    mainPanel(
      leafletOutput("heatmap", height = "600px")
    )
  )
)

server <- function(input, output, session) {
  filtered_data <- na.omit(reactive({
    newdf %>%
      filter(
        (input$year == "All" | year == input$year) &
        (input$transaction_type == "All" | transaction_type == input$transaction_type) &
        (input$internal_industry == "All" | internal_industry == input$internal_industry)
      ) 
    
  }))
  
  output$heatmap <- renderLeaflet({
    leaflet_density_heatmap(filtered_data())
  })
}

# Run the app
shinyApp(ui = ui, server = server)

