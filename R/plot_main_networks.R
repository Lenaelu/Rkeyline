#' Plot dtm with Main Valleys and Ridges
#'
#' Creates a visualization of a Digital Elevation Model (dtm) with hillshade,
#' main valley lines, and main ridge lines. This function uses pre-calculated
#' geomorphology metrics and pre-extracted networks.
#'
#' @param dtm SpatRaster. dtm raster object from the terra package.
#' @param main_valleys sf object. Main valley lines from \code{extract_main_valleys()}.
#'   This parameter is REQUIRED.
#' @param main_ridges sf object. Main ridge lines from \code{extract_main_ridges()}.
#'   This parameter is REQUIRED.
#' @param metrics List. A list object returned from \code{calc_geomorph_metrics()}.
#'   This parameter is REQUIRED. Must contain hillshade.
#' @param valley_color Character. Color for valley lines. Default is "lightblue".
#' @param ridge_color Character. Color for ridge lines. Default is "darkorange".
#' @param valley_width Numeric. Line width for valleys. Default is 2.
#' @param ridge_width Numeric. Line width for ridges. Default is 2.
#' @param show_contours Logical. Should contour lines be shown? Default is TRUE.
#' @param contour_color Character. Color for contour lines. Default is "gray30".
#' @param contour_width Numeric. Line width for contours. Default is 0.5.
#' @param dtm_alpha Numeric. Transparency of dtm overlay (0-1). Default is 0.6.
#' @param show_labels Logical. Should RANK labels be shown? Default is FALSE.
#' @param label_size Numeric. Size of RANK labels. Default is 0.8.
#' @param main_title Character. Plot title. Default is "Main Valleys and Ridges".
#' @param legend Logical. Should legend be shown? Default is TRUE.
#'
#' @return A plot displaying the dtm with hillshade, main valleys, and main ridges.
#'   Invisibly returns a list containing:
#' \itemize{
#'   \item \code{dtm}: Original dtm as SpatRaster
#'   \item \code{hillshade}: Hillshade as SpatRaster
#'   \item \code{main_valleys}: Main valley lines as sf object
#'   \item \code{main_ridges}: Main ridge lines as sf object
#' }
#'
#' @details
#' This function requires pre-calculated inputs:
#' 1. Metrics from \code{calc_geomorph_metrics(dtm)}
#' 2. Valley network from \code{extract_networks(dtm, type = "valley", metrics = metrics)}
#' 3. Ridge network from \code{extract_networks(dtm, type = "ridge", metrics = metrics)}
#' 4. Main valleys from \code{extract_main_valleys(valleys, dtm, nr_main, metrics)}
#' 5. Main ridges from \code{extract_main_ridges(ridges, dtm, nr_main, metrics)}
#'
#' @export
#' @import terra
#' @import sf
#' @import graphics
#' @import grDevices
#'
#' @examples
#' \dontrun{
#' dtm <- rast("path/to/dtm.tif")
#'
#' # Step 1: Calculate metrics
#' metrics <- calc_geomorph_metrics(dtm)
#'
#' # Step 2: Extract networks
#' valleys <- extract_networks(dtm, type = "valley", metrics = metrics)
#' ridges <- extract_networks(dtm, type = "ridge", metrics = metrics)
#'
#' # Step 3: Extract main networks
#' main_valleys <- extract_main_valleys(valleys, dtm, nr_main = 2, metrics = metrics)
#' main_ridges <- extract_main_ridges(ridges, dtm, nr_main = 2, metrics = metrics)
#'
#' # Step 4: Plot
#' plot_main_networks(
#'   dtm = dtm,
#'   main_valleys = main_valleys,
#'   main_ridges = main_ridges,
#'   metrics = metrics
#' )
#'
#' # Custom colors
#' plot_main_networks(
#'   dtm = dtm,
#'   main_valleys = main_valleys,
#'   main_ridges = main_ridges,
#'   metrics = metrics,
#'   valley_color = "blue",
#'   ridge_color = "brown"
#' )
#' }
plot_main_networks <- function(dtm,
                               main_valleys,
                               main_ridges,
                               metrics,
                               valley_color = "lightblue",
                               ridge_color = "darkorange",
                               valley_width = 2,
                               ridge_width = 2,
                               show_contours = TRUE,
                               contour_color = "gray30",
                               contour_width = 0.5,
                               dtm_alpha = 0.6,
                               show_labels = FALSE,
                               label_size = 0.8,
                               main_title = "Main valleys and ridges",
                               legend = TRUE) {


  # Input validation
  if (!inherits(dtm, "SpatRaster")) {
    stop("'dtm' must be a SpatRaster object from the terra package")
  }

  if (missing(main_valleys)) {
    stop("The 'main_valleys' parameter is required. Please extract main valleys first using extract_main_valleys() and pass the result to this function.")
  }

  if (!inherits(main_valleys, "sf")) {
    stop("'main_valleys' must be an sf object from extract_main_valleys()")
  }

  if (missing(main_ridges)) {
    stop("The 'main_ridges' parameter is required. Please extract main ridges first using extract_main_ridges() and pass the result to this function.")
  }

  if (!inherits(main_ridges, "sf")) {
    stop("'main_ridges' must be an sf object from extract_main_ridges()")
  }

  if (missing(metrics)) {
    stop("The 'metrics' parameter is required. Please calculate metrics first using calc_geomorph_metrics(dtm) and pass the result to this function.")
  }

  if (!is.list(metrics)) {
    stop("'metrics' must be a list object from calc_geomorph_metrics()")
  }

  if (!"hillshade" %in% names(metrics)) {
    stop("'metrics' must contain hillshade. Please ensure you're using the output from calc_geomorph_metrics()")
  }

  if (show_contours && !"contours" %in% names(metrics)) {
    stop("'metrics' must contain contours when show_contours = TRUE. Please ensure you're using the output from calc_geomorph_metrics()")
  }

  # Extract hillshade and contours
  hillshade <- metrics$hillshade
  if (show_contours) {
    contours <- metrics$contours
  }

  message("Starting main networks visualization...")

  # Plot hillshade base
  terra::plot(hillshade,
              col = grDevices::gray(0:100/100),
              legend = FALSE,
              main = main_title,
              las = 1)

  # Add dtm overlay
  terra::plot(dtm,
              add = TRUE,
              col = grDevices::terrain.colors(25, rev = TRUE),
              alpha = dtm_alpha,
              legend = TRUE,
              plg = list(x = "bottomright", cex = 0.8))  # Position dtm legend at bottom right

  # Plot contours if requested
  if (show_contours) {
    terra::plot(contours,
                add = TRUE,
                col = contour_color,
                lwd = contour_width)
  }

  # Plot main valleys
  plot(st_geometry(main_valleys),
       add = TRUE,
       col = valley_color,
       lwd = valley_width)

  # Plot main ridges
  plot(st_geometry(main_ridges),
       add = TRUE,
       col = ridge_color,
       lwd = ridge_width)

  # Add labels if requested
  if (show_labels) {

    # Valley labels
    if ("RANK" %in% names(main_valleys)) {
      valley_centroids <- st_centroid(st_geometry(main_valleys))
      valley_coords <- st_coordinates(valley_centroids)
      text(valley_coords[, 1], valley_coords[, 2],
           labels = paste0("V", main_valleys$RANK),
           pos = 3,
           cex = label_size,
           col = valley_color,
           font = 2)
    }

    # Ridge labels
    if ("RANK" %in% names(main_ridges)) {
      ridge_centroids <- st_centroid(st_geometry(main_ridges))
      ridge_coords <- st_coordinates(ridge_centroids)
      text(ridge_coords[, 1], ridge_coords[, 2],
           labels = paste0("R", main_ridges$RANK),
           pos = 3,
           cex = label_size,
           col = ridge_color,
           font = 2)
    }
  }

  # Add network legend (positioned above dtm legend at bottom right)
  if (legend) {
    par(xpd = TRUE)  # Allow drawing outside plot region
    legend(x = par("usr")[2] - (par("usr")[2] - par("usr")[1]) * -0.05,  # Changed from 0.03 to 0.02 (more to the right)
           y = par("usr")[3] + (par("usr")[4] - par("usr")[3]) * 0.60,  # Kept at 0.60
           legend = c("Main valleys", "Main ridges"),
           col = c(valley_color, ridge_color),
           lwd = c(valley_width, ridge_width),
           bg = "white",
           box.col = "black",
           cex = 0.4,
           xjust = 1,
           yjust = 0)
    par(xpd = FALSE)  # Reset to default
  }

  message("Plot complete")

  # Build return list
  return_list <- list(
    dtm = dtm,
    hillshade = hillshade,
    main_valleys = main_valleys,
    main_ridges = main_ridges
  )

  if (show_contours) {
    return_list$contours <- contours
  }

  invisible(return_list)
}
