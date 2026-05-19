# Extract Valley or Ridge Networks from dtm

This function extracts valley or ridge networks from a digital elevation
model (dtm) using stream network analysis. It processes the dtm to
identify valleys or ridges, calculates their lengths, and optionally
smooths the resulting lines.

## Usage

``` r
extract_networks(
  dtm,
  type = c("valley", "ridge"),
  metrics,
  output_folder = NULL,
  smooth_lines = TRUE,
  plot_result = FALSE,
  cleanup = TRUE
)
```

## Arguments

- dtm:

  A SpatRaster object (from terra package) representing the digital
  elevation model

- type:

  Character. Type of network to extract: "valley" or "ridge". Default is
  "valley".

- metrics:

  A list containing pre-calculated geomorphometric metrics from
  calc_geomorph_metrics(). This parameter is REQUIRED. For valleys: Must
  contain flow_pointer and streams For ridges: Must contain
  flow_pointer_inverted and streams_inverted

- output_folder:

  Path to folder for temporary whitebox processing files. Defaults to a
  temporary directory.

- smooth_lines:

  Logical. Should lines be smoothed using Chaikin's algorithm? Default
  is TRUE.

- plot_result:

  Logical. Should the result be plotted? Default is FALSE.

- cleanup:

  Logical. Should temporary files be removed after processing? Default
  is TRUE.

## Value

An sf object containing valley or ridge line geometries with length
attribute and preserved CRS

## Examples

``` r
if (FALSE) { # \dontrun{
dtm <- rast("path/to/dtm.tif")

# Calculate metrics first (REQUIRED)
metrics <- calc_geomorph_metrics(dtm)

# Extract valleys
valleys <- extract_networks(dtm, type = "valley", metrics = metrics)

# Extract ridges
ridges <- extract_networks(dtm, type = "ridge", metrics = metrics)
} # }
```
