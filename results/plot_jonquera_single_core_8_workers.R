source("https://raw.githubusercontent.com/edigley/spif/master/results/graph_tsp_overview.R")

results <- read.table('https://raw.githubusercontent.com/edigley/cloudsim/master/input-files/jonquera_single_core_8_workers_trace.txt', header = TRUE)
ws <- subset(results, !is.na(start), select=c( "individual", "start", "end" ))

names(ws) <- c("Worker", "start", "end")
ws$start  <- ws$start * 10
ws$end    <- ws$end   * 10

graph_tsp_overview(ws, "Deadline-Driven" ,"Running in 8Core XEN Cluster")
