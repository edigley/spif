df <- read.table( header=T, text='
             strategy  makespan  min  max  color
        "Single Core"      8.00 8.00 8.00    red
                "TAC"      3.10 3.10 3.10   blue
"Adaptive Evaluation"      1.10 1.00 1.25  green
')

library(ggplot2)
ggplot(df, aes(x = reorder(strategy, -makespan), y = makespan)) + 
    geom_bar(stat = "identity") + 
    geom_errorbar(
        position = position_dodge(.9),
        width = .25,
        aes(ymin = min, ymax = max)
    ) +
    xlab("Evaluation Strategy used in calibration phase") + 
    ylab("Overall Execution time (hours)") + 
    ggtitle("Comparing different evaluation strategies") + 
    theme(plot.title = element_text(hjust = 0.5))
