library(shiny)
library(shinydashboard)
library(stattleshipR)
library(dplyr)
library(readr)
library(stringr)
library(plotly)

teams <- read_csv("https://dl.dropboxusercontent.com/u/25945599/nbaTeams.csv")
players <- read_csv("https://dl.dropboxusercontent.com/u/25945599/nbaPlayers.csv")



players <- players %>% 
  arrange(name)

playerChoice <- players$slug
names(playerChoice) <- players$name

## 
token <-set_token('14954863fc861a855e8510512308dd38')

## set params
sport <- "basketball" 
league <- "nba"