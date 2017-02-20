help("barplot")
rm(ElectionData)
rm(k)

#**************************************************************************************************
#                   Set Working Directory and open csv file                                       *
#**************************************************************************************************
setwd("E:/01 Statistics and Analytics/00 Workspace/Projects/Election Project")
getwd()
ElectionData = read.csv("Election_Data_LS2014_Detailed.csv", header = TRUE)
ElectionData[1:10,]
str(ElectionData)
utils::View(ElectionData)
# summary(ElectionData$POLL.PERCENTAGE)
# unique(ElectionData$STATE)
# View(ElectionData)
# barplot(by(ElectionData$Total_Electors,ElectionData$STATE,sum),col= 'Red',las=2, border = NA)

#**************************************************************************************************
#                   Using package sqldf                                                           *
#**************************************************************************************************
library(sqldf)
# sqldf("SELECT * FROM ElectionData ;")
# k <- sqldf("SELECT STATE, sum(TOTAL_VOTERS) AS VOTERS,sum(TOTAL_ELECTORS) as ELECTORS FROM ElectionData  GROUP BY STATE ;")
# 
# str(k)         # Returns a Dataframe
# utils::View(k)

m <- sqldf("SELECT STATE, 'YES' as VOTED, sum(TOTAL_VOTERS) as NUMBERS FROM ElectionData  GROUP BY STATE UNION
            SELECT STATE, 'NO' as VOTED, (sum(TOTAL_ELECTORS)-sum(TOTAL_VOTERS)) as NUMBERS FROM ElectionData  GROUP BY STATE ;")

str(m)
utils::View(m)
#**************************************************************************************************
#                   Using package ggplot2                                                         *
#**************************************************************************************************
library(ggplot2)
m$VOTED <- factor(m$VOTED, levels = c("NO", "YES"))
ggplot(data = m, aes(x = STATE, y = NUMBERS, fill = factor(m$VOTED), order=(m$VOTED))) + geom_bar (stat=
                  "identity")+ coord_flip() + scale_fill_brewer(palette = "Set1") + labs(title = "Figure 1  Total Electors and Voter turnout for Each State in General Election 2014 (Lok Sabha)", 
                                                                                         x = "State", y = "Electors", fill = "Voting Status") 
#http://stackoverflow.com/questions/32345923/how-to-control-ordering-of-stacked-bar-chart-using-identity-on-ggplot2
#http://stackoverflow.com/questions/6851522/how-do-i-plot-a-stacked-bar-with-ggplot
#http://2.bp.blogspot.com/-21hIPSVRtr4/UjKU5DUNKuI/AAAAAAAAKd0/OTmbuOxnthE/s1600/RColorBrewer-palettes.png
#http://novyden.blogspot.in/2013/09/how-to-expand-color-palette-with-ggplot.html
#http://docs.ggplot2.org/current/scale_brewer.html
# fancy_scientific <- function(l) {
#   # turn in to character string in scientific notation
#   l <- format(l, scientific = TRUE)
#   # quote the part before the exponent to keep all the digits
#   l <- gsub("^(.*)e", "'\\1'e", l)
#   # turn the 'e+' into plotmath format
#   l <- gsub("e", "%*%10^", l)
#   # return this as an expression
#   parse(text=l)
# }
# ggplot(data = m, aes(x = STATE, y = NUMBERS, fill = factor(m$VOTED), order=(m$VOTED))) + geom_bar (stat=
#               "identity")+ coord_flip() + scale_fill_brewer(palette = "Set1") + labs(title = "Figure 1  Total Electors and Voter turnout for Each State in General Election 2014 (Lok Sabha)", 
#               x = "State", y = "Electors", fill = "Voting Status") + scale_y_continuous(labels=fancy_scientific)

#**************************************************************************************************
#                   Using package rmysql                                                          *
#**************************************************************************************************                                                                                                                                                                              
# install.packages("RMySQL")
install.packages("dbConnect")
library(RMySQL)
library(dbConnect)

con <- dbConnect(MySQL(),
                 user = "gangesh",
                 password = "gangesh",
                 #host = "INBASDLP02562",
                 dbname ="ranalysis")

dbGetQuery(con,statement="select STATE ,SUM(TOTAL_VOTERS) ,SUM(TOTAL_ELECTORS)  from electiondatadetailedls2014 GROUP BY STATE ;")
selectq1 <- dbGetQuery(con,statement="SELECT STATE, 'YES' as VOTED, sum(TOTAL_VOTERS) as NUMBERS FROM electiondatadetailedls2014  GROUP BY STATE UNION
            SELECT STATE, 'NO' as VOTED, (sum(TOTAL_ELECTORS)-sum(TOTAL_VOTERS)) as NUMBERS FROM electiondatadetailedls2014  GROUP BY STATE ;")
createTabq1 <-
  
  dbSendQuery (con, "
CREATE TABLE turnoutbystate (
STATE VARCHAR(45),
VOTED CHAR(3),
NUMBERS INTEGER);"
)
dbListTables(con)
dbWriteTable(con, "turnoutbystate", selectq1, append = TRUE, row.names = FALSE)
readback <- dbGetQuery(con,statement="select * from turnoutbystate ;")
#readback <- dbReadTable(con, "turnoutbystate")
readback
str(readback)
readback$VOTED <- factor(readback$VOTED, levels = c("NO", "YES"))

ggplot(data = readback, aes(x = readback$STATE, y = NUMBERS, fill = factor(VOTED), order=(VOTED))) + geom_bar (stat=
                        "identity")+ coord_flip() + scale_fill_brewer(palette = "Set1") + labs(title = "Figure 1  Total Electors and Voter turnout for Each State in General Election 2014 (Lok Sabha)", 
                        x = "State", y = "Electors", fill = "Voting Status") 

dbDisconnect(con)
