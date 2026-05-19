# Terrain Analysis with Stream Network Visualization

Creates a visualization of terrain analysis including slope, contours,
and stream network. This function uses pre-calculated geomorphology
metrics from
[`calc_geomorph_metrics()`](https://lenaelu.github.io/Rkeyline/reference/calc_geomorph_metrics.md).

## Usage

``` r
plot_slope_channels(
  dtm,
  metrics,
  contour_interval = 10,
  stream_threshold = 1000,
  hillshade_angle = 45,
  hillshade_direction = 270,
  contour_color = "darkorange4",
  contour_width = 1,
  label_size = 0.8,
  slope_alpha = 0.6,
  stream_color = "blue",
  stream_width = 1,
  main_title = "Slope with contours and streams"
)
```

## Arguments

- dtm:

  SpatRaster. dtm raster object from the terra package.

- metrics:

  Optional. A list object returned from
  [`calc_geomorph_metrics()`](https://lenaelu.github.io/Rkeyline/reference/calc_geomorph_metrics.md).
  If NULL, the function will calculate metrics internally. Default is
  NULL.

- contour_interval:

  Numeric. Elevation interval for contour lines. Default is 10.

- stream_threshold:

  Numeric. Threshold value for stream extraction (number of cells).
  Higher values result in fewer streams. Default is 1000.

- hillshade_angle:

  Numeric. Sun elevation angle for hillshade calculation (0-90 degrees).
  Default is 45.

- hillshade_direction:

  Numeric. Sun azimuth direction for hillshade (0-360 degrees). Default
  is 270.

- contour_color:

  Character. Color for contour lines. Default is "darkorange4".

- contour_width:

  Numeric. Line width for contours. Default is 1.

- label_size:

  Numeric. Size of contour labels. Default is 0.8.

- slope_alpha:

  Numeric. Transparency of slope overlay (0-1). Default is 0.6.

- stream_color:

  Character. Color for stream network. Default is "blue".

- stream_width:

  Numeric. Line width for streams. Default is 1.

- main_title:

  Character. Plot title. Default is "Slope with contours and streams".

## Value

A named list containing:

- `dtm`: Original dtm as SpatRaster

- `slope`: Slope in degrees as SpatRaster

- `aspect`: Aspect in radians as SpatRaster

- `hillshade`: Hillshade as SpatRaster

- `contours`: Contour lines as SpatVector

- `streams`: Stream network as SpatRaster

- `flow_acc`: Flow accumulation as SpatRaster

## Details

This function creates a comprehensive terrain visualization by:

1.  Using pre-calculated geomorphology metrics (slope, aspect,
    hillshade, contours, streams)

2.  Creating a multi-layer visualization with hillshade, slope,
    contours, and streams

## Note

Requires the following packages: `terra`, `whitebox`, `sf`

## Examples

``` r
if (FALSE) { # \dontrun{
# Load dtm
dtm <- rast("path/to/dtm.tif")

# Calculate metrics once
metrics <- calc_geomorph_metrics(dtm, stream_threshold = 1000)

# Use metrics for plotting
result <- plot_slope_channels(dtm, metrics = metrics)

# Custom parameters
result <- plot_slope_channels(
  dtm = dtm,
  metrics = metrics,
  contour_interval = 20,
  stream_color = "darkblue"
)

# Access individual results
plot(result$slope)
plot(result$streams)
} # }
```
