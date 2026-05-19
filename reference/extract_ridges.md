# Extract Ridge Networks from dtm

Wrapper function for extracting ridge networks. See extract_networks()
for details.

## Usage

``` r
extract_ridges(
  dtm,
  metrics,
  output_folder = NULL,
  smooth_ridges = TRUE,
  plot_result = FALSE,
  cleanup = TRUE
)
```

## Arguments

- dtm:

  A SpatRaster object (from terra package) representing the digital
  elevation model

- metrics:

  A list containing pre-calculated geomorphometric metrics from
  calc_geomorph_metrics(). This parameter is REQUIRED. For valleys: Must
  contain flow_pointer and streams For ridges: Must contain
  flow_pointer_inverted and streams_inverted

- output_folder:

  Path to folder for temporary whitebox processing files. Defaults to a
  temporary directory.

- smooth_ridges:

  Logical. Should ridge lines be smoothed? Default is TRUE.

- plot_result:

  Logical. Should the result be plotted? Default is FALSE.

- cleanup:

  Logical. Should temporary files be removed after processing? Default
  is TRUE.

## Value

An sf object containing ridge line geometries with length attribute
