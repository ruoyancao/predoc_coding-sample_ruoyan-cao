/* ================================================================================

To demonstrate my proficiency in Stata and the Difference-in-Differences (DID) 
framework, I present an empirical analysis developed during my master's studies.

================================================================================

Project: Evaluation of School-based Food Fortification Program in India
Task: Difference-in-Differences (DiD) Analysis of Anemia Prevalence
Data: hb.dta

================================================================================

BACKGROUND:

The study evaluates the impact of iron-fortified rice meals on children's 
hemoglobin (hb) levels in District T (Treated) vs District C (Control).
The program covered grades 1-8 over a 2.5-year period.

Note: For a comprehensive understanding of the research context, I have included 
the complete problem statement in README.

================================================================================
*/

* 0. Parallel Trends

/* 0.1 Why Parallel Trends Cannot Be Tested Here:
   
   Identification in DiD relies on the "Parallel Trends Assumption." 
   To formally test this, we typically require at least two pre-treatment 
   periods to observe if the groups evolved similarly before the policy.
   In this dataset (hb.dta), we only observe a single pre-intervention period (t=0) 
   and a single post-intervention period (t=1). 
   With only two points in time, it is mathematically impossible to verify 
   pre-existing trends or conduct an "Event Study".

   STANDARD STATA CODE FOR PARALLEL TRENDS (If multiple periods existed):
   * Assuming 'year' variable exists with multiple years before/after 2026:
   * reg An i.T##i.year, vce(cluster id_school)
   * coefplot, keep(*.T#*.year) vertical yline(0) 
*/

/* 0.2 Relationship Between Distributional Analysis and Parallel Trends:
   While Question 3.2 (Histogram Analysis) is not a test of parallel trends, 
   it serves as a fundamental "Data Integrity Check". 
   Even if parallel trends were theoretically satisfied, the "bunching" 
   observed at the thresholds (11.5 and 12.0) suggests that the treatment 
   effect is confounded by systematic measurement manipulation. 
   In research, data quality is a prerequisite for any identification strategy; 
   if the outcome variable is manipulated, the DiD point estimate is biased 
   regardless of trend alignment.
*/

/* 0.3 Placebo Test (Counterfactual Logic):
   A common robustness check is a "Placebo Outcome" test. If the program 
   truly improves iron levels, it should NOT affect biological traits 
   unrelated to iron, such as 'height' or 'age'.
   
   We conduct placebo tests in Section 5.
*/

* ================================================================================

clear all
set more off
set varabbrev off


* 1. Data Cleaning and Variable Construction (Question 3.1)
use "E:/Stata_data/EUI-Metrics II-PS4/hb.dta", clear
* Remove outliers and missing values as suggested
drop if hb <= 0 | hb > 25
drop if missing(hb) | missing(age) | missing(T) | missing(Post)
* Generate Age Groups
gen age_group = .
replace age_group = 1 if age >= 6  & age <= 11
replace age_group = 2 if age >= 12 & age <= 14
label define age_lbl 1 "Younger (6-11)" 2 "Older (12-14)"
label values age_group age_lbl
* Generate Anemia Dummy (An) based on age-specific thresholds
gen An = 0
replace An = 1 if age_group == 1 & hb < 11.5
replace An = 1 if age_group == 2 & hb < 12.0
label var An "Anemia Indicator"


* 2. Regression Analysis (Question 3.1)
* We estimate a Linear Probability Model (LPM) with Clustered Standard Errors 
* at the school level (id_school).
foreach g in 1 2 {
    display "--- DiD Results for Age Group: `: label age_lbl `g'' ---"
    reg An T##Post if age_group == `g', vce(cluster id_school)
}
/* INTERPRETATION OF DID RESULTS:
(1). Younger Children (Ages 6-11):
   - The DiD coefficient (Treated#After) is -0.114 and highly significant (p=0.001).
   - Finding: The program reduced the probability of anemia by 11.4 percentage points for this group.
   - Context: This suggests a substantial health improvement relative to the high baseline anemia rate.

(2). Older Children (Ages 12-14):
   - The DiD coefficient is +0.106 with a p-value of 0.053.
   - Finding: The effect is statistically insignificant at the 5% level.
   - Note: The positive coefficient is counter-intuitive and may stem from data noise or measurement error.

(3). Econometric Notes:
   - Inference: Standard errors are clustered at the school level to account for within-cluster correlation.
   - Identification: Results show strong age-based heterogeneity, possibly due to physiological differences or meal consumption patterns.
   - Data Quality: The significant result for younger children should be viewed with caution due to observed "bunching" near thresholds, suggesting potential misreporting.
*/


* 3. Distributional Analysis (Question 3.2)
* Visualize the distribution of hb to detect potential data manipulation.

forval g = 1/2 {
    local age_name  = cond(`g'==1, "6-11", "12-14")
    local threshold = cond(`g'==1, 11.5, 12.0)
    
    twoway (hist hb if age_group==`g' & T==0 & Post==0, bin(60) color(blue%30)) ///
           (hist hb if age_group==`g' & T==1 & Post==1, bin(60) color(red%30)), ///
           xline(`threshold', lcolor(black) lpattern(dash)) ///
           legend(label(1 "Control Pre") label(2 "Treated Post")) ///
           title("Hb Distribution: Ages `age_name'") ///
           ylabel(0(0.5)1.5, format(%4.1f) angle(0)) graphregion(fcolor(white)) /// 
           note("Dashed line: Anemia threshold (`threshold'). Visual bunching suggests data issues.")
           
    graph export "hist_age`g'.png", replace
}
pwd

/* OBSERVATION:
The histograms confirm severe bunching at diagnostic thresholds. This evidence of measurement manipulation suggests that the DiD estimates may be driven by reporting bias rather than clinical efficacy, a critical finding for my policy evaluation.
*/


* 4. Policy Recommendation (Question 3.3) 
/*
1. Data Integrity & Credibility:
   - Despite the statistically significant DiD estimate for younger children, these data 
     do not support strong policy recommendations.
   - The histograms reveal severe "bunching" and irregularities around the anemia 
     thresholds (11.5 and 12.0), strongly suggesting systematic measurement error 
     or deliberate misclassification by enumerators.
   - Such reporting bias means the observed "reduction" in anemia may reflect 
     manipulated records rather than actual health improvements.

2. Identification Challenges:
   - The study compares only one treated district to one control district, which 
     weakens the Parallel Trends Assumption and limits external validity.
   - The use of repeated cross-sections instead of panel data prevents controlling 
     for child-level unobserved heterogeneity.

3. Recommended Design Improvements:
   - Use continuous hemoglobin (Hb) levels as the primary outcome instead of 
     threshold-based binary indicators to avoid "bunching" bias.
   - Decouple research measurements from clinical diagnosis/treatment decisions 
     to reduce incentives for misreporting.
   - Transition to a panel data structure tracking the same children or schools.
   - Include multiple treated and control districts to strengthen the DiD framework.
*/

* 5. Placebo Test
/* To further validate the DiD identification strategy, I conducted a placebo test 
   using 'age' as a dependent variable. Since the iron-fortified rice program targets 
   nutritional outcomes (Hb levels), it should theoretically have no causal impact 
   on the baseline age of the children sampled.
*/
display "--- PLACEBO TEST: Using AGE as a fake outcome ---"
reg age T##Post, vce(cluster id_school)
/* RESULTS:
   1. Coefficient of Interest (Treated#After): 
      The DiD term for 'age' is +0.052 with a p-value of 0.610. 
   2. Statistical Significance: 
      The estimate is small and statistically indistinguishable from zero at any 
      conventional significance level (p > 0.1).
   3. Implications: 
      - The null hypothesis that the program had no effect on the average age of 
        sampled children cannot be rejected.
      - This result provides evidence against "Compositional Change" bias. It 
        suggests that the sampled populations in the treatment and control districts 
        did not systematically shift in terms of age over the study period.
      - Passing this placebo test increases confidence that the observed changes 
        in anemia (in Section 2) are not merely artifacts of changes in the 
        demographic composition of the repeated cross-sections.

   CONCLUSION:
   The placebo test supports the internal validity of the research design by 
   confirming that the treatment and control groups remained comparable in terms 
   of key non-target characteristics.
*/
