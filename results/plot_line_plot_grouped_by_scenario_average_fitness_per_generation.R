resultsTSPAgof <- read.table('two_stage_prediction_agof.txt', header=T, row.names=NULL)

dsAll <- data.frame(
    generation=integer(), 
    averageFitness=double(),
    scenario=character()
)
for (i in union(21:25,25:30)) {
    ds <- subset(resultsTSPAgof, seed==i)
    fitness <- subset(ds, select=c("generation", "individual", "fireError"))
    dsMeanFitnessPerGeneration <- fitness %>% 
        group_by(generation) %>%
        summarise(averageFitness=mean(fireError))
    dsMeanFitnessPerGeneration$scenario <- as.character(i);
    dsAll <- rbind(dsAll, dsMeanFitnessPerGeneration)
    #plot(dsMeanFitnessPerGeneration$generation, dsMeanFitnessPerGeneration$mean, type='l')
}
summary(dsAll)
ggplot(data=dsAll, aes(x=generation, y=averageFitness, group=scenario)) +
  geom_line(aes(color=scenario))+
  geom_point(aes(color=scenario))
