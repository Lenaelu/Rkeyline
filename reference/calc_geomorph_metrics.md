# Calculate Geomorphology Metrics from dtm

This function calculates various geometric and hydrological metrics from
a Digital Elevation Model (dtm). It computes terrain attributes,
performs hydrological processing (including inverted processing for
ridge extraction), and returns all metrics in a structured list.

## Usage

``` r
calc_geomorph_metrics(
  dtm,
  output_folder = tempdir(),
  contour_interval = 10,
  stream_threshold = 1000,
  breach_dist = 50,
  hillshade_angle = 45,
  hillshade_direction = 270
)
```

## Arguments

- dtm:

  A SpatRaster object imported with
  [`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html).
  Must be a valid digital elevation model.

- output_folder:

  Character string specifying the directory path for temporary whitebox
  processing files. Defaults to a temporary directory.

- contour_interval:

  Numeric value for contour line spacing in elevation units. Default is
  10.

- stream_threshold:

  Numeric value for stream and ridge extraction threshold (number of
  cells). Default is 1000. Adjust based on your study area size.

- breach_dist:

  Maximum breach distance for depression filling in cells. Default is
  50.

- hillshade_angle:

  Sun angle for hillshade calculation in degrees. Default is 45.

- hillshade_direction:

  Sun direction for hillshade calculation in degrees. Default is 270
  (from west).

## Value

A list containing the following geometric metrics:

- contours:

  sf object with contour lines

- slope:

  SpatRaster of slope in degrees

- aspect:

  SpatRaster of aspect in radians

- hillshade:

  SpatRaster of hillshade

- dtm_filled:

  SpatRaster of depression-filled dtm

- flow_pointer:

  SpatRaster of D8 flow pointers

- flow_acc:

  SpatRaster of flow accumulation

- flow_acc_log:

  SpatRaster of log-transformed flow accumulation

- streams:

  SpatRaster of extracted stream network

- dtm_inverted:

  SpatRaster of inverted dtm (for ridge analysis)

- dtm_filled_inverted:

  SpatRaster of depression-filled inverted dtm

- flow_pointer_inverted:

  SpatRaster of D8 flow pointers for inverted dtm

- flow_acc_inverted:

  SpatRaster of flow accumulation for inverted dtm

- streams_inverted:

  SpatRaster of extracted streams_inverted

- output_folder:

  Character string of the output folder path used

## Details

The function performs the following calculations in order:

1.  Basic terrain attributes (contours, slope, aspect, hillshade)

2.  Depression filling using least-cost breaching

3.  D8 flow pointer calculation

4.  Flow accumulation

5.  Log-transformed flow accumulation

6.  Stream network extraction

7.  Inverted dtm creation (dtm \* -1)

8.  Inverted hydrological processing (for ridge extraction)

9.  Ridge network extraction

The inverted hydrological processing creates a "reversed" topography
where valleys become ridges and vice versa. This allows for the
extraction of ridge networks using the same flow accumulation algorithms
used for streams.

## Note

Requires the `terra`, `whitebox`, and `sf` packages. Make sure whitebox
tools are properly installed with
[`whitebox::install_whitebox()`](https://rdrr.io/pkg/whitebox/man/install_whitebox.html).

## Examples

``` r
if (FALSE) { # \dontrun{

# Load your dtm
dtm <- rast("path/to/your/dtm.tif")

# Calculate all metrics with defaults
metrics <- calc_geomorphology_metrics(dtm)

# Access individual metrics
plot(metrics$slope)
plot(metrics$hillshade)
plot(metrics$streams)
plot(metrics$streams_inverted)

# Custom parameters
metrics <- calc_geomorphology_metrics(
  dtm = dtm,
  output_folder = "C:/my_project/temp",
  contour_interval = 20,
  stream_threshold = 500
)
} # }
```
