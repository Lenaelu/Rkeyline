#' Calculate Geomorphology Metrics from dtm
#'
#' This function calculates various geometric and hydrological metrics from a
#' Digital Elevation Model (dtm). It computes terrain attributes, performs
#' hydrological processing (including inverted processing for ridge extraction),
#' and returns all metrics in a structured list.
#'
#' @param dtm A SpatRaster object imported with \code{terra::rast()}. Must be
#'   a valid digital elevation model.
#' @param output_folder Character string specifying the directory path for
#'   temporary whitebox processing files. Defaults to a temporary directory.
#' @param contour_interval Numeric value for contour line spacing in elevation
#'   units. Default is 10.
#' @param stream_threshold Numeric value for stream and ridge extraction threshold
#'   (number of cells). Default is 1000. Adjust based on your study area size.
#' @param breach_dist Maximum breach distance for depression filling in cells.
#'   Default is 50.
#' @param hillshade_angle Sun angle for hillshade calculation in degrees.
#'   Default is 45.
#' @param hillshade_direction Sun direction for hillshade calculation in degrees.
#'   Default is 270 (from west).
#'
#' @return A list containing the following geometric metrics:
#'   \item{contours}{sf object with contour lines}
#'   \item{slope}{SpatRaster of slope in degrees}
#'   \item{aspect}{SpatRaster of aspect in radians}
#'   \item{hillshade}{SpatRaster of hillshade}
#'   \item{dtm_filled}{SpatRaster of depression-filled dtm}
#'   \item{flow_pointer}{SpatRaster of D8 flow pointers}
#'   \item{flow_acc}{SpatRaster of flow accumulation}
#'   \item{flow_acc_log}{SpatRaster of log-transformed flow accumulation}
#'   \item{streams}{SpatRaster of extracted stream network}
#'   \item{dtm_inverted}{SpatRaster of inverted dtm (for ridge analysis)}
#'   \item{dtm_filled_inverted}{SpatRaster of depression-filled inverted dtm}
#'   \item{flow_pointer_inverted}{SpatRaster of D8 flow pointers for inverted dtm}
#'   \item{flow_acc_inverted}{SpatRaster of flow accumulation for inverted dtm}
#'   \item{streams_inverted}{SpatRaster of extracted streams_inverted}
#'   \item{output_folder}{Character string of the output folder path used}
#'
#' @details
#' The function performs the following calculations in order:
#' \enumerate{
#'   \item Basic terrain attributes (contours, slope, aspect, hillshade)
#'   \item Depression filling using least-cost breaching
#'   \item D8 flow pointer calculation
#'   \item Flow accumulation
#'   \item Log-transformed flow accumulation
#'   \item Stream network extraction
#'   \item Inverted dtm creation (dtm * -1)
#'   \item Inverted hydrological processing (for ridge extraction)
#'   \item Ridge network extraction
#' }
#'
#' The inverted hydrological processing creates a "reversed" topography where
#' valleys become ridges and vice versa. This allows for the extraction of
#' ridge networks using the same flow accumulation algorithms used for streams.
#'
#' @note
#' Requires the \code{terra}, \code{whitebox}, and \code{sf} packages.
#' Make sure whitebox tools are properly installed with
#' \code{whitebox::install_whitebox()}.
#'
#' @examples
#' \dontrun{
#'
#' # Load your dtm
#' dtm <- rast("path/to/your/dtm.tif")
#'
#' # Calculate all metrics with defaults
#' metrics <- calc_geomorphology_metrics(dtm)
#'
#' # Access individual metrics
#' plot(metrics$slope)
#' plot(metrics$hillshade)
#' plot(metrics$streams)
#' plot(metrics$streams_inverted)
#'
#' # Custom parameters
#' metrics <- calc_geomorphology_metrics(
#'   dtm = dtm,
#'   output_folder = "C:/my_project/temp",
#'   contour_interval = 20,
#'   stream_threshold = 500
#' )
#' }
#' @export
calc_geomorph_metrics <- function(dtm,
                                  output_folder = tempdir(),
                                  contour_interval = 10,
                                  stream_threshold = 1000,
                                  breach_dist = 50,
                                  hillshade_angle = 45,
                                  hillshade_direction = 270) {

  # Input validation
  if (!inherits(dtm, "SpatRaster")) {
    stop("Input 'dtm' must be a SpatRaster object. Please import with terra::rast()")
  }

  if (!dir.exists(output_folder)) {
    dir.create(output_folder, recursive = TRUE)
    message("Created output folder: ", output_folder)
  }

  # Check required packages
  required_pkgs <- c("terra", "whitebox", "sf")
  missing_pkgs <- required_pkgs[!sapply(required_pkgs, requireNamespace, quietly = TRUE)]
  if (length(missing_pkgs) > 0) {
    stop("Required packages missing: ", paste(missing_pkgs, collapse = ", "))
  }

  message("Calculating geomorphology metrics...")

  # =========================================================================
  # Basic terrain attributes
  # =========================================================================

  message("Computing contours, slope, aspect, and hillshade...")

  # Contours
  contours <- terra::as.contour(
    dtm,
    levels = seq(0, max(terra::values(dtm), na.rm = TRUE), contour_interval)
  )

  # Slope (degrees)
  slope <- terra::terrain(dtm, "slope", unit = "degrees")

  # Aspect (radians)
  aspect <- terra::terrain(dtm, "aspect", unit = "radians")

  # Hillshade
  hillshade <- terra::shade(slope, aspect,
                            angle = hillshade_angle,
                            direction = hillshade_direction)

  # =========================================================================
  # Hydrolocial processing
  # =========================================================================

  message("Performing hydrological processing...")

  # Save dtm temporarily for whitebox processing
  dtm_path <- file.path(output_folder, "temp_dtm.tif")
  terra::writeRaster(dtm, dtm_path, overwrite = TRUE)

  # Fill depressions
  dtm_filled_path <- file.path(output_folder, "dtm_filled.tif")
  whitebox::wbt_breach_depressions_least_cost(
    dem = dtm_path,
    output = dtm_filled_path,
    dist = breach_dist
  )

  # D8 flow pointer
  flow_pointer_path <- file.path(output_folder, "flow_pointer.tif")
  whitebox::wbt_d8_pointer(
    dem = dtm_filled_path,
    output = flow_pointer_path
  )

  # Flow accumulation
  flow_acc_path <- file.path(output_folder, "flow_acc.tif")
  whitebox::wbt_d8_flow_accumulation(
    input = dtm_filled_path,
    output = flow_acc_path
  )

  # Extract streams
  streams_path <- file.path(output_folder, "streams.tif")
  whitebox::wbt_extract_streams(
    flow_accum = flow_acc_path,
    output = streams_path,
    threshold = stream_threshold
  )

  # =========================================================================
  # Hydrological processing inverted
  # =========================================================================

  message("Performing hydrological processing inverted...")

  # Inverted dtm
  dtm_inverted_path <- file.path(output_folder, "dtm_inverted.tif")
  dtm_inverted <- dtm * -1
  terra::writeRaster(dtm_inverted, dtm_inverted_path, overwrite = TRUE)

  # Fill depressions inverted
  dtm_filled_inverted_path <- file.path(output_folder, "dtm_filled_inverted.tif")
  whitebox::wbt_breach_depressions_least_cost(
    dem = dtm_inverted_path,
    output = dtm_filled_inverted_path,
    dist = breach_dist)

  # D8 flow pointer inverted
  flow_pointer_inverted_path <- file.path(output_folder, "flow_pointer_inverted.tif")
  whitebox::wbt_d8_pointer(
    dem = dtm_filled_inverted_path,
    output = flow_pointer_inverted_path)

  # Flow accumulation inverted
  flow_acc_inverted_path <- file.path(output_folder, "flow_acc_inverted.tif")
  whitebox::wbt_d8_flow_accumulation(
    input = dtm_filled_inverted_path,
    output = flow_acc_inverted_path)

  # Extract streams inverted
  streams_inverted_path <- file.path(output_folder, "streams_inverted.tif")
  whitebox::wbt_extract_streams(
    flow_accum = flow_acc_inverted_path,
    output = streams_inverted_path,
    threshold = stream_threshold)

  # =========================================================================
  # Load results into R
  # =========================================================================

  message("Loading results...")

  dtm_filled <- terra::rast(dtm_filled_path)
  flow_pointer <- terra::rast(flow_pointer_path)
  flow_acc <- terra::rast(flow_acc_path)
  flow_acc_inverted <- terra::rast(flow_acc_inverted_path)
  streams <- terra::rast(streams_path)
  dtm_inverted <- terra::rast(dtm_inverted_path)
  dtm_filled_inverted <- terra::rast(dtm_filled_inverted_path)
  flow_pointer_inverted <- terra::rast(flow_pointer_inverted_path)
  flow_acc_inverted <- terra::rast(flow_acc_inverted_path)
  streams_inverted <- terra::rast(streams_inverted_path)

  # Calculate log-transformed flow accumulation
  flow_acc_log <- log(flow_acc + 1)  # avoid log(0) issues

  # =========================================================================
  # Return results
  # =========================================================================

  message("All geomorphology metrics calculated successfully.")
  message("\n========================================")
  message("Summary")
  message("========================================")

  results <- list(
    contours = contours,
    slope = slope,
    aspect = aspect,
    hillshade = hillshade,
    dtm_filled = dtm_filled,
    flow_pointer = flow_pointer,
    flow_acc = flow_acc,
    flow_acc_log = flow_acc_log,
    flow_acc_inverted = flow_acc_inverted,
    streams = streams,
    dtm_inverted = dtm_inverted,
    dtm_filled_inverted = dtm_filled_inverted,
    flow_pointer_inverted = flow_pointer_inverted,
    flow_acc_inverted = flow_acc_inverted,
    streams_inverted = streams_inverted,
    output_folder = output_folder
  )

  # Print summary information
  message("\nTerrain Attributes:")
  message("Contours: ", nrow(contours), " lines")
  message("Slope: ", round(min(terra::values(slope), na.rm = TRUE), 2), "degrees to ",
          round(max(terra::values(slope), na.rm = TRUE), 2), "degrees")
  message("Aspect: computed (radians)")
  message("Hillshade: computed")

  message("\nHydrological Metrics:")
  message("Dtm filled: depressions breached")
  message("Flow pointer: D8 algorithm")
  message("Flow accumulation: max ",
          format(max(terra::values(flow_acc), na.rm = TRUE), big.mark = ","), " cells")
  message("Flow accumulation (log): computed")
  message("Streams extracted: threshold = ", stream_threshold, " cells")

  message("\nInverted Hydrological Metrics (for ridges):")
  message("Dtm inverted: computed")
  message("Dtm filled inverted: depressions breached")
  message("Flow pointer inverted: D8 algorithm")
  message("Flow accumulation inverted: max ",
          format(max(terra::values(flow_acc_inverted), na.rm = TRUE), big.mark = ","), " cells")
  message("Streams inverted extracted: threshold = ", stream_threshold, " cells")

  message("\nOutput files saved to:")
  message("  ", output_folder)

  message("\nAccess metrics from the returned list:")
  message("  $contours, $slope, $aspect, $hillshade")
  message("  $dtm_filled, $flow_pointer, $flow_acc, $flow_acc_log, $streams")
  message("  $dtm_inverted, $dtm_filled_inverted, $flow_pointer_inverted")
  message("  $flow_acc_inverted, $streams_inverted")
  message("========================================\n")

  return(results)
}
