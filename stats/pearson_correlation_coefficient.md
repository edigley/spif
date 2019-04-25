Pearson correlation coefficient

Pearson correlation coefficient or the bivariate correlation is a measure of the linear correlation between two variables X and Y.

According to the Cauchy–Schwarz inequality it has a value between +1 and −1, where 
    1 is total positive linear correlation, 
    0 is no linear correlation, and 
    −1 is total negative linear correlation.

Note that the correlation reflects the noisiness and direction of a linear relationship (top row), but not the slope of that relationship (middle), nor many aspects of nonlinear relationships (bottom).
https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Correlation_examples2.svg/400px-Correlation_examples2.svg.png

It is obtained by dividing the covariance of the two variables by the product of their standard deviations.

corr is a widely used alternative notation for the correlation coefficient.

The Pearson correlation is defined only if both standard deviations are finite and positive. 

As it approaches zero there is less of a relationship (closer to uncorrelated). 
The closer the coefficient is to either −1 or 1, the stronger the correlation between the variables. 

If the variables are independent, Pearson's correlation coefficient is 0, 
    but the converse is not true because the correlation coefficient detects only linear dependencies between two variables. 

Symmetry property

The correlation coefficient is symmetric: corr(X,Y) = corr(Y,X)

Coefficient Value
0.1 < |r| < 0.3	-> small correlation
0.3 < |r| < 0.5 -> medium/moderate correlation
      |r| > 0.5 -> large/strong correlation

https://www.dummies.com/education/math/statistics/how-to-interpret-a-correlation-coefficient-r/

To interpret its value, see which of the following values your correlation r is closest to:

Exactly –1: A perfect downhill (negative) linear relationship.
–0.70: A strong downhill (negative) linear relationship.
–0.50: A moderate downhill (negative) relationship.
–0.30: A weak downhill (negative) linear relationship
0: No linear relationship.
+0.30: A weak uphill (positive) linear relationship
+0.50: A moderate uphill (positive) relationship
+0.70: A strong uphill (positive) linear relationship
Exactly +1: A perfect uphill (positive) linear relationship

If the scatterplot doesn’t indicate there’s at least somewhat of a linear relationship, the correlation doesn’t mean much. 
Why measure the amount of linear relationship if there isn’t enough of one to speak of? 
However, you can take the idea of no linear relationship two ways: 
    1) If no relationship at all exists, calculating the correlation doesn’t make sense because correlation only applies to linear relationships; and 
    2) If a strong relationship exists but it’s not linear, the correlation may be misleading, because in some cases a strong curved relationship exists. 
That’s why it’s critical to examine the scatterplot first.

How close is close enough to –1 or +1 to indicate a strong enough linear relationship? 
Most statisticians like to see correlations beyond at least +0.5 or –0.5 before getting too excited about them. 
Don’t expect a correlation to always be 0.99 however; remember, these are real data, and real data aren’t perfect.

http://onlinestatbook.com/2/describing_bivariate_data/pearson.html
Learning Objectives

    Describe what Pearson's correlation measures
    Give the symbols for Pearson's correlation in the sample and in the population
    State the possible range for Pearson's correlation
    Identify a perfect linear relationship

The Pearson product-moment correlation coefficient is a measure of the strength of the linear relationship between two variables. 
It is referred to as Pearson's correlation or simply as the correlation coefficient. 
If the relationship between the variables is not linear, 
    then the correlation coefficient does not adequately represent the strength of the relationship between the variables.

The symbol for Pearson's correlation is "ρ" when it is measured in the population and "r" when it is measured in a sample. 
    Because we will be dealing almost exclusively with samples, we will use r to represent Pearson's correlation unless otherwise noted.

Pearson's r can range from -1 to 1. 
An r of -1 indicates a perfect negative linear relationship between variables, an r of 0 indicates no linear relationship between variables, 
    and an r of 1 indicates a perfect positive linear relationship between variables.

For example, in the stock market, if we want to measure how two stocks are related to each other, 
    Pearson r correlation is used to measure the degree of relationship between the two.

Types of research questions a Pearson correlation can examine:
    Is there a statistically significant relationship between age, as measured in years, and height, measured in inches?
    Is there a relationship between temperature, measured in degrees Fahrenheit, and ice cream sales, measured by income?
    Is there a relationship between job satisfaction, as measured by the JSS, and income, measured in dollars?

Assumptions

    For the Pearson r correlation, both variables should be normally distributed (normally distributed variables have a bell-shaped curve).  
    Other assumptions include linearity and homoscedasticity.
    Linearity assumes a straight line relationship between each of the two variables and 
        homoscedasticity assumes that data is equally distributed about the regression line.

The Pearson product-moment correlation coefficient (or Pearson correlation coefficient, for short)

Are there guidelines to interpreting Pearson's correlation coefficient?

Yes, the following guidelines have been proposed:

Strength of Association
Small 	0.1 to 0.3 	-0.1 to -0.3
Medium 	0.3 to 0.5 	-0.3 to -0.5
Large 	0.5 to 1.0 	-0.5 to -1.0

Remember that these values are guidelines and whether an association is strong or not will also depend on what you are measuring.

Can you use any type of variable for Pearson's correlation coefficient?

    No, the two variables have to be measured on either an interval or ratio scale. 
    However, both variables do not need to be measured on the same scale (e.g., one variable can be ratio and one can be interval). 
    Further information about types of variable can be found in our Types of Variable guide. 
    If you have ordinal data, you will want to use Spearman's rank-order correlation or a Kendall's Tau Correlation instead of the Pearson product-moment correlation.

Do the two variables have to be measured in the same units?

    No, the two variables can be measured in entirely different units. 
    For example, you could correlate a person's age with their blood sugar levels. 
    Here, the units are completely different; 
        age is measured in years and blood sugar level measured in mmol/L (a measure of concentration). 
    Indeed, the calculations for Pearson's correlation coefficient were designed such that the units of measurement do not affect the calculation. 
    This allows the correlation coefficient to be comparable and not influenced by the units of the variables used.

What about dependent and independent variables?

    The Pearson product-moment correlation does not take into consideration whether a variable has been classified as a dependent or independent variable. 
    It treats all variables equally. 
    For example, you might want to find out whether basketball performance is correlated to a person's height. 
    You might, therefore, plot a graph of performance against height and calculate the Pearson correlation coefficient. 
    Lets say, for example, that r = .67. That is, as height increases so does basketball performance. 
    This makes sense. 
    However, if we plotted the variables the other way around and wanted to determine whether a person's height was determined by their basketball performance 
        (which makes no sense), we would still get r = .67. 
    This is because the Pearson correlation coefficient makes no account of any theory behind why you chose the two variables to compare.

Does the Pearson correlation coefficient indicate the slope of the line?

    It is important to realize that the Pearson correlation coefficient, r, does not represent the slope of the line of best fit. 
    Therefore, if you get a Pearson correlation coefficient of +1 this does not mean that for every unit increase in one variable 
        there is a unit increase in another. It simply means that there is no variation between the data points and the line of best fit. 

What assumptions does Pearson's correlation make?

There are five assumptions that are made with respect to Pearson's correlation:

    The variables must be either interval or ratio measurements (see our Types of Variable guide for further details).
    The variables must be approximately normally distributed (see our Testing for Normality guide for further details).
    There is a linear relationship between the two variables (but see note at bottom of page). We discuss this later in this guide (jump to this section here).
    Outliers are either kept to a minimum or are removed entirely. We also discuss this later in this guide (jump to this section here).
    There is homoscedasticity of the data. This is discussed later in this guide (jump to this section here).

How can you detect a linear relationship?

    To test to see whether your two variables form a linear relationship you simply need to plot them on a graph (a scatterplot, for example) 
        and visually inspect the graph's shape. 
    In the diagram below, you will find a few different examples of a linear relationship and some non-linear relationships. 
    It is not appropriate to analyse a non-linear relationship using a Pearson product-moment correlation.

Note: 
    Pearson's correlation determines the degree to which a relationship is linear. 
    Put another way, it determines whether there is a linear component of association between two continuous variables. 
    As such, linearity is not actually an assumption of Pearson's correlation. 
    However, you would not normally want to pursue a Pearson's correlation to determine the strength and direction of a linear relationship 
        when you already know the relationship between your two variables is not linear. 
    Instead, the relationship between your two variables might be better described by another statistical measure. 
    For this reason, it is not uncommon to view the relationship between your two variables in a scatterplot to see 
        if running a Pearson's correlation is the best choice as a measure of association or whether another measure would be better.

How can you detect outliers?

    An outlier (in correlation analysis) is a data point that does not fit the general trend of your data, 
        but would appear to be a wayward (extreme) value and not what you would expect compared to the rest of your data points. 
    You can detect outliers in a similar way to how you detect a linear relationship, 
        by simply plotting the two variables against each other on a graph and visually inspecting the graph for wayward (extreme) points. 
    You can then either remove or manipulate that particular point as long as you can justify why you did so 
        (there are far more robust methods for detecting outliers in regression analysis). 
    Alternatively, if you cannot justify removing the data point(s), you can run a nonparametric test such as 
        Spearman's rank-order correlation or Kendall's Tau Correlation instead, which are much less sensitive to outliers. 
    This might be your best approach if you cannot justify removing the outlier. 

Why is testing for outliers so important?

    Outliers can have a very large effect on the line of best fit and the Pearson correlation coefficient,
        which can lead to very different conclusions regarding your data. 
    This point is most easily illustrated by studying scatterplots of a linear relationship with an outlier included and after its removal, 
        with respect to both the line of best fit and the correlation coefficient.

https://statistics.laerd.com/statistical-guides/pearson-correlation-coefficient-statistical-guide.php
https://statistics.laerd.com/statistical-guides/pearson-correlation-coefficient-statistical-guide-2.php