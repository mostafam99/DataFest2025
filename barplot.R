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

data2018 <- data1 %>% filter(year==2018)
quarters2018 <- count(data2018,quarter)
data2019 <- data1 %>% filter(year==2019)
quarters2019 <- count(data2019,quarter)
data2020 <- data1 %>% filter(year==2020)
quarters2020 <- count(data2020,quarter)
data2021 <- data1 %>% filter(year==2021)
quarters2021 <- count(data2021,quarter)
data2022 <- data1 %>% filter(year==2022)
quarters2022 <- count(data2022,quarter)
data2023 <- data1 %>% filter(year==2023)
quarters2023 <- count(data2023,quarter)
data2024 <- data1 %>% filter(year==2024)
quarters2024 <- count(data2024,quarter)

quarters2018$Year <- 2018
quarters2018 <- quarters2018[, c("Year", names(quarters2018)[-ncol(quarters2018)])]

quarters2019$Year <- 2019
quarters2019 <- quarters2019[, c("Year", names(quarters2019)[-ncol(quarters2019)])]

quarters2020$Year <- 2020
quarters2020 <- quarters2020[, c("Year", names(quarters2020)[-ncol(quarters2020)])]

quarters2021$Year <- 2021
quarters2021 <- quarters2021[, c("Year", names(quarters2021)[-ncol(quarters2021)])]

quarters2022$Year <- 2022
quarters2022 <- quarters2022[, c("Year", names(quarters2022)[-ncol(quarters2022)])]

quarters2023$Year <- 2023
quarters2023 <- quarters2023[, c("Year", names(quarters2023)[-ncol(quarters2023)])]

quarters2024$Year <- 2024
quarters2024 <- quarters2024[, c("Year", names(quarters2024)[-ncol(quarters2024)])]

quartersall <- rbind(quarters2018,quarters2019,quarters2020,quarters2021,quarters2022,quarters2023,quarters2024)


# Load the ggplot2 package
library(ggplot2)

quartersall$Time <- paste(quartersall$Year, quartersall$Quarter)

# Plot the data
ggplot(quartersall, aes(x = Time, y = n, group = 1)) +
  geom_line(color = "blue") +         # Line for trends
  geom_point(color = "red", size = 3) + # Points for each quarter
  labs(title = "Quarterly Data for 2018",
       x = "Quarter",
       y = "Value (n)") +
  theme_minimal()




ui <- fluidPage(
  titlePanel("Leases in each state by Internal Industry"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = "internal_industry",
        label = "Select Internal Industry:",
        choices = c("All", unique(newdf$internal_industry)),
        selected = "All"
      ),
    ),
    mainPanel(
      plotOutput("graph")
    )
  )
)



server <- function(input, output) {
  
  output$graph <- renderPlot({
    
    filtered <- 
      data1 %>%
      (input$internal_industry == "All" | internal_industry == input$internal_industry)
    
    counting <- na.omit(filtered,input$transaction_type)
    
    ggplot(counting,aes(x=counting[,1],y=n)) + geom_bar(stat = "identity")
    
  })
}


server <- function(input, output, session) {    
  
  # Update dropdowns dynamically
  updateSelectInput(
    session,
    inputId = "transaction_type",
    choices = c("All", unique(data1$transaction_type))
  )
  
  
  # Reactive expressions
  filtered_data <- reactive({
    data1 %>% filter(
      input$internal_industry == "All" | internal_industry == input$internal_industry
    )
  })
  
  counted_data <- reactive({
    na.omit(count(filtered_data(), state))
  })
  
  # Render the plot
  output$graph <- renderPlot({
    ggplot(counted_data(), aes(x = !!sym(names(counted_data())[1]), y = n)) +
      geom_bar(stat = "identity") +
      labs(x = names(counted_data())[1], y = "Count", title = "Dynamic Plot")
  })
}


# Run the app
shinyApp(ui = ui, server = server)
