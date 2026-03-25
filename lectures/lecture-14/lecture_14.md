# Lecture 14

The report will be submitted in parts

Guidance on the report is on Canvas

## 3.1 A Framework for Prediction

Different structure from causal inference

Types

- Quantitative
- Probability
- Time Series

Framework

- Combining estimation and model selection

### Three types of errors

We need to minimize the prediction error

Types

1) Estimation error
    - Difference between the estimated value and the true coefficient
    - Can be reduced with more data or better estimation methods
2) Model error
    - Difference between the true model value and the best possible predictor (any model)
    - Caused by using a model that does not capture the true data-generating process
3) Genuine (irreducible) error
    - Even when estimation and model errors are zero
    - Y cannot be predicted perfectly from X; sets a floor on prediction accuracy

### Loss function

Assigns value to a prediction error - how bad is the error

Key qualitative characteristics

- Symmetry: are errors in opposite directions equally costly?
- Convexity: do twice-as-large errors incur more than twice the loss

More complex models reduce bias but increase variance (overfitting)