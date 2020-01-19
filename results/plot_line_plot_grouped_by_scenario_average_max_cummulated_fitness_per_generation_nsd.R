source("https://raw.githubusercontent.com/edigley/spif/master/results/function_generate_aggregated_stats.R")

resultsTSPNSD <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/two_stage_prediction.txt', header=T, row.names=NULL)

dsAll <- generateAggregatedStats(resultsTSPNSD)

#summary(dsAll)
#head(dsAll)

ggplot(data=dsAll, aes(x=generation, y=minCummFitnees, group=scenario)) +
  geom_line(aes(color=scenario)) +
  geom_point(aes(color=scenario))

ggplot(data=dsAll, aes(x=generation, y=averageFitness, group=scenario)) +
  geom_line(aes(color=scenario)) +
  geom_point(aes(color=scenario))
