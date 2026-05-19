# Extract Main Ridge Lines from dtm

This function identifies and extracts the main ridge lines based on flow
accumulation values from inverted dtm. It selects the top N ridge
tributaries by maximum flow accumulation, merges segments within each
tributary, and returns the result with ranking information.

## Usage

``` r
extract_main_ridges(ridges, dtm, nr_main = 2, metrics, plot_result = FALSE)
```

## Arguments

- ridges:

  An sf object containing ridge line network with TRIB_ID attribute.
  This must be pre-extracted using extract_networks(dtm, type = "ridge",
  metrics = metrics). This parameter is REQUIRED.

- dtm:

  A SpatRaster object (from terra package) representing the digital
  elevation model. Used for plotting only.

- nr_main:

  Integer specifying the number of main ridges to extract. Default is 2.

- metrics:

  A list containing pre-calculated geomorphometric metrics from
  calc_geomorph_metrics(). This parameter is REQUIRED. Must contain
  flow_acc_inverted for ridge analysis.

- plot_result:

  Logical. Should the result be plotted? Default is FALSE.

## Value

An sf object containing main ridge lines with attributes:

- TRIB_ID: Tributary identifier

- RANK: Ranking (1 = highest flow accumulation)

- flow_acc_inverted_max: Maximum flow accumulation value for the
  tributary

- geometry: LINESTRING geometry

## Details

The function follows this workflow:

1.  Extract flow accumulation values at each ridge segment

2.  Aggregate by TRIB_ID to find maximum flow per tributary

3.  Select top N tributaries by flow accumulation

4.  Merge segments within each selected tributary

5.  Add RANK attribute (1 = highest flow)

Note: Flow accumulation is extracted from individual segments BEFORE
merging to ensure accurate values. Some tools may merge first, leading
to incorrect results.

## Examples

``` r
if (FALSE) { # \dontrun{
dtm <- rast("path/to/dtm.tif")

# Calculate metrics (REQUIRED)
metrics <- calc_geomorph_metrics(dtm)

# Extract ridge network (REQUIRED)
ridges <- extract_networks(dtm, type = "ridge", metrics = metrics)

# Extract main ridges
main_ridges <- extract_main_ridges(
  ridges = ridges,
  dtm = dtm,
  nr_main = 2,
  metrics = metrics
)

} # }
```
