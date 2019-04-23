F-test

An F-test is any statistical test in which the test statistic has an F-distribution under the null hypothesis. 
It is most often used when comparing statistical models that have been fitted to a data set, 
    in order to identify the model that best fits the population from which the data were sampled. 
Exact "F-tests" mainly arise when the models have been fitted to the data using least squares. 
The name was coined by George W. Snedecor, in honour of Sir Ronald A. Fisher. Fisher initially developed the statistic as the variance ratio in the 1920s.

Common examples of the use of F-tests include the study of the following cases: 

The hypothesis that the means of a given set of normally distributed populations, 
    all having the same standard deviation, are equal. 
This is perhaps the best-known F-test, and plays an important role in the analysis of variance (ANOVA).

The hypothesis that a proposed regression model fits the data well. See Lack-of-fit sum of squares.

The hypothesis that a data set in a regression analysis follows the simpler of two proposed linear models that are nested within each other.

In addition, some statistical procedures, such as Scheffé's method for multiple comparisons adjustment in linear models, also use F-tests. 

F-test of the equality of two variances
Main article: F-test of equality of variances

The F-test is sensitive to non-normality.
In the analysis of variance (ANOVA), alternative tests include Levene's test, Bartlett's test, and the Brown–Forsythe test. 
However, when any of these tests are conducted to test the underlying assumption of homoscedasticity (i.e. homogeneity of variance), 
as a preliminary step to testing for mean effects, there is an increase in the experiment-wise Type I error rate.


Formula and calculation
    
    Most F-tests arise by considering a decomposition of the variability in a collection of data in terms of sums of squares. 
    The test statistic in an F-test is the ratio of two scaled sums of squares reflecting different sources of variability. 
    These sums of squares are constructed so that the statistic tends to be greater when the null hypothesis is not true. 
    In order for the statistic to follow the F-distribution under the null hypothesis, the sums of squares should be statistically independent, and each should follow a scaled χ²-distribution. 
    The latter condition is guaranteed if the data values are independent and normally distributed with a common variance. 


Multiple-comparison ANOVA problems

    The F-test in one-way analysis of variance is used to assess whether the expected values of a quantitative variable within several pre-defined groups differ from each other. 
    For example, suppose that a medical trial compares four treatments. 
    The ANOVA F-test can be used to assess whether any of the treatments is on average superior, or inferior, to the others 
        versus the null hypothesis that all four treatments yield the same mean response. 
    This is an example of an "omnibus" test, meaning that a single test is performed to detect any of several possible differences. 
    Alternatively, we could carry out pairwise tests among the treatments 
        (for instance, in the medical trial example with four treatments we could carry out six tests among pairs of treatments). 
    The advantage of the ANOVA F-test is that we do not need to pre-specify which treatments are to be compared, 
        and we do not need to adjust for making multiple comparisons. 
    The disadvantage of the ANOVA F-test is that if we reject the null hypothesis, 
        we do not know which treatments can be said to be significantly different from the others, 
            nor, if the F-test is performed at level α, 
                can we state that the treatment pair with the greatest mean difference is significantly different at level α. 