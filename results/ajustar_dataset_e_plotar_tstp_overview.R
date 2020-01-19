#Para descobrir quantos elementos existem em cada geracao
calculateSummary <- function(resultsTSP) {
    summaryAll <- data.frame(
            generation=integer(), 
            nElements=double(),
            scenario=character()
    )
    for (i in unique(resultsTSP$seed)) {
        ds <- subset(resultsTSP, seed==i)
        fitness <- subset(ds, select=c("generation", "individual"))
        singleSummary <- fitness %>% 
            group_by(generation) %>%
            summarise(nElements=n())
        singleSummary$scenario <- as.character(i)
        summaryAll <- rbind(summaryAll, singleSummary)
    }
    summaryAll
}

# preparar a funcao
plotCalibrationOverview <- function(resultsTSP) {
    theSeed        <- unique(resultsTSP$seed)
    tempResultsTSP <- subset(resultsTSP, select=c("generation", "individual", "executionTime"))
    tempResultsTSP <- tempResultsTSP[order(tempResultsTSP$generation, tempResultsTSP$individual),]

    nResultsTSP <- data.frame(
        generation    = tempResultsTSP$generation, 
        individual    = tempResultsTSP$individual,
        executionTime = tempResultsTSP$executionTime,
        case          = paste("TSP",theSeed),
        hours         = 12,
        startTime     = 0
    )
    nds <- nResultsTSP %>% 
        group_by(generation) %>% 
        mutate(
            generationMaxExecutionTime=max(executionTime),
            rowGroupNumber=dplyr::row_number(),
            generationSize=max(dplyr::row_number())
        ) 

    write.table(nds, "dataframe_nds.txt", append = FALSE, sep = " ", dec = ".", row.names = TRUE, col.names = TRUE)

    nds$generationMaxFinishTime <- nds$startTime + nds$generationMaxExecutionTime

    for (i in 1:max(nds$generation)) {
        nds <- within(nds,      startTime[generation==1] <- 0)
        nds <- within(nds, rowGroupNumber[generation==1] <- 0)
        nds <- nds %>%
            group_by(case) %>%
            mutate(
                startTime = generationMaxFinishTime[row_number()-rowGroupNumber],
                generationMaxFinishTime = startTime + generationMaxExecutionTime
            )
        nds <- within(nds,      startTime[generation==1] <- 0)
        nds <- within(nds, rowGroupNumber[generation==1] <- 0)
        nds$generationMaxFinishTime <- nds$startTime + nds$generationMaxExecutionTime
    }

    summary <- nds %>% 
        group_by(generation) %>%
        summarise(nElements=n())

    summary <- summary %>% 
        mutate(cumulated=cumsum(nElements)+1)

    #summary

    nds$Worker <- nds$rowGroupNumber
    nds$start  <- nds$startTime
    nds$end    <- nds$startTime + nds$executionTime

    sub <- subset(nds, select=c(individual, Worker, start, end))
    sub <- within(sub, Worker[individual<=50] <- individual[individual<=50])

    nTail <- 54
    theSummary <- rbind(
        head(nds, summary$cumulated[ 1]) %>% tail(nTail),
        head(nds, summary$cumulated[ 2]) %>% tail(nTail),
        head(nds, summary$cumulated[ 3]) %>% tail(nTail),
        head(nds, summary$cumulated[ 4]) %>% tail(nTail),
        head(nds, summary$cumulated[ 5]) %>% tail(nTail),
        head(nds, summary$cumulated[ 6]) %>% tail(nTail),
        head(nds, summary$cumulated[ 7]) %>% tail(nTail),
        head(nds, summary$cumulated[ 8]) %>% tail(nTail),
        head(nds, summary$cumulated[ 9]) %>% tail(nTail),
        head(nds, summary$cumulated[10]) %>% tail(nTail),
        head(nds, summary$cumulated[11]) %>% tail(nTail),
        head(nds, summary$cumulated[12]) %>% tail(nTail),
        head(nds, summary$cumulated[13]) %>% tail(nTail)
    )
    theSummary <- theSummary[order(theSummary$generation, theSummary$individual),]

    graph_tsp_overview(sub, unique(nResultsTSP$case), "Running in Intel i3 4-Core")
}
                       
#names(theSummary)
#subset(theSummary, generation==1, select=c(generation, individual, executionTime, rowGroupNumber, generationMaxFinishTime, Worker, start, end));
#subset(theSummary, generation==2, select=c(generation, individual, executionTime, rowGroupNumber, generationMaxFinishTime, Worker, start, end));

summaryAll <- calculateSummary(resultsTSPAgof)
subset(summaryAll, generation==1)

#Ajustar o dataset original
resultsTSPAgof <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/two_stage_prediction_agof.txt', header=T, row.names=NULL)

for (theSeed in unique(summaryAll$scenario)) {
    theDS <- subset(summaryAll, scenario==theSeed & generation==1)
    resultsTSPAgof <- within(resultsTSPAgof, generation[individual<=theDS$nElements & seed == theSeed] <-  1)
    resultsTSPAgof <- within(resultsTSPAgof, generation[individual<=100 & seed == theSeed] <-  0)
    resultsTSPAgof <- within(resultsTSPAgof, generation[individual<= 50 & seed == theSeed] <- -1)
}
resultsTSPAgof <- within(resultsTSPAgof, generation <- generation + 2)

# plot all scenarios
for (i in unique(resultsTSPAgof$seed)) {
    resultsTSP   <- subset(resultsTSPAgof, seed==i)
    resultsTSP[] <- lapply(resultsTSP, function(x) if(is.factor(x)) factor(x) else x)
    print(plotCalibrationOverview(resultsTSP))
}
