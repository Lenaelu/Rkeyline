#' Plot dtm with Hillshade and Contours
#'
#' Creates a visualization of a Digital Elevation Model (dtm) with hillshade,
#' contour lines, and labels. This function uses pre-calculated geomorphology
#' metrics from \code{calc_geomorphology_metrics()}.
#'
#' @param dtm SpatRaster. dtm raster object from the terra package.
#' @param metrics Optional. A list object returned from \code{calc_geomorphology_metrics()}.
#'   If NULL, the function will calculate metrics internally. Default is NULL.
#' @param contour_interval Numeric. Elevation interval between contour lines. Default is 10.
#' @param hillshade_angle Numeric. Sun angle for hillshade calculation. Default is 45.
#' @param hillshade_direction Numeric. Sun direction for hillshade. Default is 270.
#' @param contour_color Character. Color for contour lines. Default is "darkorange4".
#' @param contour_width Numeric. Line width for contours. Default is 1.
#' @param label_size Numeric. Size of contour labels. Default is 0.8.
#' @param dtm_alpha Numeric. Transparency of dtm overlay (0-1). Default is 0.6.
#' @param main_title Character. Plot title. Default is "dtm with contours and hillshade".
#'
#' @return A plot displaying the dtm with hillshade and contours. Invisibly returns a list containing:
#' \itemize{
#'   \item \code{dtm}: Original dtm as SpatRaster
#'   \item \code{hillshade}: Hillshade as SpatRaster
#'   \item \code{contours}: Contour lines as SpatVector
#'   \item \code{slope}: Slope in degrees as SpatRaster
#'   \item \code{aspect}: Aspect in radians as SpatRaster
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' dtm <- rast("path/to/dtm.tif")
#'
#' # Calculate metrics once
#' metrics <- calc_geomorph_metrics(dtm)
#'
#' # Use metrics for plotting
#' plot_dtm_contours(dtm, metrics = metrics)
#' plot_dtm_contours(dtm, metrics = metrics, contour_interval = 20)
#'
#' # Multiple plots from same metrics (efficient!)
#' plot_dtm_contours(dtm, metrics = metrics, contour_color = "blue")
#' plot_dtm_contours(dtm, metrics = metrics, dtm_alpha = 0.8)
#' }
plot_dtm_contours <- function(dtm,
                              metrics,
                              contour_interval = 10,
                              hillshade_angle = 45,
                              hillshade_direction = 270,
                              contour_color = "darkorange4",
                              contour_width = 1,
                              label_size = 0.8,
                              dtm_alpha = 0.6,
                              main_title = "Dtm with contours") {

  # Validate input
  if (!inherits(dtm, "SpatRaster")) {
    stop("'dtm' must be a SpatRaster object from the terra package")
  }

  # Validate metrics object
  if (!is.list(metrics)) {
    stop("'metrics' must be a list object from calc_geomorph_metrics(). Please run calc_geomorph_metrics() first.")
  }

  required_elements <- c("contours", "slope", "aspect", "hillshade")
  if (!all(required_elements %in% names(metrics))) {
    stop("'metrics' must contain: ", paste(required_elements, collapse = ", "),
         "\nPlease ensure you're using the output from calc_geomorph_metrics()")
  }

  message("Starting dtm visualization...")

  # Extract metrics
  contours <- metrics$contours
  slope <- metrics$slope
  aspect <- metrics$aspect
  hillshade <- metrics$hillshade

  # Plot
  terra::plot(hillshade, col = grDevices::gray(0:100/100), legend = FALSE,
              main = main_title, las = 1)
  terra::plot(dtm, add = TRUE, col = grDevices::terrain.colors(25, rev = TRUE),
              alpha = dtm_alpha, legend = TRUE)
  terra::plot(contours, add = TRUE, col = contour_color, lwd = contour_width)

  # Add contour labels
  terra::contour(dtm, add = TRUE,
                 levels = seq(0, max(terra::values(dtm), na.rm = TRUE), contour_interval),
                 col = contour_color, lwd = contour_width, labcex = label_size)

  message("Plot complete!")

  invisible(list(
    dtm = dtm,
    hillshade = hillshade,
    contours = contours,
    slope = slope,
    aspect = aspect
  ))
}
