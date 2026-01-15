# Lecture 2 - Simple linear regression

## Prediction of the conditional mean: E[y|x]=f(x)

- Expected values (average)
- The actual value of y can be lower/higher than the mean depending on the error term of or the residual e
  - $y=f(x)+e$
  - $y^E=f(x)$
  - $y^E$ is the conditional mean

## Nonparametric modelling

- We're not assuming a functional form for f(x) when modelling y^E
- We can do it through bins or smoothing
- A popular smoothing method: Lowess smoothing

## SLR: Continous case

- $y^E=alpha+beta(x)$
- Example interpr.: The predicted average value of y when x is zero is -5000. When x increases by one, the predicted average increase in y is 3000. The standard deviation of the conditional distributions is 13.
- Watch out for increase/increase when discussing SLR. Do not imply causality

## Natural logs

- $ln(a)-ln(b)$ = basically a percentage change. Enables better communication of differences
- Logs transform the skewed part of distributions, so that they look more linear
- loglog, levellog, loglevel regressions depending on loging x or y
  - loglog: a percentage change associated with a percentage change in y
  - levellog: a percentage change associated with a $beta$*0.01 change in y
  - loglevel: a percentage change associated with a $beta$*100 change in y
- It's good to graph the data to know whether to log x or y