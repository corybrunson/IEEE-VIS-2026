# Generates two looping GIFs of the GUGOG biplot:
#   * predictive‑axis version (uses biplot partial theme)
#   * interpolative‑axis version (no special theme)
# Each GIF animates inertia balance: row-principal → column-principal → back,
# omitting the duplicate start frame so the loop is seamless.

# ---- Libraries -----------------------------------------------------------
library(Lock5withR)      # provides Cereal dataset
library(dplyr)
library(gggda)           # ggbiplot, theme_biplot, etc.
library(ordr)            # ordinate(), confer_inertia()
library(grid)            # for arrow()
library(magick)          # for GIF assembly
library(here)            # path handling

# ---- Palette -------------------------------------------------------------
pal <- palette.colors(palette = "Okabe-Ito", names = TRUE)


# ---- User‑adjustable controls --------------------------------------------
# Minimum distance of markers from the origin for printing text labels
min_dist <- 0.8
# Row(s) to label/plot as points (default: all rows are shown)
proj_subset <- 23                     # single row to project
ref_subset   <- c(2, 4, 6)            # reference rows for projection lines

# ---- Base ordination -----------------------------------------------------
cereal_ord_raw <- Cereal |>
  ordinate(cols = Calories:Protein, model = ~prcomp(., scale. = TRUE))

# ---- Fixed plot limits covering both extremes ----------------------------
pc_range <- function(tbl) {
  raw_sc <- as.data.frame(get_rows(tbl))
  colnames(raw_sc) <- paste0("PC", seq_len(ncol(raw_sc)))
  sc <- raw_sc %>% select(PC1, PC2)
  max(abs(c(sc$PC1, sc$PC2)), 1)   # include unit circle radius = 1
}

tbl_bal0 <- confer_inertia(cereal_ord_raw, c(0, 1))   # all inertia on PC2
tbl_bal1 <- confer_inertia(cereal_ord_raw, c(1, 0))   # all inertia on PC1
M <- max(pc_range(tbl_bal0), pc_range(tbl_bal1)) * 1.05   # 5% margin

# ---- Helper to build a single plot --------------------------------------
make_gugog_plot <- function(balance, axis_type = "predictive") {
  bal_tbl <- confer_inertia(cereal_ord_raw, c(balance, 1 - balance))
  tt_fort <- fortify(bal_tbl)

  # Filter rows for labels far from origin
  label_df <- tt_fort[ sqrt(tt_fort$PC1^2 + tt_fort$PC2^2) >= min_dist , ]
  p <- ggbiplot(tt_fort, aes(x = PC1, y = PC2)) +
    geom_rows_point(size = 1.5, color = pal[["blue"]]) +
    geom_rows_text(
      data = label_df, aes(label = Name),
      size = 3, color = pal[["blue"]]
    ) +
    geom_cols_axis(
      aes(label = name, center = center, scale = scale),
      axis.type = axis_type,
      size = 4, tick_length = .01, text_dodge = .012,
      label_dodge = .02, num = 10
    ) +
    geom_unit_circle(color = pal[["vermillion"]]) +
    geom_cols_vector(
      arrow = grid::arrow(length = unit(.01, "native"), type = "closed"),
      linewidth = .75, color = pal[["vermillion"]], vector_labels = FALSE
    ) +
    stat_rows_projection(
      subset = proj_subset, ref_subset = ref_subset,
      color = pal[["bluishgreen"]], linetype = "dashed", linewidth = .75
    ) +
    coord_fixed(xlim = c(-M, M), ylim = c(-M, M))

  if (axis_type == "predictive") {
    p <- p + theme_biplot()
  }
  p
}

# ---- Balance sequence for smooth looping ---------------------------------
forward  <- seq(0, 1, by = 0.02)   # full‑row → full‑column (51 frames)
len <- length(forward)
balances <- c(forward[-len], rev(forward)[-len])  # total 100 frames

# ---- Output dimensions (same as static figure) --------------------------
# inches * scale factor (copied from gugog-figure.r)
sf <- 1
text_width <- 7 * sf

# ---- Function to render frames and build GIF -----------------------------
render_gif <- function(axis_type) {
  out_dir <- file.path("supporting-materials", "gif_frames", axis_type)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  for (i in seq_along(balances)) {
    p <- make_gugog_plot(balances[i], axis_type)
    fn <- sprintf("%05d.png", i)
    ggsave(file.path(out_dir, fn), p,
           width = text_width, height = text_width,
           units = "in", dpi = 150)
  }

  # Assemble GIF
  frames <- list.files(out_dir, pattern = "\\.png$", full.names = TRUE)
  imgs <- image_read(frames)
  gif <- image_animate(imgs, fps = 10)  # adjust speed if needed
  gif_path <- file.path(
    "supporting-materials",
    paste0("gugog-figure-", axis_type, ".gif")
  )
  image_write(gif, path = gif_path)

  # Clean up PNG frames
  unlink(out_dir, recursive = TRUE)
  message("Created ", gif_path)
}

# ---- Generate both GIFs ---------------------------------------------------
render_gif("predictive")
render_gif("interpolative")
