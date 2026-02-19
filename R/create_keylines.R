#' Calculate Approximate Keylines from Valley or Ridge Networks
#'
#' @description
#' Generates approximate keylines by sampling elevation values along main valley
#' or ridge lines and matching them to the nearest pre-computed contour lines.
#'
#' **Important:** These keylines are a computational approximation only and should
#' be treated as an orientation for field work. Keylines must always be verified,
#' refined, and adjusted on-site by an experienced practitioner.
#'
#' @param dtm A `SpatRaster` object (terra). The digital elevation model.
#' @param lines A `sf` or `SpatVector` object. Either the main valley lines from
#'   \code{extract_main_valleys()} or the main ridge lines from \code{extract_main_ridges()}.
#' @param contours A `sf` or `SpatVector` object. Pre-computed contour lines with
#'   an elevation column named `level`, typically from \code{calc_geomorph_metrics()}.
#' @param n_keylines Integer. The desired number of keylines per valley or ridge.
#'   Default is 3. Note that the actual number returned may be lower if the input
#'   line does not span enough elevation range to support the requested number.
#'
#' @return A `sf` object containing the approximate keylines with the following columns:
#' \describe{
#'   \item{level}{Elevation of the keyline in map units (usually metres).}
#'   \item{line_id}{Integer ID identifying which valley or ridge the keyline belongs to.}
#'   \item{note}{A reminder that these lines are approximations requiring field validation.}
#' }
#'
#' @note
#' Keyline design is a landscape design methodology developed by P.A. Yeomans.
#' The placement of keylines in the field requires expert judgment and cannot be
#' fully automated. This function provides a spatial approximation to support
#' planning and desktop analysis only.
#'
#' @examples
#' \dontrun{
#' # From valley lines
#' valley_keylines <- create_keylines(dtm, main_valleys, contours, n_keylines = 3)
#'
#' # From ridge lines
#' ridge_keylines <- create_keylines(dtm, main_ridges, contours, n_keylines = 3)
#' }
#'
#' @seealso [calc_geomorph_metrics()], [extract_main_valleys()], [extract_main_ridges()]
#'
#' @export
create_keylines <- function(dtm, lines, contours, n_keylines = 3) {

  # --- Input validation -------------------------------------------------------

  if (!inherits(dtm, "SpatRaster")) {
    stop("'dtm' must be a SpatRaster object (terra).")
  }

  if (!is.numeric(n_keylines) || n_keylines < 1) {
    stop("'n_keylines' must be a positive integer.")
  }

  if (!inherits(lines, "sf"))    lines    <- st_as_sf(lines)
  if (!inherits(contours, "sf")) contours <- st_as_sf(contours)

  # --- Setup ------------------------------------------------------------------

  n_keypoints      <- n_keylines * 5
  contour_levels   <- sort(unique(contours$level))
  contour_interval <- min(diff(contour_levels))

  message(
    "Creating approximate keylines.\n"
  )

  all_keylines <- list()

  # --- Main loop --------------------------------------------------------------

  for (i in 1:nrow(lines)) {

    single_line <- lines[i, ]

    # Sample evenly spaced points along the line
    points_on_line <- st_sample(single_line, size = n_keypoints, type = "regular")
    points_coords  <- st_coordinates(points_on_line)[, 1:2]

    # Extract elevation at each point using bilinear interpolation
    z_values <- extract(dtm, points_coords, method = "bilinear")
    z_clean  <- z_values[, 1][!is.na(z_values[, 1])]

    if (length(z_clean) == 0) {
      warning("Line ", i, ": no valid elevation values found. Skipping.")
      next
    }

    # Snap elevation values to the nearest contour level
    z_snapped <- unique(round(z_clean / contour_interval) * contour_interval)

    # Filter contours to those matching the snapped elevations
    contours_sf <- contours[contours$level %in% z_snapped, ]

    if (nrow(contours_sf) == 0) {
      warning("Line ", i, ": no matching contours found. Skipping.")
      next
    }

    # Select n_keylines evenly spread across the available elevation range
    available_levels <- sort(unique(contours_sf$level))
    actual_n         <- length(available_levels)

    if (actual_n < n_keylines) {
      warning(
        "Line ", i, ": only ", actual_n, " keyline(s) available out of ",
        n_keylines, " requested line does not span enough elevation range. ",
        "Returning all available keylines."
      )
    }

    if (actual_n > n_keylines) {
      selected_levels <- available_levels[round(seq(1, actual_n, length.out = n_keylines))]
      contours_sf     <- contours_sf[contours_sf$level %in% selected_levels, ]
    }

    # Tag output with metadata
    contours_sf$line_id <- i
    contours_sf$note    <- "Approximate keyline desktop estimate only. Field verification and manual adjustment required before implementation."

    all_keylines[[i]] <- contours_sf
  }

  # --- Combine and return -----------------------------------------------------

  if (length(all_keylines) == 0) {
    stop("No keylines could be generated. Check your input data.")
  }

  final_lines <- do.call(rbind, all_keylines)

  message("Done. ", nrow(final_lines), " approximate keyline(s) generated across ",
          length(all_keylines), " line(s).")

  return(final_lines)
}
