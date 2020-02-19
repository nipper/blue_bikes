library(mapdeck)
library(dplyr)
library(geosphere)

source("load_data.R")
key = key_data

trip_data_head <- as.data.frame(head(trip_data,200000))
mapdeck(token = key, style = mapdeck_style('dark'), pitch = 35) %>%
  add_heatmap(
    data = trip_data,
    lat = "start_station_latitude",
    lon = "start_station_longitude",
    , layer_id = "grid_layer"
    
  )


trip_data_with_distance <- 
  trip_data %>%
  mutate(distance = purrr::pmap_dbl(list(start_station_longitude, start_station_latitude,
                                         end_station_longitude, end_station_latitude),
                                    function(a,b,c,d) {
                                      distm(c(a,b),c(c,d))
                                    }))

feather::write_feather(trip_data_with_distance,"data/trip_data.feather")

grouped_data <- 
  trip_data %>% 
  group_by(start_station_id,end_station_id) %>% 
  count() %>% 
  inner_join(trip_data %>% 
               distinct(start_station_id,end_station_id,start_station_latitude,start_station_longitude,end_station_latitude,end_station_longitude) %>% 
              select(start_station_id,end_station_id,start_station_latitude,start_station_longitude,end_station_latitude,end_station_longitude))
