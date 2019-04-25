Analysis of variance

Analysis of variance (ANOVA) is a collection of statistical models and their associated estimation procedures 
    (such as the "variation" among and between groups) used to analyze the differences among group means in a sample. 
ANOVA was developed by statistician and evolutionary biologist Ronald Fisher. 

In the ANOVA setting, the observed variance in a particular variable is partitioned into components attributable to different sources of variation. 

In its simplest form, ANOVA provides a statistical test of whether the population means of several groups are equal, 
    and therefore generalizes the t-test to more than two groups. 

ANOVA is useful for comparing (testing) three or more group means for statistical significance. 
It is conceptually similar to multiple two-sample t-tests, but is more conservative, resulting in fewer type I errors,
    and is therefore suited to a wide range of practical problems. 


Analysis of Variance (ANOVA) is a commonly used statistical technique for investigating data by comparing the means of subsets of the data. 
The base case is the one-way ANOVA which is an extension of two-sample t test for independent groups covering situations where 
    there are more than two groups being compared.

In one-way ANOVA the data is sub-divided into groups based on a single classification factor and 
    the standard terminology used to describe the set of factor levels is **treatment** even though 
        this might not always have meaning for the particular application. 
    There is variation in the measurements taken on the individual components of the data set and ANOVA investigates whether 
        this variation can be explained by the grouping introduced by the classification factor.

https://www.r-bloggers.com/one-way-analysis-of-variance-anova/amp/

As an example we consider one of the data sets available with R relating to an experiment into plant growth. 
The purpose of the experiment was to compare the yields on the plants for a control group and two treatments of interest. 
The response variable was a measurement taken on the dried weight of the plants.