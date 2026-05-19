# Extract Main Valley Lines from dtm

This function identifies and extracts the main valley lines based on
flow accumulation values. It selects the top N valley tributaries by
maximum flow accumulation, merges segments within each tributary, and
returns the result with ranking information.

## Usage

``` r
extract_main_valleys(valleys, dtm, nr_main = 2, metrics, plot_result = FALSE)
```

## Arguments

- valleys:

  An sf object containing valley line network with TRIB_ID attribute.
  This must be pre-extracted using extract_networks(dtm, type =
  "valley", metrics = metrics). This parameter is REQUIRED.

- dtm:

  A SpatRaster object (from terra package) representing the digital
  elevation model. Used for spatial reference.

- nr_main:

  Integer specifying the number of main valleys to extract. Default is
  2.

- metrics:

  A list containing pre-calculated geomorphometric metrics from
  calc_geomorph_metrics(). This parameter is REQUIRED. Must contain
  flow_acc for valley analysis.

- plot_result:

  Logical. Should the result be plotted? Default is FALSE.

## Value

An sf object containing main valley lines with attributes:

- TRIB_ID: Tributary identifier

- RANK: Ranking (1 = highest flow accumulation)

- flow_acc_max: Maximum flow accumulation value for the tributary

- geometry: LINESTRING geometry

## Details

This version matches the QGIS plugin behavior by:

1.  Rasterizing valley lines to extract flow accumulation at pixel
    centers

2.  Removing confluence points (pixels that touch multiple TRIB_IDs)

3.  Ranking tributaries by their highest non-confluence flow
    accumulation point

The function follows this workflow: Rasterize valley lines to identify
cells containing valleys Extract flow accumulation values at valley cell
centers Create points at those cell centers with flow values Spatially
join points to valley lines (with buffer = half cell size) Remove points
that belong to multiple TRIB_IDs (confluence points) For each TRIB_ID,
find the single point with highest flow accumulation Rank tributaries by
their maximum non-confluence flow value Select top N tributaries Merge
segments within each selected tributary Add RANK attribute (1 = highest
flow) Preserve CRS from input valleys

Note: This method differs from simple terra::extract() by excluding
confluence points where multiple tributaries meet, preventing "flow
accumulation theft" by short segments at confluences.

## Examples

``` r
if (FALSE) { # \dontrun{
dtm <- rast("path/to/dtm.tif")

# Calculate metrics (REQUIRED)
metrics <- calc_geomorph_metrics(dtm)

# Extract valley network (REQUIRED)
valleys <- extract_networks(dtm, type = "valley", metrics = metrics)

# Extract main valleys (QGIS-compatible method)
main_valleys <- extract_main_valleys(
  valleys = valleys,
  dtm = dtm,
  nr_main = 2,
  metrics = metrics
)
} # }
```
