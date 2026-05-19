# Plot dtm with Hillshade and Contours

Creates a visualization of a Digital Elevation Model (dtm) with
hillshade, contour lines, and labels. This function uses pre-calculated
geomorphology metrics from `calc_geomorphology_metrics()`.

## Usage

``` r
plot_dtm_contours(
  dtm,
  metrics,
  contour_interval = 10,
  hillshade_angle = 45,
  hillshade_direction = 270,
  contour_color = "darkorange4",
  contour_width = 1,
  label_size = 0.8,
  dtm_alpha = 0.6,
  main_title = "Dtm with contours"
)
```

## Arguments

- dtm:

  SpatRaster. dtm raster object from the terra package.

- metrics:

  Optional. A list object returned from `calc_geomorphology_metrics()`.
  If NULL, the function will calculate metrics internally. Default is
  NULL.

- contour_interval:

  Numeric. Elevation interval between contour lines. Default is 10.

- hillshade_angle:

  Numeric. Sun angle for hillshade calculation. Default is 45.

- hillshade_direction:

  Numeric. Sun direction for hillshade. Default is 270.

- contour_color:

  Character. Color for contour lines. Default is "darkorange4".

- contour_width:

  Numeric. Line width for contours. Default is 1.

- label_size:

  Numeric. Size of contour labels. Default is 0.8.

- dtm_alpha:

  Numeric. Transparency of dtm overlay (0-1). Default is 0.6.

- main_title:

  Character. Plot title. Default is "dtm with contours and hillshade".

## Value

A plot displaying the dtm with hillshade and contours. Invisibly returns
a list containing:

- `dtm`: Original dtm as SpatRaster

- `hillshade`: Hillshade as SpatRaster

- `contours`: Contour lines as SpatVector

- `slope`: Slope in degrees as SpatRaster

- `aspect`: Aspect in radians as SpatRaster

## Examples

``` r
if (FALSE) { # \dontrun{
dtm <- rast("path/to/dtm.tif")

# Calculate metrics once
metrics <- calc_geomorph_metrics(dtm)

# Use metrics for plotting
plot_dtm_contours(dtm, metrics = metrics)
plot_dtm_contours(dtm, metrics = metrics, contour_interval = 20)

# Multiple plots from same metrics (efficient!)
plot_dtm_contours(dtm, metrics = metrics, contour_color = "blue")
plot_dtm_contours(dtm, metrics = metrics, dtm_alpha = 0.8)
} # }
```
