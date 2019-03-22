# Simple Linear regression

Linear regression answers a simple question: Can you measure an exact relationship between one target variables and a set of predictors?

The simplest of probabilistic models is the straight line model:

![][032918_1024_RSimpleMult7.jpg]
https://www.guru99.com/images/r_programming/032918_1024_RSimpleMult7.jpg

y = b0 + b1*x + e

where

    - y  = Dependent variable
    - x  = Independent variable
    - e  = random error component
    - b0 = intercept
    - b1 = Coefficient of x

If x equals to 0, y will be equal to the intercept.
b1 is the slope of the line. It tells in which proportion y varies when x varies. 

To estimate the optimal values of b0 and b1, you use a method called **Ordinary Least Squares (OLS)**.
This method tries to find the parameters that minimize the sum of the squared errors, that is the vertical distance between the predicted y values and the actual y values. The difference is known as the **error term**.

Before you estimate the model, you can determine whether a linear relationship between y and x is plausible by plotting a scatterplot. 

## Scatterplot

### Least Squares Estimates

In a simple OLS regression, the computation of a0 and b0 is straightforward. The goal is not to show the derivation in this tutorial. You will only write the formula.

You want to estimate: *y = b0 + b1*x + e*

The goal of the OLS regression is to minimize the following equation:

where

is the actual value and is the predicted value. 

