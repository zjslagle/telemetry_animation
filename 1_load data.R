##########################################################################################
#
# Generate animation from telemetry data
#
# Zak Slagle, Ohio DNR - April 2025 


### Load packages     ############################
#library(ggpubr)
library(mapview) # quick shapefile checks
library(ggspatial) # easy addition of N arrow and scale bar on map
library(readxl)    # reading xlsx
library(lubridate) # working with dates
library(magick)    # save animation package
library(glatos)    # interpolate_paths and other convenient telemetry functions
# if you need to install glatos: install.packages('glatos', repos = c('https://ocean-tracking-network.r-universe.dev', 'https://cloud.r-project.org'))
library(sf)       # simple features - the engine of mapping in R
library(gganimate) # ggplot animations
library(tidyverse) # yay pipes


#### Data - read in and format GLATOS data  ########################
data_receivers <- read_csv("data sources/data_receivers.csv")
data_tagging <- read_csv("data sources/data_tagging.csv")
data_detections <- read_csv("data sources/data_detections.csv")

data_detections <- data_detections %>%
  mutate(detection_timestamp = with_tz(detection_timestamp_utc, tz = "US/Eastern"),
         detection_date = date(detection_timestamp_utc))

# get study start date - date first fish was tagged
study_start_date = min(data_tagging$detection_date)


