# Plot dtm with Main Valleys and Ridges

Creates a visualization of a Digital Elevation Model (dtm) with
hillshade, main valley lines, and main ridge lines. This function uses
pre-calculated geomorphology metrics and pre-extracted networks.

## Usage

``` r
plot_main_networks(
  dtm,
  main_valleys,
  main_ridges,
  metrics,
  valley_color = "lightblue",
  ridge_color = "darkorange",
  valley_width = 2,
  ridge_width = 2,
  show_contours = TRUE,
  contour_color = "gray30",
  contour_width = 0.5,
  dtm_alpha = 0.6,
  show_labels = FALSE,
  label_size = 0.8,
  main_title = "Main valleys and ridges",
  legend = TRUE
)
```

## Arguments

- dtm:

  SpatRaster. dtm raster object from the terra package.

- main_valleys:

  sf object. Main valley lines from
  [`extract_main_valleys()`](https://lenaelu.github.io/Rkeyline/reference/extract_main_valleys.md).
  This parameter is REQUIRED.

- main_ridges:

  sf object. Main ridge lines from
  [`extract_main_ridges()`](https://lenaelu.github.io/Rkeyline/reference/extract_main_ridges.md).
  This parameter is REQUIRED.

- metrics:

  List. A list object returned from
  [`calc_geomorph_metrics()`](https://lenaelu.github.io/Rkeyline/reference/calc_geomorph_metrics.md).
  This parameter is REQUIRED. Must contain hillshade.

- valley_color:

  Character. Color for valley lines. Default is "lightblue".

- ridge_color:

  Character. Color for ridge lines. Default is "darkorange".

- valley_width:

  Numeric. Line width for valleys. Default is 2.

- ridge_width:

  Numeric. Line width for ridges. Default is 2.

- show_contours:

  Logical. Should contour lines be shown? Default is TRUE.

- contour_color:

  Character. Color for contour lines. Default is "gray30".

- contour_width:

  Numeric. Line width for contours. Default is 0.5.

- dtm_alpha:

  Numeric. Transparency of dtm overlay (0-1). Default is 0.6.

- show_labels:

  Logical. Should RANK labels be shown? Default is FALSE.

- label_size:

  Numeric. Size of RANK labels. Default is 0.8.

- main_title:

  Character. Plot title. Default is "Main Valleys and Ridges".

- legend:

  Logical. Should legend be shown? Default is TRUE.

## Value

A plot displaying the dtm with hillshade, main valleys, and main ridges.
Invisibly returns a list containing:

- `dtm`: Original dtm as SpatRaster

- `hillshade`: Hillshade as SpatRaster

- `main_valleys`: Main valley lines as sf object

- `main_ridges`: Main ridge lines as sf object

## Details

This function requires pre-calculated inputs:

1.  Metrics from `calc_geomorph_metrics(dtm)`

2.  Valley network from
    `extract_networks(dtm, type = "valley", metrics = metrics)`

3.  Ridge network from
    `extract_networks(dtm, type = "ridge", metrics = metrics)`

4.  Main valleys from
    `extract_main_valleys(valleys, dtm, nr_main, metrics)`

5.  Main ridges from
    `extract_main_ridges(ridges, dtm, nr_main, metrics)`

## Examples

``` r
if (FALSE) { # \dontrun{
dtm <- rast("path/to/dtm.tif")

# Step 1: Calculate metrics
metrics <- calc_geomorph_metrics(dtm)

# Step 2: Extract networks
valleys <- extract_networks(dtm, type = "valley", metrics = metrics)
ridges <- extract_networks(dtm, type = "ridge", metrics = metrics)

# Step 3: Extract main networks
main_valleys <- extract_main_valleys(valleys, dtm, nr_main = 2, metrics = metrics)
main_ridges <- extract_main_ridges(ridges, dtm, nr_main = 2, metrics = metrics)

# Step 4: Plot
plot_main_networks(
  dtm = dtm,
  main_valleys = main_valleys,
  main_ridges = main_ridges,
  metrics = metrics
)

# Custom colors
plot_main_networks(
  dtm = dtm,
  main_valleys = main_valleys,
  main_ridges = main_ridges,
  metrics = metrics,
  valley_color = "blue",
  ridge_color = "brown"
)
} # }
```
