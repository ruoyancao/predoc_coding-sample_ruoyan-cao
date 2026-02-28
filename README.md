## Empirical Finance Research & Data Science Portfolio_Ruoyan Cao

This repository contains the coding samples for my pre-doctoral applications, focusing on **empirical finance**. It demonstrates my proficiency in data engineering, econometric modeling, and visualization using **SAS, Stata, R and Python**. The coding samples are organized by software tool.

### 01. SAS: Large-Scale Data Engineering & Structural Modeling

**Key Script**: 'Ruoyan Cao_Coding Sample_SAS'

This section demonstrates my capacity to manage the full research lifecycle, from raw data extraction to the implementation of structural identification strategies, using SAS Enterprise Guide.

**Working Paper 1**: The Impact of ESG-ratings Disagreement on Corporate Cash Holdings

This project investigates how information outcome uncertainty, proxied by ESG-ratings disagreement, influences corporate liquidity management. The empirical challenge lies in **robust variable construction** and **addressing non-random sample selection**.

* **Variable Construction & Measurement**: I constructed a firm-year proxy for **ESG-ratings disagreement** by calculating the standard deviation of normalized scores across **Asset4, MSCI IVA, and Sustainalytics**. To control for market-level risk, I developed a **SAS Macro** to estimate annual **firm-level Betas** via **rolling-window regressions** (Fama-French 3-Factor & Momentum models) using 15 years of daily **CRSP** stock returns.
* **Multi-Database Integration**: I integrated **Compustat, CRSP, and Thomson Reuters** by utilizing the **CCM Link Table** to resolve the mapping identification issue between **GVKEY** and **PERMNO**. All relational joins were executed via optimized **PROC SQL** statements to ensure data integrity across different reporting frequencies.
* **Sample Refinement & Data Cleaning**: Following corporate finance literature, I excluded **financial and utility** firms and applied **1% winsorization** to all continuous variables. I implemented a strict **nmiss** check to ensure the internal validity of the regression sample while managing the trade-off between data quality and sample size.
* **Heckman Selection Model Implementation**: To address **self-selection bias** in ESG coverage, I estimated a **Probit-based Selection Equation** using the full sample (including non-rated firms). I derived the **Inverse Mills Ratio (IMR)** from the first stage and incorporated it as a correction term in the second-stage regression, ensuring the estimated impact of ESG-ratings disagreement is not confounded by **unobservable factors**.

**Working Paper 2**: Be Armed with Knowledge Capital: The Coopetition Peer Effect in Corporate Investment Efficiency

This project identifies the causal influence of strategic peer effects on a firm's investment efficiency, addressing the **reflection problem** and **simultaneity bias inherent** in peer effect studies.

* **Instrumental Variable (IV) Strategy**: I employed **peer advertising expenses** as an instrument for peer investment, as advertising serves as a strong predictor of a peer's strategic expansion **(relevance)** but is exogenous to the focal firm's internal investment technology **(exclusion restriction)**. This isolates genuine peer influence from correlated industry-wide shocks.
* **2SLS Implementation & Structural Diagnostics**: I implemented a **Two-Stage Least Squares (2SLS)** approach by first estimating the exogenous variation in peer investment using **a predictive macro** to purge endogenous components. The second stage regresses the focal firm's investment efficiency on these **predicted values**, incorporating knowledge capital as a moderator while employing industry-year fixed effects and clustered standard errors for robust inference.

### 02. Stata: Impact Evaluation & Structural Diagnostics: Beyond the DID Baseline

**Key Script**: 'Ruoyan Cao_Coding Sample_Stata'

This project demonstrates a rigorous **Difference-in-Differences (DID)** analysis using repeated cross-sectional data to evaluate a school-based food fortification program in India. Beyond a standard implementation, this sample focuses on the critical intersection of **causal identification and data integrity**.
* **Econometric Framework**: I estimated a DID model using factor-variable notation and **clustered standard errors at the school level** to account for within-cluster correlation in policy implementation.
* **Advanced Data Diagnostics**: I conducted a distributional analysis of hemoglobin (Hb) levels, identifying significant **bunching at institutional anemia thresholds** (11.5 and 12.0 g/dl). This visualization provides empirical evidence of systematic measurement manipulation or reporting bias by enumerators.

| Ages 6-11 (Threshold 11.5) | Ages 12-14 (Threshold 12.0) |
| :---: | :---: |
| ![Hb Distribution 6-11](figures/hist_age1.png) | ![Hb Distribution 12-14](figures/hist_age2.png) | 

* **Identification & Robustness Verification**:
    * **Placebo Testing**: I performed a placebo regression using **age** as a non-target outcome. The statistically insignificant DiD coefficient ($p=0.610$) confirms that the treatment and control groups remained demographically comparable, mitigating concerns regarding compositional shift bias.
    * **Pre-trend Discussion**: I critically assessed the limitations of testing the **Parallel Trends Assumption** in two-period data and proposed alternative **Event Study** specifications for multi-period extensions.
* **Key Insight**: My analysis concludes that while the program showed a statistically significant reduction in anemia for younger children (11.4 percentage points), the underlying **measurement fraud** at diagnostic cutoffs severely undermines the internal validity of the policy recommendations.

**Note**: The complete problem statement for this econometrics project is provided in **Appendix A** for your reference.

### 03.R: IPW Treatment Effects & Bootstrap Inference (LaLonde, 1986; Dehejia & Wahba, 1999)

**Key Script**: 'Ruoyan Cao_Coding Sample_R'

This project demonstrates a complete **two-step causal estimation pipeline** in R, with a focus on **overlap diagnostics**, **estimator stability**, and **inference with generated regressors**.

* **Propensity Score Estimation (Logit)**: I implement two widely used specifications in the program evaluation literature: (i) A baseline specification following **LaLonde (1986)**; (ii) An augmented specification following **Dehejia & Wahba (1999)**, adding nonlinear terms and additional pre-treatment covariates.
* **Common Support / Overlap Diagnostics and Trimming**: I assess overlap by comparing the propensity score distributions of treated and control observations. To stabilize IPW weights, I apply **common support trimming** using the intersection of propensity score ranges across treatment groups, and visualize overlap using **density plots** (especially informative when treatment/control sample sizes are unbalanced).

<img src="figures/pscore_overlap_density.png" alt="Propensity Score Overlap: Treatment vs Control" width="650">

* **ATE Estimation via IPW (Regression and GMM Presentations)**: I estimate the ATE using the standard IPW moment condition: $\widehat{\alpha}=\frac{1}{N}\sum_i \frac{(t_i-\hat p_i)\,re78_i}{\hat p_i(1-\hat p_i)}$. For each specification, I present results in two equivalent ways: (i) **Regression-on-a-constant** with heteroskedasticity-robust standard errors; (ii) A **GMM interpretation** of the exactly identified moment condition (highlighting the equivalence between the sample mean estimator and exactly identified GMM).
* **Bootstrap Inference for Two-Step Estimators (Paired Bootstrap)**: To account for first-stage estimation uncertainty, I implement a **paired bootstrap** that re-runs the full estimation pipeline in each draw: (i) Resample observations with replacement; (ii) Re-estimate the logit model to obtain bootstrap propensity scores; (iii) Recompute common support bounds and re-trim the sample; (iv) Recompute the IPW ATE. The standard deviation of bootstrap ATEs provides a standard error that reflects sampling variation from both the first-stage propensity score estimation and the second-stage IPW estimator.

**Note**: The full problem statement and data description are provided in the **Appendix B**.

### Appendix A: Full Problem Statement for Difference-in-Differences Analysis: A Case Study

Anemia, defined as low hemoglobin (hb) levels in blood, is one of the most prevalent health ailments worldwide. Severe anemia can lead to impaired cognitive development among children (with lifelong consequences), high rates of maternal and perinatal deaths, and lost productivity due to lethargy and fatigue caused by diminished capacity to deliver oxygen to tissues. The most common cause of anemia is iron deficiency, estimated to account for about 50% of the global anemia prevalence among women and 40% among children. Some countries have attempted to reduce anemia rates (in some cases, successfully) through large-scale food fortification programs, that is, by increasing the content of iron in commonly consumed staples such as salt, wheat flour, or rice.

You have collected data to evaluate a school-based fortification scheme that took place in one district (a large administrative unit) in one Indian state (let us call it state S). Let us call this district T (as 'Treated'). The rest of the state was not covered by the program, but data have also been collected from another district that will be referred to as district C (as 'Control'). Before the intervention, all children in grades 1 to 8 in state S received, on every school day a rice-based warm meal, free of cost. For a period of about two-and-a-half years, the program fortified rice rations provided to all pupils in grades 1-8 in all the schools in district T. In contrast, in the rest of state S (including, of course, in district C) pupils kept receiving the usual non-fortified rice meals.

Data from district T and C have been collected both before and after the intervention. At each of the two points in time, an independent samples of 60 schools was randomly selected from each district, and from each of these schools, 36 children were randomly drawn from school rosters. The data are thus not a panel of individuals: you observe neither the same children nor children from the same schools before and after the intervention.

Let $Y_{it}$ denote an given outcome for a child i, measured at time t, $t \in \{0, 1\}$. Let us also $Post_{t}$ denote a binary variable $=1$ for children observed after the intervention, $T_{i}$ is a binary variable equal to one if the child was from district T, and $u_{ti}$ is a residual. Researchers have decided to estimate the impact of this program on anemia and other outcomes using a simple difference-in-difference framework, so they have estimated models such as the following:

(2) $y_{ti} = \beta_{0} + \beta_{T}T_{i} + \beta_{Post}Post_{t} + \beta_{DD}T_{i} \times Post_{i} + u_{ti}.$

The data can be found in **hb.dta**. Note that the data are not completely cleaned, so there are sometimes missing values or outliers. Make sure you clean up a bit before carrying out the analysis, although there should be no major problems to fix.

#### Task Requirements:

1. (10 points) Generate a new dummy variable **An** equal to one if the child is anemic. Define the variable as follows. For children 6-11 years old, $An=1$ if $hb < 11.5$, while for children 12-14, $An=1$ if $hb < 12$. The use of age-dependent thresholds to determine anemia status is widely accepted in public health. Estimate model (2) using **An** as dependent variable, separately for younger (age 6-11) and older (12-14) children, and interpret the results.

2. (15 points) Now let us look at the distribution of **hb** in the data. Estimate a histogram of **Hb** separately for children 6-11 and 12-14, before and after the intervention, in the treated and in the control district (so, a total of $2 \times 2 \times 2 = 8$ distributions). The histogram should not be 'too smooth', so use a large number of 'bins' (at least 50), where 'bins' are the intervals that form the basis of each vertical bar that composes the histogram. You could also treat Hb measurements as discrete (in Stata you can do this using `spikeplot` or `histogram, discrete`). You should notice something odd in the data, especially in relation to the thresholds defined above for anemia.

3. (10 points) An important international organization has actually used these data to make strong policy recommendations about the expected benefits from fortification in school meals. Do you think these data can be used to produce a convincing analysis of the school meal program that was implemented in district T? Explain, and describe how you could have improved on the study design.

### Appendix B: Full Problem Statement for Bootstrap

This problem is based on a subset of the data used in Lalonde (1986, AER, 'Evaluating the econometric evaluations of training programs', 76, 604-620) and subsequently re-analyzed in Dehejia and Wahba (1999, JASA, 'Causal effects in nonexperimental studies: re-evaluating the evaluation of training programs', 94 (448), 1053-1062). Data (**lalonde.dta**) are from an experimental treatment group and from a non-experimental control group, a sample from the PSID. The regressors are described below. t is the treatment indicator (=1 for treated, those who attend the job training program). The outcome variable is re78 (real earnings in 1978).

 | Variable Name | Variable Description |
 | :--- | :--- |
 | **age** | age |
 | **educ** | years of education |
 | **black** | indicator for Afro-American |
 | **hisp** | indicator for hispanic-american |
 | **marr** | indicator for married |
 | **re74** | earnings in 1974 (in thousands of 1978 $) |
 | **re75** | earnings in 1975 (in thousands of 1978 $) |
 | **u74** | indicator for unemployed in 1974 |
 | **u75** | indicator for unemployed in 1975 |

#### Task Requirements:

1. (5 points) Estimate the propensity score, using a logit model, and using as predictors AGE, EDUC, BLACK, HISP, MARR, RE74 and U74.

2. (10 points) Using the propensity score estimated in the previous point, and eq. (1), estimate the ATE and its standard error. For simplicity you can ignore the fact that the propensity score has been estimated in the previous step.

3. (10 points) Now you want to estimate the standard error of the ATE, but taking into account that the propensity score had been estimated, and this may contribute to the variance (in general, in two-step estimators the contribution of the estimation error from a 1st stage needs to be taken into account). You do not want to rely on asymptotic approximations and you decide to use the bootstrap. Estimate the s.e. of ˆα using paired bootstrap, and compare the results with those in the previous step.
