#' Interactive Flow Accumulation Comparison
#'
#' Creates an interactive Shiny app to compare flow accumulation with its log-transformed version.
#' Allows toggling layers on/off and adjusting opacity for better visual comparison.
#' This function requires pre-calculated geomorphology metrics from \code{calc_geomorph_metrics()}.
#'
#' @param dtm A SpatRaster object (from terra package) representing the Digital Elevation Model
#' @param metrics A list object returned from \code{calc_geomorph_metrics()}.
#'   This parameter is required.
#'
#' @return Launches a Shiny app for interactive visualization. No return value.
#'
#' @import shiny
#' @import terra
#' @import viridis
#'
#' @examples
#' \dontrun{
#' dtm <- rast("path/to/your/dtm.tif")
#'
#' # Calculate metrics first
#' metrics <- calc_geomorph_metrics(dtm)
#'
#' # Launch interactive comparison
#' plot_flow_acc(dtm, metrics = metrics)
#' }
#'
#' @export
plot_flow_acc <- function(dtm, metrics) {

  # Check if dtm is a SpatRaster
  if (!inherits(dtm, "SpatRaster")) {
    stop("dtm must be a SpatRaster object from the terra package")
  }

  # Validate metrics object
  if (!is.list(metrics)) {
    stop("'metrics' must be a list object from calc_geomorph_metrics(). Please run calc_geomorph_metrics() first.")
  }

  required_elements <- c("flow_acc", "flow_acc_log")
  if (!all(required_elements %in% names(metrics))) {
    stop("'metrics' must contain: ", paste(required_elements, collapse = ", "),
         "\nPlease ensure you're using the output from calc_geomorph_metrics()")
  }

  # Extract flow accumulation metrics
  flow_acc <- metrics$flow_acc
  flow_acc_log <- metrics$flow_acc_log

  message("Launching interactive flow accumulation viewer...")

  # Create Shiny app
  ui <- shiny::fluidPage(
    shiny::titlePanel("Flow Accumulation Comparison"),

    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::checkboxInput("show_regular", "Show Flow Accumulation", value = TRUE),
        shiny::checkboxInput("show_log", "Show Flow Accumulation (Log)", value = TRUE),
        shiny::sliderInput("alpha_regular", "Flow Accumulation Opacity:",
                           min = 0, max = 1, value = 0.7, step = 0.1),
        shiny::sliderInput("alpha_log", "Log Opacity:",
                           min = 0, max = 1, value = 0.5, step = 0.1),
        width = 3
      ),

      shiny::mainPanel(
        shiny::plotOutput("comparison_plot", height = "600px"),
        width = 9
      )
    )
  )

  server <- function(input, output) {
    output$comparison_plot <- shiny::renderPlot({
      par(mar = c(4, 4, 3, 8))

      # Determine which layer to plot first (base layer)
      if (input$show_regular || input$show_log) {
        if (input$show_regular) {
          # Plot Flow Accumulation as base
          plot(flow_acc, col = viridis::viridis(100, alpha = input$alpha_regular),
               legend = TRUE, main = "Flow Accumulation Comparison", las = 1)

          # Add log layer on top if also enabled
          if (input$show_log) {
            plot(flow_acc_log, col = viridis::magma(100, alpha = input$alpha_log),
                 legend = FALSE, add = TRUE)
          }
        } else {
          # Only log layer is shown
          plot(flow_acc_log, col = viridis::magma(100, alpha = input$alpha_log),
               legend = TRUE, main = "Flow Accumulation Comparison", las = 1)
        }
      } else {
        # If neither is shown, plot empty
        plot(flow_acc, col = "transparent", legend = FALSE,
             main = "Flow Accumulation Comparison", las = 1)
      }

      # Add custom legend only if at least one layer is shown
      legend_labels <- c()
      legend_colors <- c()

      if (input$show_regular) {
        legend_labels <- c(legend_labels, "Flow Accumulation (bottom)")
        legend_colors <- c(legend_colors, viridis::viridis(1))
      }

      if (input$show_log) {
        legend_labels <- c(legend_labels, "Flow Acc Log (top)")
        legend_colors <- c(legend_colors, viridis::magma(1))
      }

      if (length(legend_labels) > 0) {
        legend("topright",
               legend = legend_labels,
               fill = legend_colors,
               bg = "white",
               cex = 0.9)
      }
    })
  }

  # Run the app
  shiny::shinyApp(ui = ui, server = server)
}
