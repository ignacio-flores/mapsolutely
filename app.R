#load libraries 
require(osmdata)
require(shiny)
require(tmap)
require(sf)
require(dplyr)
require(shinyWidgets)

#load functions 
source("functions/map_osm_features.R")
source("functions/bmap_ui.R")
source("functions/bmap_server.R")

# Run the app
shinyApp(ui = ui, server = server) 
