# Figure(s) for GUGOG submission and/or slideshow, 2026 Nov 9

# inches * scale factor
sf <- 1
col_width <- 3.333 * sf
text_width <- 7 * sf

# pak::pkg_install("Lock5withR@1.2.2")
library(Lock5withR)
library(dplyr)
library(ordr)
library(gggda)

pal <- palette.colors(palette = "Okabe-Ito", names = TRUE)

Cereal |> 
  mutate(across(Calories:Protein, ~ .x / Serving)) |> 
  ordinate(cols = Calories:Protein, model = ~ prcomp(., scale. = TRUE)) |> 
  print() -> cereal_ord

slice(Cereal, 23)

pca_biplot <- ggbiplot(cereal_ord) +
  geom_rows_point(size = 1.5, color = pal[["blue"]]) +
  geom_rows_text_repel(aes(label = Name), size = 3, color = pal[["blue"]]) +
  geom_unit_circle(color = pal[["vermillion"]]) +
  geom_cols_axis(
    aes(label = name, center = center, scale = scale), size = 4,
    tick_length = .01, text_dodge = .012, label_dodge = .02, num = 10
  ) +
  geom_cols_vector(
    arrow = grid::arrow(length = unit(.01, "native"), type = "closed"),
    linewidth = .75, color = pal[["vermillion"]], vector_labels = FALSE
  ) +
  stat_rows_projection(
    subset = 23, ref_subset = c(2, 4, 6),
    color = pal[["bluishgreen"]], linetype = "dashed", linewidth = .75
  ) +
  coord_rect() +
  theme_biplot()
print(pca_biplot)

ggsave(
  here::here("gugog-figure-cereal.pdf"), pca_biplot,
  width = text_width, height = text_width, units = "in"
)
