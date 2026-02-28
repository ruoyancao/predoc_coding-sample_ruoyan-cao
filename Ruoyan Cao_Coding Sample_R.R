

# ==============================================================================
# Project: IPW ATE with Propensity Score Trimming: Robust vs. Paired Bootstrap
# (LaLonde, 1986; Dehejia & Wahba, 1999)

# Objective:
# This project is my solution to a bootstrap econometrics problem from my Master’s 
# program. I provide the full problem background in the README. This coding sample 
# replicates the standard setup used in LaLonde (1986) and Dehejia & Wahba (1999): 
# I first estimate the propensity score using a logit model and apply common support 
# (overlap) trimming. I then estimate the ATE using the IPW formula, and compute 
# standard errors using both (i) robust inference that ignores first-stage uncertainty 
# and (ii) a paired bootstrap that re-estimates the propensity score in each bootstrap draw.
# ==============================================================================

# ==============================================================================
# 00.Packages

library(haven)
library(dplyr)
library(ggplot2)
library(modelsummary)
# For robust SE in regression
library(sandwich)
library(lmtest)
# For GMM
install.packages("gmm")
library(gmm)
# robust SE for "asymptotic" comparison (same as Q2.2 regression-on-constant robust)
library(sandwich)
library(lmtest)
# ==============================================================================


# 01.Data loading and cleaning

# Load data
dat <- read_dta("E:/R-data/Metrics 2_PS4 Codes/lalonde.dta")

# Check missing value
key_vars <- c("t", "age", "educ", "black", "hisp", "marr", "re74", "u74", "re78")
missing_counts <- sapply(dat[key_vars], function(x) sum(is.na(x)))
print(missing_counts)

# Check Abnormal Value
summary_vars <- c("age", "educ", "re74", "re75", "re78")
print(summary(dat[summary_vars]))

# Check the value of binary variables
print(table(dat$t, useNA = "ifany"))
print(table(dat$black, useNA = "ifany"))
print(table(dat$hisp, useNA = "ifany"))
print(table(dat$marr, useNA = "ifany"))
print(table(dat$u74, useNA = "ifany"))

# Convert re74 from dollars to thousands of dollars
dat <- dat %>%
  mutate(
    re74_k = re74 / 1000
  )


# 02.Estimate propensity score via logit (Question 2.1)

ps_model <- glm(
  t ~ age + educ + black + hisp + marr + re74_k + u74,
  data = dat,
  family = binomial(link = "logit")
)

modelsummary(
  ps_model,
  statistic = "({std.error})",
  stars = TRUE,
  output = "markdown",
  title = "Logit Regression Results for Propensity Score Estimation"
)

# Predicted propensity score
dat <- dat %>%
  mutate(p_x = predict(ps_model, type = "response"))


# 03.Overlap check (Question 2.1)

# Numerical check: Calculate min/max of p_x for treatment/control groups
treat_pmin <- min(dat$p_x[dat$t == 1], na.rm = TRUE)
treat_pmax <- max(dat$p_x[dat$t == 1], na.rm = TRUE)

ctrl_pmin  <- min(dat$p_x[dat$t == 0], na.rm = TRUE)
ctrl_pmax  <- max(dat$p_x[dat$t == 0], na.rm = TRUE)

# Define common support (intersection of two groups' p_x ranges)
cs_min <- max(treat_pmin, ctrl_pmin) # Lower bound
cs_max <- min(treat_pmax, ctrl_pmax) # Upper bound

# Display common support range + overlap/non-overlap count (no drop)
cat("=====================================\n")
cat(sprintf("Common Support Domain (Overlap Area): p_x [%.6f, %.6f]\n", cs_min, cs_max))

overlap_n <- sum(dat$p_x >= cs_min & dat$p_x <= cs_max, na.rm = TRUE)
non_overlap_n <- sum(dat$p_x < cs_min | dat$p_x > cs_max, na.rm = TRUE)

cat("Total original sample size:", nrow(dat), "\n")
cat("Overlapping observations (in common support):", overlap_n, "\n")
cat("Non-overlapping observations (out of common support):", non_overlap_n, "\n")
cat("=====================================\n")

# Graphical overlap check
p_den <- ggplot(dat %>% filter(!is.na(p_x), !is.na(t)),
                aes(x = p_x, color = factor(t), fill = factor(t))) +
  geom_density(alpha = 0.25, linewidth = 1) +
  geom_vline(xintercept = cs_min, linetype = "dashed", color = "black") +
  geom_vline(xintercept = cs_max, linetype = "dashed", color = "black") +
  scale_color_manual(
    values = c("0" = "blue", "1" = "red"),
    labels = c("0" = "Control (t=0)", "1" = "Treatment (t=1)")
  ) +
  scale_fill_manual(
    values = c("0" = "blue", "1" = "red"),
    labels = c("0" = "Control (t=0)", "1" = "Treatment (t=1)")
  ) +
  labs(
    title = "Propensity Score Overlap: Treatment vs Control",
    x = "Propensity Score (p_x)",
    y = "Density",
    color = NULL,
    fill = NULL,
    caption = sprintf("Black dashed lines: Common Support [%.6f, %.6f]", cs_min, cs_max)
  ) +
  theme_minimal()

print(p_den)


# 04.Estimate the ATE and its standard error (Question 2.2)

# Compute common support bounds based on predicted p for t==1 and t==0
common_support_bounds <- function(p, t) {
  t_pmin <- min(p[t == 1], na.rm = TRUE)
  t_pmax <- max(p[t == 1], na.rm = TRUE)
  c_pmin <- min(p[t == 0], na.rm = TRUE)
  c_pmax <- max(p[t == 0], na.rm = TRUE)
  
  cs_min <- max(t_pmin, c_pmin)
  cs_max <- min(t_pmax, c_pmax)
  list(cs_min = cs_min, cs_max = cs_max)
}

# Regression on constant with robust SE
reg_mean_robust <- function(w) {
  fit <- lm(w ~ 1)
  se  <- sqrt(vcovHC(fit, type = "HC1"))[1, 1]
  est <- coef(fit)[1]
  list(ate = unname(est), se = unname(se))
}

# Exactly identified GMM for moment E[w - alpha] = 0
gmm_mean <- function(w) {
  # g(theta, x) = w - alpha
  g <- function(theta, x) {
    alpha <- theta[1]
    cbind(x - alpha)
  }
  # x is w
  fit <- gmm(g, x = w, t0 = mean(w, na.rm = TRUE))
  ate <- coef(fit)[1]
  se  <- sqrt(diag(vcov(fit)))[1]
  list(ate = unname(ate), se = unname(se), fit = fit)
}

# Method 1: Lalonde (1986) specification
# logit t age educ black hisp marr re74_k u74
ps_l86 <- glm(
  t ~ age + educ + black + hisp + marr + re74_k + u74,
  data = dat,
  family = binomial(link = "logit")
)

dat_l86 <- dat %>%
  mutate(p_x = predict(ps_l86, type = "response"))

# common support (intersection)
b_l86 <- common_support_bounds(dat_l86$p_x, dat_l86$t)
cs_min_l86 <- b_l86$cs_min
cs_max_l86 <- b_l86$cs_max

# drop out of support
dat_l86_cs <- dat_l86 %>%
  filter(p_x >= cs_min_l86, p_x <= cs_max_l86) %>%
  mutate(
    w = ((t - p_x) * re78) / (p_x * (1 - p_x))
  )

# Regression ATE + robust SE
l86_reg <- reg_mean_robust(dat_l86_cs$w)

# GMM ATE + SE
l86_gmm <- gmm_mean(dat_l86_cs$w)

# Method 2: Dehejia & Wahba (1999) specification
# logit t age age^2 educ educ^2 black hisp marr re74 re75 u74 u75
ps_dw99 <- glm(
  t ~ age + I(age^2) + educ + I(educ^2) + black + hisp + marr + re74 + re75 + u74 + u75,
  data = dat,
  family = binomial(link = "logit")
)

dat_dw <- dat %>%
  mutate(p_x_new = predict(ps_dw99, type = "response"))

# common support intersection for this new pscore
b_dw <- common_support_bounds(dat_dw$p_x_new, dat_dw$t)
cs_min_dw <- b_dw$cs_min
cs_max_dw <- b_dw$cs_max

# drop out of support + compute w_new
dat_dw_cs <- dat_dw %>%
  filter(p_x_new >= cs_min_dw, p_x_new <= cs_max_dw) %>%
  mutate(
    w_new = ((t - p_x_new) * re78) / (p_x_new * (1 - p_x_new))
  )

dw_reg <- reg_mean_robust(dat_dw_cs$w_new)
dw_gmm <- gmm_mean(dat_dw_cs$w_new)

# Present results
results <- tibble::tibble(
  Specification = c("Method 1 (L86)", "Method 1 (L86)", "Method 2 (DW99)", "Method 2 (DW99)"),
  Estimation    = c("Regression (robust)", "GMM (robust)", "Regression (robust)", "GMM (robust)"),
  ATE           = c(l86_reg$ate, l86_gmm$ate, dw_reg$ate, dw_gmm$ate),
  Robust_SE     = c(l86_reg$se,  l86_gmm$se,  dw_reg$se,  dw_gmm$se),
  N_used        = c(nrow(dat_l86_cs), nrow(dat_l86_cs), nrow(dat_dw_cs), nrow(dat_dw_cs)),
  CS_min        = c(cs_min_l86, cs_min_l86, cs_min_dw, cs_min_dw),
  CS_max        = c(cs_max_l86, cs_max_l86, cs_max_dw, cs_max_dw)
)

print(results)


# 05.Bootstrap Standard Error for ATE (Question 2.3)

ate_from_pscore <- function(df, p_var) {
  # compute w = ((t - p)*re78)/(p*(1-p)) and ATE = mean(w)
  p <- df[[p_var]]
  w <- ((df$t - p) * df$re78) / (p * (1 - p))
  mean(w, na.rm = TRUE)
}

asymptotic_se_ignore_first_stage <- function(w) {
  # robust SE of constant-only regression (HC1)
  fit <- lm(w ~ 1)
  sqrt(vcovHC(fit, type = "HC1"))[1, 1]
}

# One bootstrap run for a given specification:
# 1) resample rows with replacement
# 2) re-estimate logit
# 3) recompute common support and trim
# 4) compute ATE
boot_one <- function(dat, spec = c("L86", "DW99")) {
  spec <- match.arg(spec)
  
  # paired bootstrap: resample N obs with replacement
  N <- nrow(dat)
  idx <- sample.int(N, size = N, replace = TRUE)
  d <- dat[idx, , drop = FALSE]
  
  # estimate propensity score
  if (spec == "L86") {
    m <- glm(t ~ age + educ + black + hisp + marr + re74_k + u74,
             data = d, family = binomial("logit"))
    d$p <- predict(m, type = "response")
  } else {
    m <- glm(t ~ age + I(age^2) + educ + I(educ^2) + black + hisp + marr + re74 + re75 + u74 + u75,
             data = d, family = binomial("logit"))
    d$p <- predict(m, type = "response")
  }
  
  # common support bounds using treated/control intersection
  b <- common_support_bounds(d$p, d$t)
  
  # trim to common support
  d_cs <- d %>% filter(p >= b$cs_min, p <= b$cs_max)
  
  # If trimming leads to too few observations (rare but possible), return NA
  if (nrow(d_cs) < 10) return(NA_real_)
  
  # compute ATE
  ate_from_pscore(d_cs, "p")
}

# 1) "Asymptotic" SE

# Method 1 (L86)
m_l86 <- glm(t ~ age + educ + black + hisp + marr + re74_k + u74,
             data = dat, family = binomial("logit"))
dat_l86 <- dat %>% mutate(p = predict(m_l86, type = "response"))
b_l86 <- common_support_bounds(dat_l86$p, dat_l86$t)
dat_l86_cs <- dat_l86 %>% filter(p >= b_l86$cs_min, p <= b_l86$cs_max)
w_l86 <- ((dat_l86_cs$t - dat_l86_cs$p) * dat_l86_cs$re78) / (dat_l86_cs$p * (1 - dat_l86_cs$p))
ate_l86 <- mean(w_l86, na.rm = TRUE)
se_asym_l86 <- asymptotic_se_ignore_first_stage(w_l86)

# Method 2 (DW99)
m_dw <- glm(t ~ age + I(age^2) + educ + I(educ^2) + black + hisp + marr + re74 + re75 + u74 + u75,
            data = dat, family = binomial("logit"))
dat_dw <- dat %>% mutate(p = predict(m_dw, type = "response"))
b_dw <- common_support_bounds(dat_dw$p, dat_dw$t)
dat_dw_cs <- dat_dw %>% filter(p >= b_dw$cs_min, p <= b_dw$cs_max)
w_dw <- ((dat_dw_cs$t - dat_dw_cs$p) * dat_dw_cs$re78) / (dat_dw_cs$p * (1 - dat_dw_cs$p))
ate_dw <- mean(w_dw, na.rm = TRUE)
se_asym_dw <- asymptotic_se_ignore_first_stage(w_dw)

# 2) Bootstrap (paired) SE: rerun full pipeline each draw

set.seed(12345)
B <- 1000

boot_ate_l86 <- replicate(B, boot_one(dat, spec = "L86"))
boot_ate_dw  <- replicate(B, boot_one(dat, spec = "DW99"))

# remove failed draws (if any)
boot_ate_l86 <- boot_ate_l86[!is.na(boot_ate_l86)]
boot_ate_dw  <- boot_ate_dw[!is.na(boot_ate_dw)]

se_boot_l86 <- sd(boot_ate_l86)
se_boot_dw  <- sd(boot_ate_dw)

# 3) Compare results
out <- data.frame(
  Specification = c("Method 1 (L86)", "Method 2 (DW99)"),
  Mean_Boot_ATE = c(mean(boot_ate_l86), mean(boot_ate_dw)),
  Asymptotic_SE = c(se_asym_l86, se_asym_dw),
  Bootstrap_SE  = c(se_boot_l86, se_boot_dw),
  B_Used        = c(length(boot_ate_l86), length(boot_ate_dw))
)

print(out)
