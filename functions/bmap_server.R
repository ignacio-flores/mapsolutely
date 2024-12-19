server <- function(input, output, session) {

  # Predefined Styles
  styles <- list(
    buildings_rojo = list(
      features_colors = '{"leisure" : "#515A47", "highway" : "#F3D9B1", "waterway": "#1D2F6F", "building": "#C33149"}', #"electrified": "#C33149"
      other_colors = '{"in.bground": "#C29979", "out.bground": "white", "title": "gray20", "highlighted.fill": "#124E78", "highlighted.border": "black", "polygon.border": "#F3D9B1"}'
    ),
    buildings_blue = list(
      features_colors = '{"leisure" : "#515A47", "highway" : "#F3D9B1", "waterway": "#1D2F6F", "building": "#124E78"}', #"electrified": "#92140C"
      other_colors = '{"in.bground": "#C29979", "out.bground": "white", "title": "gray20", "highlighted.fill": "#C33149", "highlighted.border": "black", "polygon.border": "#F3D9B1"}'
    ),
    fondo_rojo = list(
      features_colors = '{"leisure" : "#A8C256", "highway" : "#F3D9B1", "waterway": "#1D2F6F", "building": "#C29979"}',
      other_colors = '{"in.bground": "#C33149", "out.bground": "white", "title": "gray20", "highlighted.fill": "#C29979", "highlighted.border": "black", "polygon.border": "#A22522"}'
    ),
    girly = list(
      features_colors = '{"leisure" : "#FFFFE8", "highway" : "#FFFFE8", "waterway": "#1D2F6F", "building": "#8CFFDA"}',
      other_colors = '{"in.bground": "#D972FF", "out.bground": "white", "title": "gray20", "highlighted.fill": "#8CFFDA", "highlighted.border": "black", "polygon.border": "#A22522"}'
    ),
    violet = list(
      features_colors = '{"leisure" : "#473198", "highway" : "#DAFFED", "waterway": "#9BF3F0", "building": "#ADFC92"}',
      other_colors = '{"in.bground": "#4A0D67", "out.bground": "white", "title": "gray20", "highlighted.fill": "#ADFC92", "highlighted.border": "black", "polygon.border": "#4A0D67"}'
    ),
    new_yellow = list(
      features_colors = '{"leisure" : "#F29E4C", "highway" : "#16DB93", "waterway": "#9BF3F0", "building": "#EFEA5A"}', #"electrified" : "#16DB93"
      other_colors = '{"in.bground": "#A4036F", "out.bground": "white", "title": "gray20", "highlighted.fill": "#EFEA5A", "highlighted.border": "black", "polygon.border": "#4A0D67"}'
    )
  )

  # Observe changes in the style dropdown
  observeEvent(input$style, {
    if (input$style != "Custom") {
      selected_style <- styles[[input$style]]
      updateTextAreaInput(session, "features_colors", value = selected_style$features_colors)
      updateTextAreaInput(session, "other_colors", value = selected_style$other_colors)
    }
  })

  # Reactive function to parse lat/long input
  parse_latlong <- reactive({
    coords <- strsplit(input$latlong, ",")[[1]]
    if (length(coords) == 2) {
      latitude <- as.numeric(trimws(coords[1]))
      longitude<- as.numeric(trimws(coords[2]))
      if (!is.na(longitude) && !is.na(latitude)) {
        return(list(longitude = longitude, latitude = latitude))
      }
    }
    showNotification("Invalid format. Please enter as 'longitude, latitude'.", type = "error")
    return(NULL)
  })

  # Generate map based on inputs
  map_data <- eventReactive(input$update_map, {
    coords <- parse_latlong()
    if (is.null(coords)) return(NULL)  # Stop if parsing fails

    features_colors <- jsonlite::fromJSON(input$features_colors, simplifyVector = TRUE)
    other_colors <- jsonlite::fromJSON(input$other_colors, simplifyVector = TRUE)
    highlight_osm_ids <- as.numeric(unlist(strsplit(input$highlight_osm_ids, ",")))

    # Retrieve the user-defined highway color
    highway_color <- features_colors[["highway"]]

    # Dynamically assign the highway color to each selected subcategory
    for (subcat in input$highway_subcategories) {
      features_colors[[paste0("highway.", subcat)]] <- highway_color
    }

    map_file <- tempfile(fileext = ".png")

    map_osm_features(
      longitude = coords$longitude,
      latitude = coords$latitude,
      buffer_radius = input$buffer_radius,
      features_colors = features_colors,
      other_colors = other_colors,
      crop_type = input$crop_type,
      highlight_osm_ids = highlight_osm_ids,
      title = input$title,
      subtitle = input$subtitle,
      save_path = map_file,
      dpi = input$dpi,
      outer_margin = input$outer_margin
    )

    return(map_file)
  })

  # Render the map image
  output$map_image <- renderImage({
    map_file <- map_data()
    list(src = map_file, contentType = "image/png", alt = "Map Image")
  }, deleteFile = FALSE)

  # Download handler for the map
  output$download_map <- downloadHandler(
    filename = function() {
      paste("map-", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      file.copy(map_data(), file)
    },
    contentType = "image/png"
  )
}
