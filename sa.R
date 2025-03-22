library(dplyr)
data1 <- read.csv("./Leases.csv")
occ <- read.csv("./occ.csv")
data2 <- data1[data1$transaction_type == 'Relocation',]

technology <- data2[data2$internal_industry == 'Technology, Advertising, Media, and Information',]


count(technology, market)
count(occ, market)
