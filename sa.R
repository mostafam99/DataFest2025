library(dplyr)
library(ggplot2)
library(googleVis)
library(tidygeocoder)

data1 <- read.csv("./Leases.csv")
data2 <- data1[data1$transaction_type == 'New',]
industry <- na.omit(data1[data1$internal_industry == 'Technology, Advertising, Media, and Information',])
newindustry <- na.omit(industry[industry$transaction_type == 'New',])

counts <- count(industry, state)

data2 <- data1 %>% 
  rename(
    zipcode = zip,
  )


require(datasets)

# Create GeoChart with state codes
GeoStates <- gvisGeoChart(counts, "state", "n",
                          options = list(region = "US",
                                         title = "Technology", 
                                         displayMode = "regions",
                                         resolution = "provinces",
                                         colorAxis="{colors:['red', 'purple']}",
                                         width = 600, height = 400))
# Plot the GeoChart
plot(GeoStates)





