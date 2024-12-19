
# Function to map features with specified colors and highlight specific buildings
map_osm_features <- function(longitude, latitude, buffer_radius, features_colors, other_colors, crop_type = "vertical_2_3", highlight_osm_ids = NULL, place_name = NULL, save_path = NULL, dpi = 300, outer_margin = 0.05) {
  
  library(sf)
  library(osmdata)
  library(tmap)
  library(dplyr)
  
  # Create a bounding box or shape based on crop_type
  center_point <- st_sfc(st_point(c(longitude, latitude)), crs = 4326) %>%
    st_transform(crs = 3857)
  
  if (crop_type == "vertical_2_3") {
    bbox <- st_bbox(center_point) %>%
      as.numeric()
    width <- buffer_radius * 2 * 2/3
    bbox_matrix <- matrix(c(bbox[1] - width / 2, bbox[2] - buffer_radius,
                            bbox[1] - width / 2, bbox[2] + buffer_radius,
                            bbox[1] + width / 2, bbox[2] + buffer_radius,
                            bbox[1] + width / 2, bbox[2] - buffer_radius,
                            bbox[1] - width / 2, bbox[2] - buffer_radius), 
                          ncol = 2, byrow = TRUE)
    shape <- st_polygon(list(bbox_matrix)) %>%
      st_sfc(crs = 3857) %>%  # Assign CRS
      st_transform(crs = 4326)
  } 
  
  bbox <- st_bbox(shape)
  
  # Calculate the aspect ratio of the map (height/width)
  aspect_ratio <- (bbox[4] - bbox[2]) / (bbox[3] - bbox[1])
  
  # Adjust the outer margins based on crop type
  outer_margin_vector <- rep(outer_margin, 4)
  
  # Initialize an empty list to store the data
  data_list <- list()
  
  # Fetch the OSM data for each feature
  for (feature in names(features_colors)) {
    osm_data <- opq(bbox = bbox) %>%
      add_osm_feature(key = feature) %>%
      osmdata_sf()
    
    # Check if the data for the feature exists and has geometries
    if (!is.null(osm_data$osm_polygons) && nrow(osm_data$osm_polygons) > 0) {
      data_list[[feature]] <- list(geometry = osm_data$osm_polygons, type = "polygon")
    } else if (!is.null(osm_data$osm_lines) && nrow(osm_data$osm_lines) > 0) {
      data_list[[feature]] <- list(geometry = osm_data$osm_lines, type = "line")
    } else {
      message(paste("No data found for feature:", feature))
    }
  }
  
  # Plot the data using tmap
  tm <- tm_shape(shape) +
    tm_fill(col = other_colors["in.bground"]) +  
    tm_borders(col = "transparent", lwd = 0)
  
  for (feature in names(data_list)) {
    if (!is.null(data_list[[feature]])) {
      if (data_list[[feature]]$type == "polygon") {
        tm <- tm + tm_shape(data_list[[feature]]$geometry) +
          tm_fill(col = features_colors[[feature]]) +
          tm_borders(col = other_colors["polygon.border"], lwd = 0.2)
      } else if (data_list[[feature]]$type == "line") {
        tm <- tm + tm_shape(data_list[[feature]]$geometry) +
          tm_lines(col = features_colors[[feature]], lwd = 2)
      }
    }
  }
  
  # Highlight specific buildings by a list of osm_ids if provided
  if (!is.null(highlight_osm_ids)) {
    osm_data_building <- opq(bbox = bbox) %>%
      add_osm_feature(key = "building") %>%
      osmdata_sf()
    
    highlighted_buildings <- osm_data_building$osm_polygons %>% filter(osm_id %in% highlight_osm_ids)
    
    if (nrow(highlighted_buildings) > 0) {
      tm <- tm + tm_shape(highlighted_buildings) +
        tm_fill(col = other_colors["highlighted.fill"]) +
        tm_borders(col = other_colors["highlighted.border"], lwd = 1.2)
    } else {
      message("None of the specified buildings were found.")
    }
  }
  
  # Add the place name on the bottom right corner
  if (!is.null(place_name)) {
    tm <- tm + tm_layout(
      title = place_name,
      title.position = c("left", "top"),
      title.size = 1.2,
      title.fontface = "bold",
      title.fontfamily = "serif",
      title.color = other_colors["title"]
    ) + tm_credits(
      " Volmerange-lès-Boulay", 
      fontface = "italic",
      fontfamily = "serif",
      size = 1,
      position = c("left", "top")
    ) 
  }
  
  # Set the outer margins with equal spacing based on the aspect ratio
  tm <- tm + tm_layout(bg.color = other_colors["out.bground"], outer.margins = outer_margin_vector, inner.margins = 0, frame = FALSE) + tm_legend(show = FALSE)
  
  # Save the map if save_path is provided
  if (!is.null(save_path)) {
    tmap_save(tm, filename = save_path, dpi = dpi)
  }
  
  print(tm)
}

tmap_mode("view")

# Example usage of the function
features_colors <- list(
  "waterway" = "#1D2F6F",
  "highway" = "#DFBE99",
  "building" = "#8B5D33"
)

other_colors <- list(
 "in.bground" = "darkseagreen4",  
 "out.bground" = "white",
 "title" = "gray20",
 "highlighted.fill" = "#8B5D33",
 "highlighted.border" = "black",
 "polygon.border" = "#DFBE99"
)

highlight_osm_ids <- c(133085015, 133085517, 133085552)  # List of osm_ids to highlight
map_osm_features(
  longitude = 2.396188537,
  latitude = 48.8358976,
  buffer_radius = 800,
  features_colors = features_colors,
  other_colors = other_colors, 
  crop_type = "vertical_2_3", 
  highlight_osm_ids = highlight_osm_ids,  # Highlight these buildings
  place_name = " Titre",
  save_path = "test_map.png",  # Path to save the image
  dpi = 4500,  # Resolution in DPI 45000
  outer_margin = 0  # Outer margin to add around the plot
)
