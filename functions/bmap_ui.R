# Define UI for application
ui <- fluidPage(
  
  # Include shinyjs for disabling/enabling inputs
  shinyjs::useShinyjs(),
  
  # Center all content
  tags$div(style = "text-align: center;",
           
           # Application title
           titlePanel("Mapsolutely"),
           
           # Layout with inputs on top and map below
           fluidRow(
             column(8, offset = 2, 
                    fluidRow(
                      column(6, textInput("latlong", "Latitude, Longitude:", value = "48.85555151703638, 2.36552760400104")),
                      column(6, sliderInput("buffer_radius", "Buffer Radius (meters):", min = 50, max = 1600, value = 700, step = 50))
                    ),
                    fluidRow(
                      column(6, selectInput("style", "Color Style:", 
                                            choices = c("custom", "buildings_rojo", "buildings_blue", "fondo_rojo", "girly", "violet", "new_yellow"), 
                                            selected = "buildings_rojo")),
                      column(6, selectInput("crop_type", "Crop Type:", 
                                            choices = c("square", "vertical_2_3"),
                                            selected = "square"))
                    )
             )
           ),
           
           fluidRow(
             column(8, offset = 2,
                    # Collapsible "More Options" section using Bootstrap
                    tags$div(
                      class = "panel-group",
                      tags$div(
                        class = "panel panel-default",
                        tags$div(
                          class = "panel-heading",
                          tags$h4(
                            class = "panel-title",
                            tags$a(
                              "data-toggle" = "collapse",
                              href = "#collapseOptions",
                              "More Options"
                            )
                          )
                        ),
                        tags$div(
                          id = "collapseOptions",
                          class = "panel-collapse collapse",
                          tags$div(
                            class = "panel-body",
                            
                            # Arrange inputs in pairs (two per row)
                            fluidRow(
                              column(6, textInput("title", "Title:", value = "")),
                              column(6, textInput("subtitle", "Subtitle:", value = ""))
                            ),
                            fluidRow(
                              column(6, sliderInput("outer_margin", "Outer Margin:", min = 0, max = 0.5, value = 0, step = 0.01)),
                              column(6, numericInput("dpi", "Resolution (DPI)", value = 100))
                            ),
                            fluidRow(
                              column(6, textInput("highlight_osm_ids", "Highlight OSM IDs (comma-separated):", value = "")),
                              column(6, textAreaInput("features_colors", "Features Colors (JSON format):", 
                                                      value = '{"leisure" : "#C5E1A5", "highway" : "#9E9E9E", "waterway": "#1D2F6F", "building": "#D7CCC8", "man_made": "#D7CCC8"}'))
                            ),
                            fluidRow(
                              column(6, textAreaInput("other_colors", "Other Colors (JSON format):", 
                                                      value = '{"in.bground": "#E0E0E0", "out.bground": "white", "title": "gray20", "highlighted.fill": "#8B5D33", "highlighted.border": "black", "polygon.border": "#DFBE99"}'))
                            ),
                            fluidRow(
                              column(6, 
                                     checkboxGroupInput(
                                       "highway_subcategories", 
                                       "Select Highway Subcategories to Include:",
                                       choices = c("primary", "secondary", "tertiary", "unclassified", "residential",  "service", "motorway", "motorway_link", "living_street"),
                                       selected = c("primary", "secondary", "tertiary", "unclassified", "residential", "service", "motorway", "motorway_link", "living_street")
                                     )
                              )
                            )
                          )
                        )
                      )
                    )
             )
           ),
           
           fluidRow(
             column(8, offset = 2,
                    div(style = "text-align:center; margin-bottom: 40px;",
                        actionButton("update_map", 
                                     label = tagList(icon("map"), strong("Create")),
                                     style = "font-weight: bold; color: white; background-color: #007bff; border-color: #007bff;"
                        ),
                        tags$span(style = "margin-left: 20px;"), # Adding some space between buttons
                        downloadButton("download_map", "Download")
                    )
             )
           ),
           
           # Map output centered with download button below
           fluidRow(
             column(8, offset = 2,
                    tags$div(
                      imageOutput("map_image", height = "auto"),
                      style = "margin-bottom: 20px;"
                    )
             )
           )
  )
)
