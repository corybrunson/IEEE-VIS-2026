library(tidyverse)
library(broom)
library(gggda)
library(ordr)
library(expm)

sepal_plot <- ggplot(iris) +
  geom_point(aes(Sepal.Length, Sepal.Width, color = Species)) +
  coord_fixed()
sepal_plot

cols_inner_prod <- function(cols, rot = diag(rep(1, 4))) {
  mat <- (as.matrix(cols[, 1:4]) %*% t(rot))[, 1:2]
  diag(mat %*% t(mat))
}

iris_pca <- ordinate(iris, prcomp, cols = 1:4)

pca_rot <- iris_pca$rotation

pca_rows <- fortify(iris_pca) |> filter(.matrix == "rows")
pca_cols <- fortify(iris_pca) |> filter(.matrix == "cols")

pca_cols <- mutate(pca_cols, inner = cols_inner_prod(pca_cols))

biplot <- ggplot() +
  geom_point(data = pca_rows, aes(PC1, PC2, color = Species)) +
  geom_axis(
    data = pca_cols,
    mapping = aes(PC1, PC2, label = name, center = center, alpha = inner),
    axis.type = "predictive"
  ) +
  scale_alpha_continuous(range = c(0, 1)) +
  coord_square() + theme_biplot()
biplot

rot_rows <- select(pca_rows, starts_with("PC")) |> 
  as.matrix() |> 
  ( \(x) x %*% t(pca_rot) )() |> 
  as_tibble() |> 
  bind_cols(select(pca_rows, -starts_with("PC")))
rot_cols <- select(pca_cols, starts_with("PC")) |> 
  as.matrix() |> 
  ( \(x) x %*% t(pca_rot) )() |> 
  as_tibble() |> 
  bind_cols(select(pca_cols, -starts_with("PC")))

rot_cols <- mutate(rot_cols, inner = cols_inner_prod(rot_cols))

rot_biplot <- ggplot() +
  geom_point(data = rot_rows, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_axis(
    data = rot_cols,
    mapping = aes(
      Sepal.Length, Sepal.Width,
      label = name, center = center, alpha = inner
    ),
    axis.type = "predictive"
  ) +
  scale_alpha_continuous(range = c(0, 1)) +
  coord_square() + theme_biplot()
rot_biplot

path_rot <- function(t) {
  stopifnot(is.numeric(t), length(t) == 1, t >= 0, t <= 1)
  expm::expm(t * expm::logm(pca_rot))
}

make_path_biplot <- function(t) {
  m <- path_rot(t)
  path_rows <- select(pca_rows, starts_with("PC")) |> 
    as.matrix() |> 
    ( \(x) x %*% t(m) )() |> 
    as_tibble() |> set_names(str_c("R", 1:4)) |> 
    bind_cols(select(pca_rows, -starts_with("PC")))
  path_cols <- select(pca_cols, starts_with("PC")) |> 
    as.matrix() |> 
    ( \(x) x %*% t(m) )() |> 
    as_tibble() |> set_names(str_c("R", 1:4)) |> 
    bind_cols(select(pca_cols, -starts_with("PC")))
  path_cols <- mutate(path_cols, inner = cols_inner_prod(path_cols))
  ggplot() +
    geom_point(
      data = path_rows,
      mapping = aes(R1, R2, color = Species)
    ) +
    geom_axis(
      data = path_cols,
      mapping = aes(R1, R2, label = name, center = center, alpha = inner),
      axis.type = "predictive"
    ) +
    scale_alpha_continuous(range = c(0, 1)) +
    coord_square() + theme_biplot()
}
path_biplots <- lapply(seq(0, 1, by = 0.2), make_path_biplot)
lapply(path_biplots, plot)

frame_dir <- tempfile("pca_biplot_frames")
dir.create(frame_dir)
ts <- seq(0, 1, length.out = 60)
ts <- c(ts, rep(1, 24), rev(ts), rep(0, 24))
frame_files <- character(length(ts))
for (i in seq_along(ts)) {
  frame_files[i] <- file.path(frame_dir, sprintf("frame_%03d.png", i))
  ggsave(
    frame_files[i], make_path_biplot(ts[i]),
    width = 6, height = 6, dpi = 150
  )
}
gif_file <- file.path(getwd(), "iris-pca-path.gif")
anim <- magick::image_read(frame_files) |>
  magick::image_animate(fps = 10)
magick::image_write(anim, gif_file, format = "gif")
cat("GIF written to:", gif_file, "\n")
