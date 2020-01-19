source("https://raw.githubusercontent.com/edigley/spif/master/results/function_generate_aggregated_stats.R")

resultsTSPAgof <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/two_stage_prediction_agof.txt', header=T, row.names=NULL)

dsAll <- generateAggregatedStats(resultsTSPAgof)

#summary(dsAll)
#head(dsAll)

ggplot(data=dsAll, aes(x=generation, y=maxCummFitnees, group=scenario)) +
  geom_line(aes(color=scenario)) +
geom_point(aes(color=scenario))
