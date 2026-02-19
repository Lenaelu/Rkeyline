#' Extract Main Valley Lines from dtm
#'
#' This function identifies and extracts the main valley lines based on flow accumulation
#' values. It selects the top N valley tributaries by maximum flow accumulation, merges
#' segments within each tributary, and returns the result with ranking information.
#'
#' This version matches the QGIS plugin behavior by:
#' 1. Rasterizing valley lines to extract flow accumulation at pixel centers
#' 2. Removing confluence points (pixels that touch multiple TRIB_IDs)
#' 3. Ranking tributaries by their highest non-confluence flow accumulation point
#'
#' @param valleys An sf object containing valley line network with TRIB_ID attribute.
#'   This must be pre-extracted using extract_networks(dtm, type = "valley", metrics = metrics).
#'   This parameter is REQUIRED.
#' @param dtm A SpatRaster object (from terra package) representing the digital elevation model.
#'   Used for spatial reference.
#' @param nr_main Integer specifying the number of main valleys to extract. Default is 2.
#' @param metrics A list containing pre-calculated geomorphometric metrics from calc_geomorph_metrics().
#'   This parameter is REQUIRED. Must contain flow_acc for valley analysis.
#' @param plot_result Logical. Should the result be plotted? Default is FALSE.
#'
#' @return An sf object containing main valley lines with attributes:
#'   - TRIB_ID: Tributary identifier
#'   - RANK: Ranking (1 = highest flow accumulation)
#'   - flow_acc_max: Maximum flow accumulation value for the tributary
#'   - geometry: LINESTRING geometry
#'
#' @details
#' The function follows this workflow:
#' Rasterize valley lines to identify cells containing valleys
#' Extract flow accumulation values at valley cell centers
#' Create points at those cell centers with flow values
#' Spatially join points to valley lines (with buffer = half cell size)
#' Remove points that belong to multiple TRIB_IDs (confluence points)
#' For each TRIB_ID, find the single point with highest flow accumulation
#' Rank tributaries by their maximum non-confluence flow value
#' Select top N tributaries
#' Merge segments within each selected tributary
#' Add RANK attribute (1 = highest flow)
#' Preserve CRS from input valleys
#'
#' Note: This method differs from simple terra::extract() by excluding confluence points
#' where multiple tributaries meet, preventing "flow accumulation theft" by short
#' segments at confluences.
#'
#' @importFrom terra rast res ext crs
#' @importFrom sf st_as_sf st_buffer st_join st_union st_geometry st_crs st_crs<- st_bbox st_coordinates
#' @importFrom dplyr group_by summarize left_join mutate select arrange slice_head n
#'
#' @examples
#' \dontrun{
#' dtm <- rast("path/to/dtm.tif")
#'
#' # Calculate metrics (REQUIRED)
#' metrics <- calc_geomorph_metrics(dtm)
#'
#' # Extract valley network (REQUIRED)
#' valleys <- extract_networks(dtm, type = "valley", metrics = metrics)
#'
#' # Extract main valleys (QGIS-compatible method)
#' main_valleys <- extract_main_valleys(
#'   valleys = valleys,
#'   dtm = dtm,
#'   nr_main = 2,
#'   metrics = metrics
#' )
#' }
#'
#' @export
extract_main_valleys <- function(valleys,
                                 dtm,
                                 nr_main = 2,
                                 metrics,
                                 plot_result = FALSE) {

  # Input validation
  if (missing(valleys)) {
    stop("The 'valleys' parameter is required. Please extract valleys first using extract_networks(dtm, type = 'valley', metrics = metrics) and pass the result to this function.")
  }

  if (!inherits(valleys, "sf")) {
    stop("valleys must be an sf object from the sf package")
  }

  if (!"TRIB_ID" %in% names(valleys)) {
    stop("valleys must have a TRIB_ID attribute. Please use extract_networks() to generate the valley network.")
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

  if (!"flow_acc" %in% names(metrics)) {
    stop("Missing required metric: flow_acc. Please ensure you calculated metrics using calc_geomorph_metrics(dtm).")
  }

  if (nr_main < 1) {
    stop("nr_main must be at least 1")
  }

  # Store original CRS to preserve it
  original_crs <- st_crs(valleys)

  # Import necessary metrics
  flow_acc <- metrics$flow_acc

  message("Processing valley tributaries...")

  # Get raster properties
  dtm_res <- res(dtm)[1]  # Assuming square pixels
  dtm_extent <- ext(dtm)

  # Rasterize valley lines to create a binary mask
  valley_rast <- rasterize(vect(valleys), dtm, field = 1, background = 0)

  # Find all cells where valleys exist and flow_acc > 0
  valley_mask <- valley_rast == 1
  flow_mask <- flow_acc > 0
  valid_mask <- valley_mask & flow_mask

  # Get cell indices where valleys exist with flow > 0
  cell_indices <- which(values(valid_mask) == 1)

  if (length(cell_indices) == 0) {
    stop("No valley cells found with flow accumulation > 0")
  }

  # Get coordinates of cell centers
  cell_coords <- xyFromCell(flow_acc, cell_indices)

  # Get flow accumulation values at these cells
  facc_values <- values(flow_acc)[cell_indices]

  # Create points at cell centers with flow accumulation values
  points_sf <- st_as_sf(
    data.frame(
      x = cell_coords[, 1],
      y = cell_coords[, 2],
      facc = facc_values
    ),
    coords = c("x", "y"),
    crs = original_crs
  )

  # Spatial join with valley lines (using buffered points)
  # Buffer points by half cell size to ensure we capture lines at cell edges
  buffer_distance <- dtm_res / 2.0
  points_buffered <- st_buffer(points_sf, buffer_distance)

  # Join to valleys to get TRIB_ID
  points_joined <- st_join(points_buffered, valleys[, "TRIB_ID"], join = st_intersects)

  # Remove points that didn't join to any valley
  points_joined <- points_joined[!is.na(points_joined$TRIB_ID), ]

  if (nrow(points_joined) == 0) {
    stop("No points successfully joined to valley lines")
  }

  # Remove confluence points (points that touch multiple TRIB_IDs)
  # Get original point geometries (unbuffered) for duplicate detection
  points_joined$geom_wkt <- st_as_text(st_geometry(points_sf)[as.numeric(rownames(points_joined))])

  # Count how many unique TRIB_IDs each point geometry touches
  geom_trib_counts <- points_joined %>%
    st_drop_geometry() %>%
    group_by(geom_wkt) %>%
    summarize(n_trib_ids = n_distinct(TRIB_ID), .groups = 'drop')

  # Keep only points that touch exactly one TRIB_ID
  valid_geoms <- geom_trib_counts$geom_wkt[geom_trib_counts$n_trib_ids == 1]
  points_unique <- points_joined[points_joined$geom_wkt %in% valid_geoms, ]

  n_removed <- nrow(points_joined) - nrow(points_unique)

  if (nrow(points_unique) == 0) {
    stop("No valid points remaining after removing confluence points")
  }

  # For each TRIB_ID, find the point with highest flow accumulation
    points_sorted <- points_unique %>%
    st_drop_geometry() %>%
    arrange(desc(facc))

  # Get one point per TRIB_ID (the one with highest facc)
  points_top_per_trib <- points_sorted %>%
    group_by(TRIB_ID) %>%
    slice_head(n = 1) %>%
    ungroup()

  # Rank tributaries by their maximum flow accumulation
  trib_rankings <- points_top_per_trib %>%
    arrange(desc(facc)) %>%
    mutate(RANK = row_number()) %>%
    select(TRIB_ID, RANK, flow_acc_max = facc)

  # Check if we have enough tributaries
  if (nrow(trib_rankings) < nr_main) {
    warning(sprintf("Only %d valley tributaries available, but nr_main = %d. Returning all available.",
                    nrow(trib_rankings), nr_main))
    nr_main <- nrow(trib_rankings)
  }

  # Select top N tributaries
  top_tribs <- trib_rankings %>%
    slice_head(n = nr_main)

  message(sprintf("Selected top %d valley tributaries:", nr_main))
  for (i in 1:nrow(top_tribs)) {
    message(sprintf("  RANK %d: TRIB_ID %d (flow_acc = %.0f)",
                    top_tribs$RANK[i],
                    top_tribs$TRIB_ID[i],
                    top_tribs$flow_acc_max[i]))
  }

  # Extract and merge valley segments for selected tributaries
  main_valleys <- valleys[valleys$TRIB_ID %in% top_tribs$TRIB_ID, ]

  # Group all segments from the same tributary together
  main_valleys_merged <- main_valleys %>%
    group_by(TRIB_ID) %>%
    summarize(geometry = st_union(geometry), .groups = 'drop')

  # Add ranking and flow accumulation information
  main_valleys_merged <- left_join(
    main_valleys_merged,
    top_tribs,
    by = "TRIB_ID"
  )

  # Reorder columns for clarity
  main_valleys_merged <- main_valleys_merged %>%
    select(TRIB_ID, RANK, flow_acc_max, geometry)

  # Step 10: Preserve CRS from input valleys
  st_crs(main_valleys_merged) <- original_crs

  # Plot if requested
  if (plot_result) {
    plot(dtm, main = "Main Valley Lines")
    plot(st_geometry(main_valleys_merged), add = TRUE, col = "blue", lwd = 2)
  }

  message("Main valley extraction complete!")
  return(main_valleys_merged)
}
