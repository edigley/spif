individualHeader <- c(params, paste("p", seq(11,21), sep=""))
individuals <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals.txt', skip=1, col.names=individualHeader)
individuals <- subset(individuals, select=params)
individuals <- tibble::rowid_to_column(individuals, "id")
individuals$id <- (individuals$id - 1)
setdiff(0:1000, individuals$id)
head(individuals, 6)
plot(
    predict(marsRuntime, head(individuals, 1001)), 
    ds$runtime, 
    xlab="predicted", 
    ylab="actual", 
    xlim=c(0,20000), 
    ylim=c(0,20000)
)
qqplot(
    predict(marsRuntime, head(individuals, 1001)), 
    ds$runtime
)
abline(a=0, b=1)
plot(density(residuals(marsRuntime)))
plot(sort(residuals(marsRuntime)))
plot(residuals(marsRuntime), pch=".")
qqnorm(residuals(marsRuntime))
qqline(residuals(marsRuntime))