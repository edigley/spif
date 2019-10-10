graph_tsp_overview <- function(ds, subtitle, platform) { 

    ggplot(
        title = "Runtime"
    ) + 
    theme(
        plot.title = element_text(hjust = 0.5)
    ) + 
    labs(
        title = "Effect of Vitamin C on Tooth Growth",
        subtitle = subtitle,
        caption = platform,
        color = "Runtime (hours)"
    ) + 
    geom_rect(
        data=ds,
        aes(xmin=start/3600, xmax=end/3600, ymin=Worker, ymax=Worker+0.3, color=(end-start)/3600),
        size=1
    ) +
    scale_color_gradient(
        low="green", 
        high="red"
    ) + 
    scale_y_reverse(
    ) + 
    geom_hline(
        yintercept = c(0.7, 8.7, 16.7, 24.7, 32.7, 40.7, 48.7, 56.7, 64.7),
        color='gray', 
        size=0.3
    ) + 
    theme(
        legend.position = "bottom",#c(0.7, 0.2),
        legend.direction = "horizontal",
        legend.title = element_blank(), #element_text(face = "italic"),
        plot.title = element_text(hjust = 0.5, size = 14),    # Center title position and size
        plot.subtitle = element_text(hjust = 0.5),            # Center subtitle
        plot.caption = element_text(hjust = 1, face = "italic", color = "gray", size = 6)
    ) + 
    ggtitle(
        "La Jonquera Single-Core Scenario"
    ) +
    xlab(
        "Time (hours)"
    ) + 
    ylab(
        "Individuals"
    ) + #+ theme(legend.position = "none")
    theme(
      legend.title = element_text(color = "black", size = 8),
      legend.text = element_text(color = "black", size = 6),
      # Change legend background color
      #legend.background = element_rect(fill = "darkgray"),
      #legend.key = element_rect(fill = "lightblue", color = NA),
      # Change legend key size and key width
      #legend.key.size = unit(0.5, "cm"),
      legend.key.width = unit(0.7,"cm"),
      legend.key.size = unit(0.3,"line"),
    ) +
    guides(colour = guide_colorbar(title.position = "top", title = element_blank()))
}
