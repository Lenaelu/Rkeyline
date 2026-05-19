# Calculate Approximate Keylines from Valley or Ridge Networks

Generates approximate keylines by sampling elevation values along main
valley or ridge lines and matching them to the nearest pre-computed
contour lines.

**Important:** These keylines are a computational approximation only and
should be treated as an orientation for field work. Keylines must always
be verified, refined, and adjusted on-site by an experienced
practitioner.

## Usage

``` r
create_keylines(dtm, lines, contours, n_keylines = 3)
```

## Arguments

- dtm:

  A `SpatRaster` object (terra). The digital elevation model.

- lines:

  A `sf` or `SpatVector` object. Either the main valley lines from
  [`extract_main_valleys()`](https://lenaelu.github.io/Rkeyline/reference/extract_main_valleys.md)
  or the main ridge lines from
  [`extract_main_ridges()`](https://lenaelu.github.io/Rkeyline/reference/extract_main_ridges.md).

- contours:

  A `sf` or `SpatVector` object. Pre-computed contour lines with an
  elevation column named `level`, typically from
  [`calc_geomorph_metrics()`](https://lenaelu.github.io/Rkeyline/reference/calc_geomorph_metrics.md).

- n_keylines:

  Integer. The desired number of keylines per valley or ridge. Default
  is 3. Note that the actual number returned may be lower if the input
  line does not span enough elevation range to support the requested
  number.

## Value

A `sf` object containing the approximate keylines with the following
columns:

- level:

  Elevation of the keyline in map units (usually metres).

- line_id:

  Integer ID identifying which valley or ridge the keyline belongs to.

- note:

  A reminder that these lines are approximations requiring field
  validation.

## Note

Keyline design is a landscape design methodology developed by P.A.
Yeomans. The placement of keylines in the field requires expert judgment
and cannot be fully automated. This function provides a spatial
approximation to support planning and desktop analysis only.

## See also

[`calc_geomorph_metrics()`](https://lenaelu.github.io/Rkeyline/reference/calc_geomorph_metrics.md),
[`extract_main_valleys()`](https://lenaelu.github.io/Rkeyline/reference/extract_main_valleys.md),
[`extract_main_ridges()`](https://lenaelu.github.io/Rkeyline/reference/extract_main_ridges.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# From valley lines
valley_keylines <- create_keylines(dtm, main_valleys, contours, n_keylines = 3)

# From ridge lines
ridge_keylines <- create_keylines(dtm, main_ridges, contours, n_keylines = 3)
} # }
```
