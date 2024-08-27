
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

# Google maps API token
key <- "XXXXXXXXXXXXXXXXXXXXXXX"
register_google(key)
# Openweather API Token
set_weather_key("XXXXXXXXXXXXXXXXXXXXXXX")

source("data.R")
source("components.R")
