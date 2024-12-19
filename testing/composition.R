library(magick)

# Load images
folder_path <- "cado"
image_files <- list.files(folder_path, full.names = TRUE, pattern = "\\.(jpg|jpeg|png)$")
images <- lapply(image_files, image_read)

# Add margins between images
images <- lapply(images, function(img) image_border(img, "white", "60x60"))

# Create rows by combining pairs of images horizontally
row1 <- image_append(c(images[[1]], images[[2]])) # First row
row2 <- image_append(c(images[[3]], images[[4]])) # Second row
row3 <- image_append(c(images[[5]], images[[6]])) # Third row

# Combine rows vertically
composition <- image_append(c(row1, row2, row3), stack = TRUE)
composition <- image_border(composition, "white", "60x60")

# Save the final composition to a file
output_file <- file.path(folder_path, "composition_grid.png")
image_write(composition, output_file)
