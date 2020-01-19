generateAggregatedStats <- function(resultsTSP) {
    dsAll <- data.frame(
        generation=integer(), 
        averageFitness=double(),
        scenario=character()
    )
    for (i in unique(resultsTSP$seed)) {
        ds <- subset(resultsTSP, seed==i)
        fitness <- subset(ds, select=c("generation", "individual", "fireError"))
        dsMeanFitnessPerGeneration <- fitness %>% 
            group_by(generation) %>%
            summarise(
                averageFitness=mean(fireError), 
                minFitness=min(fireError), 
                maxFitness=max(fireError)
            )
        dsMeanFitnessPerGeneration$scenario <- as.character(i);
        dsMeanFitnessPerGeneration$maxCummFitnees <- cummax(dsMeanFitnessPerGeneration$maxFitness)
        dsMeanFitnessPerGeneration$minCummFitnees <- cummin(dsMeanFitnessPerGeneration$minFitness)
        dsAll <- rbind(dsAll, dsMeanFitnessPerGeneration)
    }
    dsAll
}
