# gugog-shiny.R
# Shiny app reproducing the GUGOG PCA biplot with interactive controls

library(shiny)
library(Lock5withR)   # provides Cereal dataset
library(dplyr)
library(gggda)        # ggbiplot, theme_biplot, etc.
library(ordr)         # ordinate(), confer_inertia()
library(grid)         # for arrow()

# -------------------------------------------------------------------
# 1. Load data and compute base ordination (once)
# -------------------------------------------------------------------

cereal      <- Cereal
tbl_ord_raw <- cereal |> 
  ordinate(cols = Calories:Protein,
           model = ~prcomp(., scale. = TRUE))

# Color palette (same as original script)
pal <- palette.colors(palette = "Okabe-Ito", names = TRUE)

# -------------------------------------------------------------------
# 2. Choose a small set of "distant" cereals for UI checkboxes
# -------------------------------------------------------------------
set.seed(123)  # deterministic selection
raw_scores <- get_rows(tbl_ord_raw) %>% as.data.frame()
colnames(raw_scores) <- paste0("PC", seq_len(ncol(raw_scores)))
scores <- raw_scores %>% select(PC1, PC2)

far_points <- function(df, k) {
  chosen <- integer(0)
  # start with point farthest from origin
  d0 <- sqrt(rowSums(df ^ 2))
  chosen <- which.max(d0)
  while (length(chosen) < k) {
    d <- apply(df, 1, function(pt) {
      min(sqrt(rowSums((t(df[chosen, ]) - pt) ^ 2)))
    })
    chosen <- c(chosen, which.max(d))
  }
  chosen
}

subset_idx   <- far_points(scores, 6)                 # integer row IDs
subset_names <- cereal$Name[subset_idx]               # human‑readable labels

# -------------------------------------------------------------------
# 3. Determine fixed plot limits that cover all inertia balances
# -------------------------------------------------------------------
pc_range <- function(tbl) {
  raw_sc <- as.data.frame(get_rows(tbl))
colnames(raw_sc) <- paste0("PC", seq_len(ncol(raw_sc)))
sc <- raw_sc %>% select(PC1, PC2)
  max_abs <- max(abs(c(sc$PC1, sc$PC2)), 1)   # include unit circle radius = 1
  max_abs
}

tbl_bal0 <- confer_inertia(tbl_ord_raw, c(0, 1))   # all inertia on PC2
tbl_bal1 <- confer_inertia(tbl_ord_raw, c(1, 0))   # all inertia on PC1
M <- max(pc_range(tbl_bal0), pc_range(tbl_bal1)) * 1.05   # 5% margin

# -------------------------------------------------------------------
# 4. UI definition
# -------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("Cereal PCA Biplot (GUGOG)"),
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "balance", "Conference of inertia on rows",
        min = 0, max = 1, value = 0.5, step = 0.01
      ),
      checkboxInput(
        "axis_calib", "Predictive axis calibration", value = TRUE
      ),
      checkboxGroupInput(
        "proj_rows", "Rows to project",
        choices = setNames(subset_idx, subset_names),
        selected = subset_idx[1]
      ),
      checkboxGroupInput(
        "ref_rows", "Reference rows",
        choices = setNames(subset_idx, subset_names),
        selected = subset_idx[2:4]
      )
    ),
    mainPanel(
      plotOutput("biplot", height = "800px")
    )
  )
)

# -------------------------------------------------------------------
# 5. Server logic
# -------------------------------------------------------------------
server <- function(input, output, session) {

  # Reactive balanced ordination (uses confer_inertia)
  balanced_tbl <- reactive({
    if (axis_type() == "interpolative") {
      # Standard coordinates required for interpolation
      confer_inertia(tbl_ord_raw, p = "rows")
    } else {
      p <- input$balance
      confer_inertia(tbl_ord_raw, c(p, 1 - p))
    }
  })

  # Axis type string based on toggle
  axis_type <- reactive({
    if (input$axis_calib) "predictive" else "interpolative"
  })

  # Whether to apply the original theme (predictive only)
  use_theme <- reactive({ input$axis_calib })

  output$biplot <- renderPlot({
    tt <- balanced_tbl()
    # fortify the tbl_ord for ggplot compatibility
    tt_fort <- fortify(tt)
    print(tt_fort)
    p <- ggbiplot(tt_fort, aes(x = PC1, y = PC2)) +
      geom_rows_point(size = 1.5, color = pal[["blue"]]) +
      geom_rows_text_repel(aes(label = Name), size = 3,
                           color = pal[["blue"]]) +
      geom_cols_axis(
        aes(label = name, center = center, scale = scale),
        axis.type = axis_type(),
        size = 4,
        tick_length = .01, text_dodge = .012,
        label_dodge = .02, num = 10
      ) +
      geom_unit_circle(color = pal[["vermillion"]]) +
      geom_cols_vector(
        arrow = grid::arrow(length = unit(.01, "native"), type = "closed"),
        linewidth = .75, color = pal[["vermillion"]],
        vector_labels = FALSE
      ) +
        if (axis_type() == "predictive") {
          stat_rows_projection(
            subset = as.integer(input$proj_rows),
            ref_subset = as.integer(input$ref_rows),
            color = pal[["bluishgreen"]],
            linetype = "dashed", linewidth = .75
          )
        } else {
          # Interpolation layer for interpolative axis calibration
          interp_data <- Cereal[as.integer(input$proj_rows), c("Calories", "Fat", "Sodium", "Carbs", "Fiber", "Sugars", "Protein")]
geom_cols_interpolation(
              aes(center = center, scale = scale, interpolate = name),
              new_data = interp_data,
              type = "centroid",
              color = pal[["bluishgreen"]],
              linetype = "dashed",
              linewidth = .75
            )
        } +
      coord_fixed(xlim = c(-M, M), ylim = c(-M, M))

    if (use_theme()) {
      p <- p + theme_biplot()
    }
    print(p)
  })
}

# -------------------------------------------------------------------
# 6. Launch the app
# -------------------------------------------------------------------
shinyApp(ui, server)
