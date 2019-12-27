deadlineDrivenResultsDS <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera_12_hours.txt', header = TRUE, skip=1)
summary(deadlineDrivenResultsDS)
deadlineDrivenResultsDS$strategy <- "Deadline-Driven"

adaptiveEvaluationResultsDS <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/two_stage_prediction.txt', header=T)
summary(adaptiveEvaluationResultsDS)
adaptiveEvaluationResultsDS$strategy <- "Adaptive-Evaluation"

deadlineDrivenResults <- subset(deadlineDrivenResultsDS, select=c("strategy", "runtime"))
names(deadlineDrivenResults) <- c("strategy", "runtime")
head(deadlineDrivenResults)

adaptiveEvaluationResults <- subset(adaptiveEvaluationResultsDS, select=c("strategy", "executionTime"))
names(adaptiveEvaluationResults) <- c("strategy", "runtime")
head(adaptiveEvaluationResults)

results <- rbind(deadlineDrivenResults, adaptiveEvaluationResults)
head(results)
summary(results)

setEPS()
postscript("plot_violin_evaluation_strategies_runtime_distributions.eps")
p <- ggplot(results, aes(x=strategy, y=runtime/60, fill=strategy)) + 
geom_violin() +
xlab("Strategy") + 
ylab("Execution Time (minutes)") +
theme(
    axis.title.x = element_blank(),
    legend.position = "none",
) +
scale_x_discrete(limits=c("Deadline-Driven", "Adaptive-Evaluation"))
print(p)
dev.off()
p
