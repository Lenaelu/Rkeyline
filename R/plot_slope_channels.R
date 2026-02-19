#' Terrain Analysis with Stream Network Visualization
#'
#' @description
#' Creates a visualization of terrain analysis including slope, contours, and
#' stream network. This function uses pre-calculated geomorphology metrics from
#' \code{calc_geomorph_metrics()}.
#'
#' @param dtm SpatRaster. dtm raster object from the terra package.
#' @param metrics Optional. A list object returned from \code{calc_geomorph_metrics()}.
#'   If NULL, the function will calculate metrics internally. Default is NULL.
#' @param contour_interval Numeric. Elevation interval for contour lines. Default is 10.
#' @param stream_threshold Numeric. Threshold value for stream extraction (number of cells).
#'   Higher values result in fewer streams. Default is 1000.
#' @param hillshade_angle Numeric. Sun elevation angle for hillshade calculation (0-90 degrees).
#'   Default is 45.
#' @param hillshade_direction Numeric. Sun azimuth direction for hillshade (0-360 degrees).
#'   Default is 270.
#' @param contour_color Character. Color for contour lines. Default is "darkorange4".
#' @param contour_width Numeric. Line width for contours. Default is 1.
#' @param label_size Numeric. Size of contour labels. Default is 0.8.
#' @param slope_alpha Numeric. Transparency of slope overlay (0-1). Default is 0.6.
#' @param stream_color Character. Color for stream network. Default is "blue".
#' @param stream_width Numeric. Line width for streams. Default is 1.
#' @param main_title Character. Plot title. Default is "Slope with contours and streams".
#'
#' @return A named list containing:
#' \itemize{
#'   \item \code{dtm}: Original dtm as SpatRaster
#'   \item \code{slope}: Slope in degrees as SpatRaster
#'   \item \code{aspect}: Aspect in radians as SpatRaster
#'   \item \code{hillshade}: Hillshade as SpatRaster
#'   \item \code{contours}: Contour lines as SpatVector
#'   \item \code{streams}: Stream network as SpatRaster
#'   \item \code{flow_acc}: Flow accumulation as SpatRaster
#' }
#'
#' @details
#' This function creates a comprehensive terrain visualization by:
#' \enumerate{
#'   \item Using pre-calculated geomorphology metrics (slope, aspect, hillshade, contours, streams)
#'   \item Creating a multi-layer visualization with hillshade, slope, contours, and streams
#' }
#'
#' @note
#' Requires the following packages: \code{terra}, \code{whitebox}, \code{sf}
#'
#' @examples
#' \dontrun{
#' # Load dtm
#' dtm <- rast("path/to/dtm.tif")
#'
#' # Calculate metrics once
#' metrics <- calc_geomorph_metrics(dtm, stream_threshold = 1000)
#'
#' # Use metrics for plotting
#' result <- plot_slope_channels(dtm, metrics = metrics)
#'
#' # Custom parameters
#' result <- plot_slope_channels(
#'   dtm = dtm,
#'   metrics = metrics,
#'   contour_interval = 20,
#'   stream_color = "darkblue"
#' )
#'
#' # Access individual results
#' plot(result$slope)
#' plot(result$streams)
#' }
#'
#' @export
plot_slope_channels <- function(dtm,
                                metrics,
                                contour_interval = 10,
                                stream_threshold = 1000,
                                hillshade_angle = 45,
                                hillshade_direction = 270,
                                contour_color = "darkorange4",
                                contour_width = 1,
                                label_size = 0.8,
                                slope_alpha = 0.6,
                                stream_color = "blue",
                                stream_width = 1,
                                main_title = "Slope with contours and streams") {

  # Validate inputs
  if (!inherits(dtm, "SpatRaster")) {
    stop("'dtm' must be a SpatRaster object from the terra package")
  }

  # Validate metrics object
  if (!is.list(metrics)) {
    stop("'metrics' must be a list object from calc_geomorph_metrics(). Please run calc_geomorph_metrics() first.")
  }

  required_elements <- c("contours", "slope", "aspect", "hillshade", "streams", "flow_acc")
  if (!all(required_elements %in% names(metrics))) {
    stop("'metrics' must contain: ", paste(required_elements, collapse = ", "),
         "\nPlease ensure you're using the output from calc_geomorph_metrics()")
  }

  message("Starting terrain visualization...")

  # Extract metrics
  slope <- metrics$slope
  aspect <- metrics$aspect
  hillshade <- metrics$hillshade
  contours <- metrics$contours
  streams <- metrics$streams
  flow_acc <- metrics$flow_acc

  # Plot results
  message("Generating plot...")
  terra::plot(hillshade,
              col = grDevices::gray(0:100/100),
              legend = FALSE,
              main = main_title,
              las = 1)

  terra::plot(slope,
              add = TRUE,
              col = grDevices::hcl.colors(25, "YlOrRd", rev = TRUE),
              alpha = slope_alpha,
              legend = TRUE)

  terra::plot(contours,
              add = TRUE,
              col = contour_color,
              lwd = contour_width)

  terra::contour(dtm,
                 add = TRUE,
                 levels = seq(0, max(terra::values(dtm), na.rm = TRUE), contour_interval),
                 col = contour_color,
                 lwd = contour_width,
                 labcex = label_size)

  terra::plot(streams,
              add = TRUE,
              col = stream_color,
              lwd = stream_width,
              legend = FALSE)

  message("Terrain visualization complete!")

  # Return results
  return(invisible(list(
    dtm = dtm,
    slope = slope,
    aspect = aspect,
    hillshade = hillshade,
    contours = contours,
    streams = streams,
    flow_acc = flow_acc
  )))
}
