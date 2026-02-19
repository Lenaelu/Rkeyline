#' Extract Main Ridge Lines from dtm
#'
#' This function identifies and extracts the main ridge lines based on flow accumulation
#' values from inverted dtm. It selects the top N ridge tributaries by maximum flow
#' accumulation, merges segments within each tributary, and returns the result with
#' ranking information.
#'
#' @param ridges An sf object containing ridge line network with TRIB_ID attribute.
#'   This must be pre-extracted using extract_networks(dtm, type = "ridge", metrics = metrics).
#'   This parameter is REQUIRED.
#' @param dtm A SpatRaster object (from terra package) representing the digital elevation model.
#'   Used for plotting only.
#' @param nr_main Integer specifying the number of main ridges to extract. Default is 2.
#' @param metrics A list containing pre-calculated geomorphometric metrics from calc_geomorph_metrics().
#'   This parameter is REQUIRED. Must contain flow_acc_inverted for ridge analysis.
#' @param plot_result Logical. Should the result be plotted? Default is FALSE.
#'
#' @return An sf object containing main ridge lines with attributes:
#'   - TRIB_ID: Tributary identifier
#'   - RANK: Ranking (1 = highest flow accumulation)
#'   - flow_acc_inverted_max: Maximum flow accumulation value for the tributary
#'   - geometry: LINESTRING geometry
#'
#' @details
#' The function follows this workflow:
#' 1. Extract flow accumulation values at each ridge segment
#' 2. Aggregate by TRIB_ID to find maximum flow per tributary
#' 3. Select top N tributaries by flow accumulation
#' 4. Merge segments within each selected tributary
#' 5. Add RANK attribute (1 = highest flow)
#'
#' Note: Flow accumulation is extracted from individual segments BEFORE merging
#' to ensure accurate values. Some tools may merge first, leading to incorrect results.
#'
#' @importFrom terra vect extract
#' @importFrom sf st_union st_geometry
#' @importFrom dplyr group_by summarize left_join mutate select
#'
#' @examples
#' \dontrun{
#' dtm <- rast("path/to/dtm.tif")
#'
#' # Calculate metrics (REQUIRED)
#' metrics <- calc_geomorph_metrics(dtm)
#'
#' # Extract ridge network (REQUIRED)
#' ridges <- extract_networks(dtm, type = "ridge", metrics = metrics)
#'
#' # Extract main ridges
#' main_ridges <- extract_main_ridges(
#'   ridges = ridges,
#'   dtm = dtm,
#'   nr_main = 2,
#'   metrics = metrics
#' )
#'
#' }
#'
#' @export
extract_main_ridges <- function(ridges,
                                dtm,
                                nr_main = 2,
                                metrics,
                                plot_result = FALSE) {

  # Input validation
  if (missing(ridges)) {
    stop("The 'ridges' parameter is required. Please extract ridges first using extract_networks(dtm, type = 'ridge', metrics = metrics) and pass the result to this function.")
  }

  if (!inherits(ridges, "sf")) {
    stop("ridges must be an sf object from the sf package")
  }

  if (!"TRIB_ID" %in% names(ridges)) {
    stop("ridges must have a TRIB_ID attribute. Please use extract_networks() to generate the ridge network.")
  }

  if (!inherits(dtm, "SpatRaster")) {
    stop("dtm must be a SpatRaster object from the terra package")
  }

  if (missing(metrics)) {
    stop("The 'metrics' parameter is required. Please calculate metrics first using calc_geomorph_metrics(dtm) and pass the result to this function.")
  }

  if (is.null(metrics)) {
    stop("The 'metrics' parameter cannot be NULL. Please calculate metrics first using calc_geomorph_metrics(dtm).")
  }

  if (!is.list(metrics)) {
    stop("The 'metrics' parameter must be a list object returned from calc_geomorph_metrics().")
  }

  if (!"flow_acc_inverted" %in% names(metrics)) {
    stop("Missing required metric: flow_acc_inverted. Please ensure you calculated metrics using calc_geomorph_metrics(dtm).")
  }

  if (nr_main < 1) {
    stop("nr_main must be at least 1")
  }

  # Import necessary metrics
  flow_acc_inverted <- metrics$flow_acc_inverted

  message("Processing ridge tributaries...")

  # Convert to terra format
  ridges_vect <- vect(ridges)

  # Extract flow accumulation (max value for each line)
  flow_acc_inverted_values <- extract(flow_acc_inverted, ridges_vect, fun = max, na.rm = TRUE)

  # Add flow acc values to ridge
  ridges$flow_acc_inverted_max <- flow_acc_inverted_values[, 2]

  # Convert to df
  ridges_df <- as.data.frame(ridges)

  # For each TRIB_ID find max flow_acc_inverted
  trib_max_flow_acc_inverted <- aggregate(
    flow_acc_inverted_max ~ TRIB_ID,
    data = ridges_df,
    FUN = max
  )

  # Sort by flow acc (highest top)
  trib_max_flow_acc_inverted <- trib_max_flow_acc_inverted[order(-trib_max_flow_acc_inverted$flow_acc_inverted_max), ]

  # Check if we have enough tributaries
  if (nrow(trib_max_flow_acc_inverted) < nr_main) {
    warning(sprintf("Only %d ridge tributaries available, but nr_main = %d. Returning all available.",
                    nrow(trib_max_flow_acc_inverted), nr_main))
    nr_main <- nrow(trib_max_flow_acc_inverted)
  }

  # Take top values of flow acc
  top_tribs <- head(trib_max_flow_acc_inverted, nr_main)

  # Take ridges from selected tributaries
  main_ridges <- ridges[ridges$TRIB_ID %in% top_tribs$TRIB_ID, ]

  # Group all segments from the same tributary together
  main_ridges_merged <- main_ridges %>%
    group_by(TRIB_ID) %>%
    summarize(geometry = st_union(geometry))

  main_ridges_merged <- left_join(
    main_ridges_merged,
    top_tribs %>% mutate(RANK = row_number()),
    by = "TRIB_ID"
  )

  # Reorder columns for clarity
  main_ridges_merged <- main_ridges_merged %>%
    select(TRIB_ID, RANK, flow_acc_inverted_max, geometry)

  # Plot if requested
  if (plot_result) {
    plot(dtm, main = "Main Ridge Lines")
    plot(st_geometry(main_ridges_merged), add = TRUE, col = "red", lwd = 2)
  }

  message("Main ridge extraction complete!")
  return(main_ridges_merged)
}
