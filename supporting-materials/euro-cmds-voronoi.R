library(gggda)
library(ordr)

eurodist %>% 
  cmdscale(k = 6) %>% 
  as.data.frame() %>% 
  tibble::rownames_to_column(var = "city") |> 
  transform(city = forcats::fct_inorder(city)) ->
  euro_mds
pc_pal <- palette.colors(n = nrow(euro_mds), palette = "Polychrome 36")

# planar regions (note superimposed perimeters)
euro_low <- 
  ggplot(euro_mds, aes(V1, V2, label = city)) +
  coord_equal() +
  stat_voronoi(aes(fill = city), color = "black") +
  geom_point(aes(fill = city), size = 2, shape = "circle filled") +
  geom_text(size = 3, hjust = "outward", vjust = "outward") +
  scale_fill_manual(values = pc_pal, guide = "none") +
  theme_scaffold()
ggsave(
  here::here("slideshow/figures/euro-cmds-low.jpg"), euro_low,
  width = 5, height = 5
)

# intersection of plane with full-dimensional regions
euro_high <- 
  ggplot(euro_mds, aes_c(aes_coord(euro_mds, "V"), aes(label = city))) +
  coord_equal() +
  stat_voronoi(aes(fill = city), color = "black") +
  geom_point(aes(V1, V2, fill = city), size = 2, shape = "circle filled") +
  geom_text(aes(V1, V2), size = 3, hjust = "outward", vjust = "outward") +
  scale_fill_manual(values = pc_pal, guide = "none") +
  theme_scaffold()
ggsave(
  here::here("slideshow/figures/euro-cmds-high.jpg"), euro_high,
  width = 5, height = 5
)
