# You might think that the function chisq.test() would be the best way to test a variance in R. 
# Although base R provides this function, it’s not appropriate here. Statisticians use this function to test other kinds of hypotheses.

# Instead, turn to a function called varTest, which is in the EnvStats package. 
# On the Packages tab, click Install. 
# Then type EnvStats into the Install Packages dialog box and click Install. 
# When EnvStats appears on the Packages tab, select its check box.

# Before you use the test, you create a vector to hold the ten measurements:

FarKlempt.data2 <- c(12.43, 11.71, 14.41, 11.05, 9.53, 11.66, 9.33,11.71,14.35,13.81)

# And now, the test:

varTest(FarKlempt.data2,alternative="greater",conf.level = 0.95,sigma.squared = 2.25)

# The first argument is the data vector. 
# The second specifies the alternative hypothesis that the true variance is greater than the hypothesized variance, 
# the third gives the confidence level (1 – ɑ), and 
# the fourth is the hypothesized variance.

# Results of Hypothesis Test
# --------------------------
# Null Hypothesis: variance = 2.25
# Alternative Hypothesis: True variance is greater than 2.25
# Test Name: Chi-Squared Test on Variance
# Estimated Parameter(s): variance = 3.245299

# Data: FarKlempt.data2
# Test Statistic: Chi-Squared = 12.9812
# Test Statistic Parameter: df = 9
# P-value: 0.163459
# 95% Confidence Interval: LCL = 1.726327
# UCL = Inf

# Among other statistics, the output shows 
#    the chi-square (12.9812) and the 
#    p-value (0.163459). 
# (The chi-square value in the previous section is a bit lower because of rounding.) 
# The p-value is greater than .05. 
# Therefore, you cannot reject the null hypothesis.

# How high would chi-square (with df = 9) have to be in order to reject? Hmmm. . .