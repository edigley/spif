source("https://raw.githubusercontent.com/edigley/spif/master/results/graph_tsp_overview.R")
plotCalibrationOverview <- function(resultsTSP) {
    theSeed <- unique(resultsTSP$seed)
    resultsTSP <- subset(resultsTSP, select=c("generation", "individual", "executionTime"))
    resultsTSP$case  <- paste("TSP",theSeed)
    resultsTSP$hours <- 12
    resultsTSP$startTime <- 0
    nds <- resultsTSP %>% 
        group_by(generation) %>% 
        mutate(
            generationMaxExecutionTime=max(executionTime),
            rowGroupNumber=dplyr::row_number(),
            generationSize=max(dplyr::row_number())
        ) 
    nds$generationMaxFinishTime <- nds$startTime + nds$generationMaxExecutionTime

    for (i in 1:11) {
        nds <- within(nds,      startTime[generation==0] <- 0)
        nds <- within(nds, rowGroupNumber[generation==0] <- 0)
        nds <- nds %>%
            group_by(case) %>%
            mutate(
                startTime = generationMaxFinishTime[row_number()-rowGroupNumber],
                generationMaxFinishTime = startTime + generationMaxExecutionTime
            )
        nds <- within(nds,      startTime[generation==0] <- 0)
        nds <- within(nds, rowGroupNumber[generation==0] <- 0)
        nds$generationMaxFinishTime <- nds$startTime + nds$generationMaxExecutionTime
    }

    summary <- nds %>% 
        group_by(generation) %>%
        summarise(nElements=n())

    summary <- summary %>% 
        mutate(cumulated=cumsum(nElements)+1)

    nds$Worker <- nds$rowGroupNumber
    nds$start  <- nds$startTime
    nds$end    <- nds$startTime + nds$executionTime
    sub <- subset(nds, select=c(individual, Worker, start, end))
    sub <- within(sub, Worker[individual<100] <- individual[individual<100])

    theSummary <- rbind(
        head(nds, summary$cumulated[ 1]) %>% tail(2),
        head(nds, summary$cumulated[ 2]) %>% tail(2),
        head(nds, summary$cumulated[ 3]) %>% tail(2),
        head(nds, summary$cumulated[ 4]) %>% tail(2),
        head(nds, summary$cumulated[ 5]) %>% tail(2),
        head(nds, summary$cumulated[ 6]) %>% tail(2),
        head(nds, summary$cumulated[ 7]) %>% tail(2),
        head(nds, summary$cumulated[ 8]) %>% tail(2),
        head(nds, summary$cumulated[ 9]) %>% tail(2),
        head(nds, summary$cumulated[10]) %>% tail(2),
        head(nds, summary$cumulated[11]) %>% tail(2)
    )

    graph_tsp_overview(sub, resultsTSP$case, "Running in Intel i3 4-Core")
    
    #theSummary;
}
