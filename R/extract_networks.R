#' Extract Valley or Ridge Networks from dtm
#'
#' This function extracts valley or ridge networks from a digital elevation model (dtm)
#' using stream network analysis. It processes the dtm to identify valleys or ridges,
#' calculates their lengths, and optionally smooths the resulting lines.
#'
#' @param dtm A SpatRaster object (from terra package) representing the digital elevation model
#' @param type Character. Type of network to extract: "valley" or "ridge". Default is "valley".
#' @param metrics A list containing pre-calculated geomorphometric metrics from calc_geomorph_metrics().
#'   This parameter is REQUIRED.
#'   For valleys: Must contain flow_pointer and streams
#'   For ridges: Must contain flow_pointer_inverted and streams_inverted
#' @param output_folder Path to folder for temporary whitebox processing files.
#'   Defaults to a temporary directory.
#' @param smooth_lines Logical. Should lines be smoothed using Chaikin's algorithm?
#'   Default is TRUE.
#' @param plot_result Logical. Should the result be plotted? Default is FALSE.
#' @param cleanup Logical. Should temporary files be removed after processing?
#'   Default is TRUE.
#'
#' @return An sf object containing valley or ridge line geometries with length attribute and preserved CRS
#'
#' @importFrom terra rast crs
#' @importFrom whitebox wbt_init wbt_raster_streams_to_vector wbt_vector_stream_network_analysis
#' @importFrom sf st_read st_length st_crs st_crs<-
#' @importFrom smoothr smooth
#'
#' @examples
#' \dontrun{
#' dtm <- rast("path/to/dtm.tif")
#'
#' # Calculate metrics first (REQUIRED)
#' metrics <- calc_geomorph_metrics(dtm)
#'
#' # Extract valleys
#' valleys <- extract_networks(dtm, type = "valley", metrics = metrics)
#'
#' # Extract ridges
#' ridges <- extract_networks(dtm, type = "ridge", metrics = metrics)
#' }
#'
#' @export
extract_networks <- function(dtm,
                             type = c("valley", "ridge"),
                             metrics,
                             output_folder = NULL,
                             smooth_lines = TRUE,
                             plot_result = FALSE,
                             cleanup = TRUE) {

  # Input validation
  if (!inherits(dtm, "SpatRaster")) {
    stop("dtm must be a SpatRaster object from the terra package")
  }

  # Check that metrics is provided
  if (missing(metrics)) {
    stop("The 'metrics' parameter is required. Please calculate metrics first using calc_geomorph_metrics(dtm) and pass the result to this function.")
  }

  if (is.null(metrics)) {
    stop("The 'metrics' parameter cannot be NULL. Please calculate metrics first using calc_geomorph_metrics(dtm).")
  }

  if (!is.list(metrics)) {
    stop("The 'metrics' parameter must be a list object returned from calc_geomorph_metrics().")
  }

  # Match and validate type argument
  type <- match.arg(type)

  # Set up output folder
  if (is.null(output_folder)) {
    output_folder <- tempdir()
  }

  if (!dir.exists(output_folder)) {
    dir.create(output_folder, recursive = TRUE)
  }

  # Set parameters based on type
  if (type == "valley") {
    required_metrics <- c("flow_pointer", "streams")
    flow_pointer <- metrics$flow_pointer
    streams <- metrics$streams
    file_prefix <- "valleys"
    plot_title <- "Extracted Valleys"
  } else {  # ridge
    required_metrics <- c("flow_pointer_inverted", "streams_inverted")
    flow_pointer <- metrics$flow_pointer_inverted
    streams <- metrics$streams_inverted
    file_prefix <- "ridges"
    plot_title <- "Extracted Ridges"
  }

  # Validate metrics object
  missing_metrics <- setdiff(required_metrics, names(metrics))
  if (length(missing_metrics) > 0) {
    stop("Missing required metrics: ", paste(missing_metrics, collapse = ", "),
         ". Please ensure you calculated metrics using calc_geomorph_metrics(dtm).")
  }

  # Store dtm CRS to preserve it throughout processing
  dtm_crs <- crs(dtm)

  # Initialize whitebox
  message("Initializing WhiteboxTools...")
  wbt_init()

  # Define temporary file paths
  streams_vector_path <- file.path(output_folder, paste0(file_prefix, "_vector.shp"))
  networks_analyzed_path <- file.path(output_folder, paste0(file_prefix, "_analyzed.shp"))

  # Convert raster streams to vector
  wbt_raster_streams_to_vector(
    streams = streams,
    d8_pntr = flow_pointer,
    output = streams_vector_path
  )

  # Perform vector stream network analysis
  wbt_vector_stream_network_analysis(
    streams = streams_vector_path,
    output = networks_analyzed_path
  )

  # Import networks
  networks <- st_read(networks_analyzed_path, quiet = TRUE)

  # Store CRS after reading (should match dtm)
  networks_crs <- st_crs(networks)

  # Add length attribute
  networks$length_m <- as.numeric(st_length(networks))

  # Smooth lines if requested
  if (smooth_lines) {
    networks <- smooth(networks, method = "chaikin")

    # Restore CRS after smoothing
    # The smooth() function can sometimes drop the CRS
    if (is.na(st_crs(networks))) {
      st_crs(networks) <- networks_crs
    }
  }

  # Final CRS check: ensure CRS matches dtm
  if (is.na(st_crs(networks))) {
    message("Warning: CRS was lost during processing. Restoring from dtm...")
    st_crs(networks) <- dtm_crs
  }

  # Clean up temporary files if requested
  if (cleanup) {
    message("Cleaning up temporary files...")
    temp_files <- c(
      streams_vector_path,
      networks_analyzed_path,
      gsub("\\.shp$", ".shx", streams_vector_path),
      gsub("\\.shp$", ".dbf", streams_vector_path),
      gsub("\\.shp$", ".prj", streams_vector_path),
      gsub("\\.shp$", ".shx", networks_analyzed_path),
      gsub("\\.shp$", ".dbf", networks_analyzed_path),
      gsub("\\.shp$", ".prj", networks_analyzed_path)
    )

    for (f in temp_files) {
      if (file.exists(f)) {
        file.remove(f)
      }
    }
  }

  # Plot if requested
  if (plot_result) {
    plot(networks, main = plot_title)
  }

  message(sprintf("%s extraction complete!", tools::toTitleCase(type)))
  return(networks)
}


#' Extract Valley Networks from dtm
#'
#' Wrapper function for extracting valley networks. See extract_networks() for details.
#'
#' @inheritParams extract_networks
#' @param smooth_valleys Logical. Should valley lines be smoothed? Default is TRUE.
#'
#' @return An sf object containing valley line geometries with length attribute
#' @export
extract_valleys <- function(dtm,
                            metrics,
                            output_folder = NULL,
                            smooth_valleys = TRUE,
                            plot_result = FALSE,
                            cleanup = TRUE) {
  extract_networks(
    dtm = dtm,
    type = "valley",
    metrics = metrics,
    output_folder = output_folder,
    smooth_lines = smooth_valleys,
    plot_result = plot_result,
    cleanup = cleanup
  )
}


#' Extract Ridge Networks from dtm
#'
#' Wrapper function for extracting ridge networks. See extract_networks() for details.
#'
#' @inheritParams extract_networks
#' @param smooth_ridges Logical. Should ridge lines be smoothed? Default is TRUE.
#'
#' @return An sf object containing ridge line geometries with length attribute
#' @export
extract_ridges <- function(dtm,
                           metrics,
                           output_folder = NULL,
                           smooth_ridges = TRUE,
                           plot_result = FALSE,
                           cleanup = TRUE) {
  extract_networks(
    dtm = dtm,
    type = "ridge",
    metrics = metrics,
    output_folder = output_folder,
    smooth_lines = smooth_ridges,
    plot_result = plot_result,
    cleanup = cleanup
  )
}
