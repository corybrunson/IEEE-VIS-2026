library(gggda)
library(ordr)

iris_pca <- ordinate(iris, prcomp, cols = 1:4)
sub_rows <- c(42, 110)
sub_cols <- c(1, 3)

# interpolative
sub_data <- iris[sub_rows, seq(5, 1), drop = FALSE]
iris_interp <- ggbiplot(iris_pca) +
  geom_rows_point(aes(color = Species, shape = Species)) +
  geom_cols_axis(aes(label = name), axis.type = "interpolative") +
  geom_cols_interpolation(
    aes(center = center, interpolate = name),
    size = 3, linetype = "dashed", linewidth = 1,
    new_data = sub_data, type = "seq"
  ) +
  scale_color_brewer(palette = "Dark2") +
  coord_square() +
  guides(color = "none", shape = "none") +
  theme_biplot()
ggsave(
  here::here("slideshow/figures/iris-pca-interp.jpg"), iris_interp,
  width = 5, height = 5
)

# predictive
iris_pred <- ggbiplot(iris_pca) +
  geom_rows_point(aes(color = Species, shape = Species)) +
  geom_cols_axis(aes(label = name), axis.type = "predictive") +
  stat_rows_projection(
    subset = sub_rows, ref_subset = sub_cols,
    linetype = "dashed", linewidth = 1
  ) +
  scale_color_brewer(palette = "Dark2") +
  coord_square() +
  guides(color = "none", shape = "none") +
  theme_biplot()
ggsave(
  here::here("slideshow/figures/iris-pca-pred.jpg"), iris_pred,
  width = 5, height = 5
)

iris_rule <- ggbiplot(iris_pca, axis.percents = FALSE) +
  geom_rows_point(aes(color = Species, shape = Species)) +
  stat_cols_rule(
    axis.type = "predictive",
    aes(label = name, center = center)
  ) +
  scale_color_brewer(palette = "Dark2") +
  coord_square() +
  guides(color = "none", shape = "none") +
  theme_scaffold()
ggsave(
  here::here("slideshow/figures/iris-pca-rule.jpg"), iris_rule,
  width = 5, height = 5
)
