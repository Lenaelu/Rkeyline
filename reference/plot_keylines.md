# Plot Keylines with Terrain Context

Plot Keylines with Terrain Context

## Usage

``` r
plot_keylines(
  dtm,
  metrics,
  keylines,
  contour_interval = 10,
  slope_alpha = 0.5,
  contour_color = "darkorange4",
  contour_width = 0.8,
  label_size = 0.7,
  keyline_color = "blue",
  keyline_width = 1.5,
  main_title = "Keylines with slope and contours",
  legend = TRUE
)
```

## Arguments

- dtm:

  SpatRaster. DTM raster object from the terra package.

- metrics:

  A list returned from
  [`calc_geomorph_metrics()`](https://lenaelu.github.io/Rkeyline/reference/calc_geomorph_metrics.md).

- keylines:

  SpatVector. Keylines returned from
  [`create_keylines()`](https://lenaelu.github.io/Rkeyline/reference/create_keylines.md).

- contour_interval:

  Numeric. Elevation interval for contour lines. Default is 10.

- slope_alpha:

  Numeric. Transparency of slope overlay (0-1). Default is 0.5.

- contour_color:

  Character. Color for contour lines. Default is "darkorange4".

- contour_width:

  Numeric. Line width for contours. Default is 0.8.

- label_size:

  Numeric. Size of contour labels. Default is 0.7.

- keyline_color:

  Character. Color for keylines. Default is "blue".

- keyline_width:

  Numeric. Line width for keylines. Default is 1.5.

- main_title:

  Character. Plot title. Default is "Keylines with slope and contours".

- legend:

  Logical. Whether to display a keylines legend. Default is TRUE.

## Value

Invisible list with dtm, slope, hillshade, contours, keylines.
