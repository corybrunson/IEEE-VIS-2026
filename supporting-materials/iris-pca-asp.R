library(gggda)
library(ordr)
library(patchwork)

iris_pca <- ordinate(iris, prcomp, cols = 1:4)

# free aspect ratio
iris_free <- ggbiplot(iris_pca, sec.axes = "cols", scale.factor = 2) +
  geom_rows_point(aes(color = Species, shape = Species)) +
  geom_cols_vector(aes(label = name)) +
  scale_color_brewer(palette = "Dark2") +
  coord_cartesian() +
  guides(color = "none", shape = "none") +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )
ggsave(
  here::here("slideshow/figures/iris-pca-free.jpg"), iris_free,
  width = 5, height = 3.75
)

# fixed aspect ratio
iris_fixed <- ggbiplot(iris_pca, sec.axes = "cols", scale.factor = 2) +
  geom_rows_point(aes(color = Species, shape = Species)) +
  geom_cols_vector(aes(label = name)) +
  scale_color_brewer(palette = "Dark2") +
  coord_equal() +
  guides(color = "none", shape = "none") +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )
ggsave(
  here::here("slideshow/figures/iris-pca-fixed.jpg"), iris_fixed,
  width = 5, height = 2.667
)

# fixed window aspect ratio
iris_square <- ggbiplot(iris_pca, sec.axes = "cols", scale.factor = 2) +
  geom_rows_point(aes(color = Species, shape = Species)) +
  geom_cols_vector(aes(label = name)) +
  scale_color_brewer(palette = "Dark2") +
  coord_square() +
  guides(
    color = guide_legend(title = NULL),
    shape = guide_legend(title = NULL)
  ) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )
ggsave(
  here::here("slideshow/figures/iris-pca-square.jpg"), iris_square,
  width = 5, height = 5
)

iris_patch <- iris_free + iris_fixed + iris_square
ggsave(
  here::here("slideshow/figures/iris-pca-asp.jpg"), iris_patch,
  width = 12, height = 4
)
