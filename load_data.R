library(vroom)
library(readr)
library(janitor)
library(feather)
library(lubridate)
library(dplyr)

load_trip_data <- function(path = "data/trip_data.feather") {
  
  vals <- mutate(clean_names(read_feather(path), case = "snake"),day_of_month = day(ymd_hms(starttime)))
  
  return(vals)  
  
}
trip_data <- load_trip_data()

load_station_data <- function(path = "data/stations.csv") {
  
  return(clean_names(vroom(path), case = "snake")) 
  
}
station_data <- load_station_data()

key_data <- read_file("secrets/mapbox.key")


min_distance <- trip_data$distance %>% min()
max_distance <- trip_data$distance %>% max()
days <- trip_data$starttime %>% ymd_hms() %>% day() %>% unique()

starting_counts <- 
  trip_data %>% 
  count(start_station_name)

trip_start_counts <- 
  trip_data %>% 
  select(start_station_id,start_station_name,start_station_latitude,start_station_longitude) %>% 
  left_join(starting_counts)
