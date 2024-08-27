
library(shiny)
library(dplyr)
library(lubridate)
library(dtplyr, warn.conflicts = F)
library(shinyNextUI)
library(echarts4r)
library(mapboxer)
library(typedjs)
library(countup)
library(reactable)
library(sparkline)
library(shiny.react)
library(globe4r)
library(OweatherR)
library(ggmap)

key <- "AIzaSyC-L1JqEFQyWuwMiflGyA-8HRMi8K31noM"
register_google(key)
set_weather_key("7ade3673d5e34cd670eaeeae0209c16d")

source("data.R")
source("components.R")
