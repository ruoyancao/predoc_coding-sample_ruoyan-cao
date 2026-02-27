# predoc_coding-sample_ruoyan-cao
### **3. Empirical Econometrics: Causal Inference & Data Diagnostics (Stata)**
* This project demonstrates a rigorous **Difference-in-Differences (DiD)** analysis using repeated cross-sectional data to evaluate a school-based food fortification program in India. Beyond a standard implementation, this sample focuses on the critical intersection of **causal identification and data integrity**.
* **Econometric Framework**: I estimated a DiD model using factor-variable notation and **clustered standard errors at the school level** to account for within-cluster correlation in policy implementation.
* **Advanced Data Diagnostics**: I conducted a distributional analysis of hemoglobin (Hb) levels, identifying significant **"bunching" at institutional anemia thresholds** (11.5 and 12.0 g/dl). This visualization provides empirical evidence of systematic measurement manipulation or reporting bias by enumerators.
* **Identification & Robustness Verification**:
    * **Placebo Testing**: I performed a placebo regression using "age" as a non-target outcome. The statistically insignificant DiD coefficient ($p=0.610$) confirms that the treatment and control groups remained demographically comparable, mitigating concerns regarding compositional shift bias.
    * **Pre-trend Discussion**: I critically assessed the limitations of testing the **Parallel Trends Assumption** in two-period data and proposed alternative "Event Study" specifications for multi-period extensions.
* **Key Insight**: My analysis concludes that while the program showed a statistically significant reduction in anemia for younger children (11.4 percentage points), the underlying **measurement fraud** at diagnostic cutoffs severely undermines the internal validity of the policy recommendations.

## Appendix: Problem Statement for Difference-in-Differences Analysis
### Difference-in-Differences: A case study

Anemia, defined as low hemoglobin (hb) levels in blood, is one of the most prevalent health ailments worldwide. Severe anemia can lead to impaired cognitive development among children (with lifelong consequences), high rates of maternal and perinatal deaths, and lost productivity due to lethargy and fatigue caused by diminished capacity to deliver oxygen to tissues. The most common cause of anemia is iron deficiency, estimated to account for about 50% of the global anemia prevalence among women and 40% among children. Some countries have attempted to reduce anemia rates (in some cases, successfully) through large-scale food fortification programs, that is, by increasing the content of iron in commonly consumed staples such as salt, wheat flour, or rice.

You have collected data to evaluate a school-based fortification scheme that took place in one district (a large administrative unit) in one Indian state (let us call it state S). Let us call this district T (as 'Treated'). The rest of the state was not covered by the program, but data have also been collected from another district that will be referred to as district C (as 'Control'). Before the intervention, all children in grades 1 to 8 in state S received, on every school day a rice-based warm meal, free of cost. For a period of about two-and-a-half years, the program fortified rice rations provided to all pupils in grades 1-8 in all the schools in district T. In contrast, in the rest of state S (including, of course, in district C) pupils kept receiving the usual non-fortified rice meals.

Data from district T and C have been collected both before and after the intervention. At each of the two points in time, an independent samples of 60 schools was randomly selected from each district, and from each of these schools, 36 children were randomly drawn from school rosters. The data are thus not a panel of individuals: you observe neither the same children nor children from the same schools before and after the intervention.

Let $Y_{it}$ denote an given outcome for a child i, measured at time t, $t \in \{0, 1\}$. Let us also $Post_{t}$ denote a binary variable $=1$ for children observed after the intervention, $T_{i}$ is a binary variable equal to one if the child was from district T, and $u_{ti}$ is a residual. Researchers have decided to estimate the impact of this program on anemia and other outcomes using a simple difference-in-difference framework, so they have estimated models such as the following:

(2) $y_{ti} = \beta_{0} + \beta_{T}T_{i} + \beta_{Post}Post_{t} + \beta_{DD}T_{i} \times Post_{i} + u_{ti}.$

The data can be found in **hb.dta**. Note that the data are not completely cleaned, so there are sometimes missing values or outliers. Make sure you clean up a bit before carrying out the analysis, although there should be no major problems to fix.

#### Task Requirements:

1. **(10 points)** Generate a new dummy variable **An** equal to one if the child is anemic. Define the variable as follows. For children 6-11 years old, $An=1$ if $hb < 11.5$, while for children 12-14, $An=1$ if $hb < 12$. The use of age-dependent thresholds to determine anemia status is widely accepted in public health. Estimate model (2) using **An** as dependent variable, separately for younger (age 6-11) and older (12-14) children, and interpret the results.

2. **(15 points)** Now let us look at the distribution of **hb** in the data. Estimate a histogram of **Hb** separately for children 6-11 and 12-14, before and after the intervention, in the treated and in the control district (so, a total of $2 \times 2 \times 2 = 8$ distributions). The histogram should not be 'too smooth', so use a large number of 'bins' (at least 50), where 'bins' are the intervals that form the basis of each vertical bar that composes the histogram. You could also treat Hb measurements as discrete (in Stata you can do this using `spikeplot` or `histogram, discrete`). You should notice something odd in the data, especially in relation to the thresholds defined above for anemia.

3. **(10 points)** An important international organization has actually used these data to make strong policy recommendations about the expected benefits from fortification in school meals. Do you think these data can be used to produce a convincing analysis of the school meal program that was implemented in district T? Explain, and describe how you could have improved on the study design.
