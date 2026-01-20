# Linear Regressions continuation

- When it's log-log, you don't convert numbers by *100
  - $ln(price^y)=\alpha+\beta(x)$

## Splining

- Statistical method that models complex, non-linear relationships between variables by fitting low-degree polynomial functions (like lines or curves) to different segments of the data, connecting them smoothly at points called knots
- **When to use**: if you want the slope to differ for different section of values
- By overfitting the data, you lose the predictive power

## Quadratic or higher-level polynomials

- $y^E=\alpha+\beta_1x+\beta_2x^2$
  - $\alpha$ is average y when x is 0
  - $\beta_1$ is has no meaningful interpretation
  - $\beta_2$ signals when the relationship is convex (if positive) or concave (if negative)

## R-Squared

- $R^2=\frac{Var[\hat{y}]}{Var[y]}=1-\frac{Var[e]}{Var[y]}$
- Sometimes a lower $R^2$ is ok

## Statistical inference

- Bootstrapping: Repeated random sampling within a sample with replacement. This gives multiple $\hat\beta$, through which we'll calculate the SE
  - Estimating the sampling distribution of a statistic
- $SE(\hat\beta)=\frac{Std[e]}{\sqrt{n}Std(x)}$
- A robust SE is assuming heteroskedasticity
