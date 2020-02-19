library(shiny)
library(shinydashboard)
library(mapdeck)

source("load_data.R")

max_number_rows = 50000

ui <- navbarPage("Blue Bikes", id="nav",
                 
                 tabPanel("Trip Plotter",
                          div(class="outer",
                              
                              tags$head(
                                  # Include our custom CSS
                                  includeCSS("styles.css"),
                              ),
                              tags$style(
                                  ".irs-bar {",
                                  "  border-color: transparent;",
                                  "  background-color: transparent;",
                                  "}",
                                  ".irs-bar-edge {",
                                  "  border-color: transparent;",
                                  "  background-color: transparent;",
                                  "}"
                              ),
                              
                              # If not using custom CSS, set height of leafletOutput to a number instead of percent
                              mapdeckOutput("map", width="100%", height="100%"),
                              
                              # Shiny versions prior to 0.11 should use class = "modal" instead.
                              absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                            draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                            width = 330, height = "auto",
                                            
                                            h2("Trip Explorer"),
                                            sliderInput("distance_slider","Distance",min_distance,max_distance,c(min_distance,min_distance + 2000))
                                            # selectInput("color", "Color", vars),
                                            # selectInput("size", "Size", vars, selected = "adultpop"),
                                            # conditionalPanel("input.color == 'superzip' || input.size == 'superzip'",
                                            #                  # Only prompt for threshold when coloring or sizing by superzip
                                            #                  numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
                                            # ),

                              ),
                              
                              tags$div(id="cite",
                                       'Data compiled for ', tags$em('Coming Apart: The State of White America, 1960–2010'), ' by Charles Murray (Crown Forum, 2012).'
                              )
                          )
                 ),
                 tabPanel("Station Counts",
                          div(class="outer",
                          mapdeckOutput("station_counts", width="100%", height="100%"))
                 )
                 
                 
)

server <- function(input, output) {
    
    trips <- reactive({
        trip_data %>% 
            filter(between(distance,input$distance_slider[[1]], input$distance_slider[[2]])) %>%
            head(max_number_rows)
    })
    
    trip_start_counts <- reactive({
        trip_start_counts
    })
    ## initialise a map
    output$map <- renderMapdeck({
        mapdeck(token = key_data, style = mapdeck_style('dark'), pitch = 35, location = c(-71.11903,42.35169), zoom = 12)
        
    })
    
    ## initialise a map
    output$station_counts <- renderMapdeck({
        mapdeck(token = key_data, style = mapdeck_style('dark'), location = c(-71.11903,42.35169), zoom = 12)
        
    })
    observe({
        print(head(trips()))
        
        mapdeck_update(map_id = "station_counts") %>%
            add_heatmap(
                data = trips(),
                lat = "start_station_latitude",
                lon = "start_station_longitude",
                layer_id = "grid_layer"
                , update_view = FALSE
            )
    })
    observe({
        mapdeck_update(map_id = "map") %>%
            add_arc(
                data = trips()
                , origin = c("start_station_longitude", "start_station_latitude")
                , destination = c("end_station_longitude", "end_station_latitude")
                , stroke_from = "distance"
                # , stroke_from_opacity = "distance"
                , auto_highlight = TRUE
               , layer_id = "myRoads"
               , update_view = FALSE
               , legend = TRUE
            )
    })
    
}

shinyApp(ui, server)