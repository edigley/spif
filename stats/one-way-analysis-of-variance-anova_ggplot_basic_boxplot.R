# https://www.r-bloggers.com/one-way-analysis-of-variance-anova/amp/

plant.df = PlantGrowth
plant.df$group = factor(plant.df$group, labels = c("Control", "Treatment 1", "Treatment 2"))
require(ggplot2)
 
ggplot(plant.df, aes(x = group, y = weight)) +
  geom_boxplot(fill = "grey80", colour = "blue") +
  scale_x_discrete() + 
  xlab("Treatment Group") +
  ylab("Dried weight of plants")

# The geom_boxplot() option is used to specify background and outline colours for the boxes. The axis labels are created with the xlab() and ylab() options. 

plant.mod1 = lm(weight ~ group, data = plant.df)

# We save the model fitted to the data in an object so that we can undertake various actions to study the goodness of the fit to the data and other model assumptions. 
# The standard summary of a lm object is used to produce the following output:

summary(plant.mod1)

# The model output indicates some evidence of a difference in the average growth for the 2nd treatment compared to the control group. 
# An analysis of variance table for this model can be produced via the anova command:

anova(plant.mod1)

# This table confirms that there are differences between the groups which were highlighted in the model summary. 
# The function confint is used to calculate confidence intervals on the treatment parameters, by default 95% confidence intervals:

confint(plant.mod1)

# The model residuals can be plotted against the fitted values to investigate the model assumptions. 
# First we create a data frame with the fitted values, residuals and treatment identifiers:

plant.mod = data.frame(
    Fitted = fitted(plant.mod1),
    Residuals = resid(plant.mod1), 
    Treatment = plant.df$group
)

# and then produce the plot:

ggplot(plant.mod, aes(Fitted, Residuals, colour = Treatment)) + geom_point()