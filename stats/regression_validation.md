Regression validation

In statistics, regression validation is the process of 
    deciding whether the numerical results quantifying hypothesized relationships between variables, 
    obtained from regression analysis, are acceptable as descriptions of the data. 
The validation process can involve 
    analyzing the goodness of fit of the regression, 
    analyzing whether the regression residuals are random, and 
    checking whether the model's predictive performance deteriorates substantially when applied to data that were not used in model estimation.

Goodness of fit
    One measure of goodness of fit is the R2 (coefficient of determination), 
        which in ordinary least squares with an intercept ranges between 0 and 1. 
    While a low R2 implies that the model does not fit the data well, an R2 close to 1 does not guarantee that the model fits the data well: 
        as Anscombe's quartet shows, a high R2 can occur in 
            the presence of misspecification of the functional form of a relationship or in 
            the presence of outliers that distort the true relationship.

One problem with the R2 as a measure of model validity is that it can always be increased by adding more variables into the model, 
    except in the unlikely event that the additional variables are exactly uncorrelated with the dependent variable in the data sample being used. 
This problem can be avoided by doing an F-test of the statistical significance of the increase in the R2, or by instead using the adjusted R2. 

Anaysis of residuals

The residuals from a fitted model are 
    the differences between 
        the responses observed at each combination of values of the explanatory variables and 
        the corresponding prediction of the response computed using the regression function. 

Mathematically, the definition of the residual for the ith observation in the data set is written 
    e_i = y_i - f(x_i;B)

with 
    y_i denoting the ith response in the data set and 
    xi the vector of explanatory variables, each set at the corresponding values found in the ith observation in the data set. 

If the model fit to the data were correct, 
    the residuals would approximate the random errors 
        that make the relationship between 
            the explanatory variables and 
            the response variable a statistical relationship. 
Therefore, if the residuals appear to behave randomly, it suggests that the model fits the data well. 
On the other hand, if non-random structure is evident in the residuals, it is a clear sign that the model fits the data poorly. 

The next section details the types of plots to use to test different aspects of a model and gives the correct interpretations of different results that could be observed for each type of plot. 

Graphical analysis of residuals

    A basic, though not quantitatively precise, way to check for problems that render a model inadequate is to conduct a visual examination of the residuals 
        (the mispredictions of the data used in quantifying the model) 
    to look for obvious deviations from randomness. 
    If a visual examination suggests, for example, the possible presence of 
        heteroskedasticity (a relationship between the variance of the model errors and the size of an independent variable's observations), 
        then statistical tests can be performed to confirm or reject this hunch; 
        if it is confirmed, different modeling procedures are called for. 

    Different types of plots of the residuals from a fitted model provide information on the adequacy of different aspects of the model.

    sufficiency of the functional part of the model: scatter plots of residuals versus predictors
    non-constant variation across the data: scatter plots of residuals versus predictors; for data collected over time, also plots of residuals against time
    drift in the errors (data collected over time): run charts of the response and errors versus time
    independence of errors: lag plot
    normality of errors: histogram and normal probability plot

Graphical methods have an advantage over numerical methods for model validation because they readily illustrate a broad range of complex aspects of the relationship between the model and the data. 