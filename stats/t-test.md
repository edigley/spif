Student's t-test

The t-test is any statistical hypothesis test in which the test statistic follows a Student's t-distribution under the null hypothesis. 
The t-test can be used, for example, to determine if the means of two sets of data are significantly different from each other. 

The t-test provides an exact test for the equality of the means of two normal populations with unknown, but equal, variances.
(Welch's t-test is a nearly exact test for the case where the data are normal but the variances may differ.)
For moderately large samples and a one tailed test, the t-test is relatively robust to moderate violations of the normality assumption.

By the central limit theorem, sample means of moderately large samples are often well-approximated by a normal distribution even if the data are not normally distributed.
For non-normal data, the distribution of the sample variance may deviate substantially from a χ2 distribution. 
However, if the sample size is large, Slutsky's theorem implies that the distribution of the sample variance has little effect on the distribution of the test statistic. 

When the normality assumption does not hold, a non-parametric alternative to the t-test can often have better statistical power.

In the presence of an outlier, the t-test is not robust.

For example, for two independent samples when the data distributions are asymmetric (that is, the distributions are skewed) or the distributions have large tails, 
then the Wilcoxon rank-sum test (also known as the Mann–Whitney U test) can have three to four times higher power than the t-test.

Among the most frequently used t-tests are: 
    A one-sample location test of whether the mean of a population has a value specified in a null hypothesis.
    A two-sample location test of the null hypothesis such that the means of two populations are equal. 
        All such tests are usually called Student's t-tests, though strictly speaking that name should only be used if the variances of the two populations are also assumed to be equal; 
        the form of the test used when this assumption is dropped is sometimes called Welch's t-test. 
        These tests are often referred to as "unpaired" or "independent samples" t-tests, 
            as they are typically applied when the statistical units underlying the two samples being compared are non-overlapping.[8]



Welch's t-test

In statistics, Welch's t-test, or unequal variances t-test, is a two-sample location test which is used to test the hypothesis that two populations have equal means. 
It is named for its creator, Bernard Lewis Welch, and is an adaptation of Student's t-test, and is more reliable when the two samples have unequal variances and/or unequal sample sizes.

These tests are often referred to as "unpaired" or "independent samples" t-tests, as they are typically applied when the statistical units underlying the two samples being compared are non-overlapping.

Given that Welch's t-test has been less popular than Student's t-test[2] and may be less familiar to readers, a more informative name is "Welch's unequal variances t-test" or "unequal variances t-test" for brevity.