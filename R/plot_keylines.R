#' Plot Keylines with Terrain Context
#'
#' @param dtm SpatRaster. DTM raster object from the terra package.
#' @param metrics A list returned from \code{calc_geomorph_metrics()}.
#' @param keylines SpatVector. Keylines returned from \code{create_keylines()}.
#' @param contour_interval Numeric. Elevation interval for contour lines. Default is 10.
#' @param slope_alpha Numeric. Transparency of slope overlay (0-1). Default is 0.5.
#' @param contour_color Character. Color for contour lines. Default is "darkorange4".
#' @param contour_width Numeric. Line width for contours. Default is 0.8.
#' @param label_size Numeric. Size of contour labels. Default is 0.7.
#' @param keyline_color Character. Color for keylines. Default is "blue".
#' @param keyline_width Numeric. Line width for keylines. Default is 1.5.
#' @param main_title Character. Plot title. Default is "Keylines with slope and contours".
#' @param legend Logical. Whether to display a keylines legend. Default is TRUE.
#'
#' @return Invisible list with dtm, slope, hillshade, contours, keylines.
#'
#' @export
plot_keylines <- function(dtm,
                          metrics,
                          keylines,
                          contour_interval = 10,
                          slope_alpha = 0.5,
                          contour_color = "darkorange4",
                          contour_width = 0.8,
                          label_size = 0.7,
                          keyline_color = "blue",
                          keyline_width = 1.5,
                          main_title = "Keylines with slope and contours",
                          legend = TRUE) {


  if (!inherits(dtm, "SpatRaster")) {
    stop("'dtm' must be a SpatRaster object from the terra package")
  }

  required_elements <- c("slope", "aspect", "hillshade", "contours")
  if (!is.list(metrics) || !all(required_elements %in% names(metrics))) {
    stop("'metrics' must be a list from calc_geomorph_metrics() containing: ",
         paste(required_elements, collapse = ", "))
  }

  message("Generating keylines plot...")

  terra::plot(metrics$hillshade,
              col = grDevices::gray(0:100/100),
              legend = FALSE,
              main = main_title,
              las = 1)

  terra::plot(metrics$slope,
              add = TRUE,
              col = grDevices::hcl.colors(25, "YlOrRd", rev = TRUE),
              alpha = slope_alpha,
              legend = TRUE,
              plg = list(x = "bottomright", cex = 0.8))

  terra::plot(metrics$contours,
              add = TRUE,
              col = contour_color,
              lwd = contour_width)

  terra::contour(dtm,
                 add = TRUE,
                 levels = seq(0, max(terra::values(dtm), na.rm = TRUE), contour_interval),
                 col = contour_color,
                 lwd = contour_width,
                 labcex = label_size)

  plot(sf::st_geometry(keylines),
       add = TRUE,
       col = keyline_color,
       lwd = keyline_width)

  if (legend) {
    par(xpd = TRUE)
    legend(x = par("usr")[2] - (par("usr")[2] - par("usr")[1]) * -0.05,
           y = par("usr")[3] + (par("usr")[4] - par("usr")[3]) * 0.60,
           legend = "Keylines",
           col = keyline_color,
           lwd = keyline_width,
           bg = "white",
           box.col = "black",
           cex = 0.4,
           xjust = 1,
           yjust = 0)
    par(xpd = FALSE)
  }

  message("Keylines plot complete!")

  return(invisible(list(
    dtm       = dtm,
    slope     = metrics$slope,
    hillshade = metrics$hillshade,
    contours  = metrics$contours,
    keylines  = keylines
  )))
}
