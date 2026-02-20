# Rkeyline

**Rkeyline** is an R package for terrain and keyline analysis from Digital Elevation Models (DTMs). It provides a complete workflow from raw DTM data to approximate keyline design, covering geomorphological analysis, valley and ridge network extraction, and visualization.

> ⚠️ Generated keylines are computational approximations for desktop planning only. Always verify and adjust keylines on-site with an experienced practitioner before implementation.

---

## Installation

```r
# install.packages("remotes")
remotes::install_github("Lenaelu/Rkeyline")
```

### Dependencies

Make sure you have the following packages installed:

```r
install.packages(c("terra", "sf", "dplyr", "smoothr", "shiny", "viridis"))
```

Rkeyline also requires **WhiteboxTools**:

```r
install.packages("whitebox")
whitebox::install_whitebox()
```

---

## Workflow Overview

The package follows a clear step-by-step workflow:

```
DTM → calc_geomorph_metrics()
         ↓
      extract_networks()        (valleys & ridges)
         ↓
      extract_main_valleys()
      extract_main_ridges()
         ↓
      create_keylines()
         ↓
      plot_*() functions
```

---

## Usage

### Step 1: Load your DTM

```r
library(terra)
library(Rkeyline)

dtm <- rast("path/to/your/dtm.tif")
```

### Step 2: Calculate geomorphology metrics

This is the foundation of the entire workflow. Run it once and reuse the results.

```r
metrics <- calc_geomorph_metrics(dtm)
```

Returns slope, aspect, hillshade, contours, flow accumulation, stream networks, and their inverted equivalents for ridge analysis.

Key parameters:
- `contour_interval` — elevation spacing for contours (default: 10)
- `stream_threshold` — number of cells required to form a stream (default: 1000)
- `breach_dist` — maximum breach distance for depression filling (default: 50)

### Step 3: Extract valley and ridge networks

```r
valleys <- extract_networks(dtm, type = "valley", metrics = metrics)
ridges  <- extract_networks(dtm, type = "ridge",  metrics = metrics)
```

Or use the wrapper functions:

```r
valleys <- extract_valleys(dtm, metrics = metrics)
ridges  <- extract_ridges(dtm, metrics = metrics)
```

### Step 4: Extract main valleys and ridges

Select the top N valley and ridge lines ranked by flow accumulation.

```r
main_valleys <- extract_main_valleys(valleys, dtm, nr_main = 2, metrics = metrics)
main_ridges  <- extract_main_ridges(ridges,  dtm, nr_main = 2, metrics = metrics)
```

### Step 5: Generate approximate keylines

```r
valley_keylines <- create_keylines(dtm, main_valleys, metrics$contours, n_keylines = 3)
ridge_keylines  <- create_keylines(dtm, main_ridges,  metrics$contours, n_keylines = 3)
```

---

## Visualization

All plot functions accept pre-calculated metrics for efficiency.

```r
# DTM with hillshade and contours
plot_dtm_contours(dtm, metrics = metrics)

# Slope with contours and stream network
plot_slope_channels(dtm, metrics = metrics)

# Main valleys and ridges
plot_main_networks(dtm,
                   main_valleys = main_valleys,
                   main_ridges  = main_ridges,
                   metrics      = metrics)

# Keylines with slope and contours
plot_keylines(dtm, metrics = metrics, keylines = valley_keylines)

# Interactive flow accumulation comparison (Shiny)
plot_flow_acc(dtm, metrics = metrics)
```

---

## Function Reference

| Function | Description |
|---|---|
| `calc_geomorph_metrics()` | Calculate all terrain and hydrological metrics from a DTM |
| `extract_networks()` | Extract valley or ridge networks |
| `extract_valleys()` | Wrapper for valley network extraction |
| `extract_ridges()` | Wrapper for ridge network extraction |
| `extract_main_valleys()` | Identify main valley lines by flow accumulation |
| `extract_main_ridges()` | Identify main ridge lines by flow accumulation |
| `create_keylines()` | Generate approximate keylines from valley or ridge lines |
| `plot_dtm_contours()` | Plot DTM with hillshade and contours |
| `plot_slope_channels()` | Plot slope with contours and stream network |
| `plot_main_networks()` | Plot DTM with main valley and ridge lines |
| `plot_keylines()` | Plot keylines with slope and contours |
| `plot_flow_acc()` | Interactive Shiny app for flow accumulation comparison |

---

## About Keyline Design

Keyline design is a land and water management methodology developed by P.A. Yeomans. It uses the natural topography of a landscape — particularly valley and ridge lines — to guide water flow and distribution across a property. This package provides computational tools to support the desktop planning phase of keyline analysis.

---

## License

MIT

## Acknowledgements

The algorithms in this package are based on the 
[TopoDArain plugin](https://github.com/wickit7/topo-drain-plugin), which provided 
the methodological foundation for the terrain analysis.
