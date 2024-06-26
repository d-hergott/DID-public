#### Bioko DiD travel analysis ####
##   Author: dhergott@uw.edu
##   Last update: 26JUN2024
##################################

# Set-up ----
rm(list=ls())
if(!require(pacman)){install.packages("pacman")}
pacman::p_load(dplyr, survey)

df <- read.csv("bioko_did_analytic_dataset.csv")
cc_vars <- c("inbefore7", "spry_perc", "aircon", "travelledisland") #define variables to control for

# ========FUNCTIONS==============
# Write functions for analyzing data ----
# the function ensures that the unadjusted and adjusted model use the same dataset

analyze_data <- function(data, covars=NULL, family = "gaussian") {
  c_data <- data[complete.cases(data[covars]), ] 
  svy.d <- svydesign(id= ~psuId+~parent_key, strata= ~stratum, weights=~wt, data=c_data) #make the survey design object
  # Construct the formula for the model
  linmod_unad <- svyglm(falc_pos~trav*year.b, design = svy.d , family = family)
  if(!is.null(covars)){
    cov.list <- paste0(covars, collapse='+')
    formula_linmod <- formula(paste0("falc_pos", "~trav*year.b", "+", cov.list))
    # Fit the  model
    linmod_adj <- svyglm(formula_linmod, design = svy.d , family = family)}
  else{
    linmod_adj <- svyglm(falc_pos~trav*year.b, design = svy.d , family = family)
  }
  
  # Print summary, coefficients, and confidence intervals of the model
  print(nobs(linmod_unad))
  print(summary(linmod_unad))
  print(coef(linmod_unad))
  print(confint(linmod_unad))
  
  if(family=="gaussian"){
    did.term.unad <- coef(linmod_unad)[length(coef(linmod_unad))]
    direction <- ifelse(did.term.unad<0, "decreased", "increased")
    print(paste0("Prevalence ", direction, " by ", round(did.term.unad*100,0), "% than expected in high travel areas in unadjusted model"))
  }
  if(family=="binomial"){
    did.term.unad <- exp(coef(linmod_unad)[length(coef(linmod_unad))])
    direction <- ifelse(did.term.unad <1, "lower", "higher")
    print(paste0("Odds of infection was", round(did.term.unad,2), "times", direction, "than expected in high travel areas in unadjusted model"))
  }
  
  print(nobs(linmod_adj))
  print(summary(linmod_adj))
  print(coef(linmod_adj))
  print(confint(linmod_adj))
  
  if(family=="gaussian"){
    did.term.adj <- coef(linmod_adj)[length(coef(linmod_adj))]
    direction <- ifelse(did.term.adj <0, "decreased", "increased")
    print(paste0("Prevalence ", direction, " by ", round(did.term.adj*100,0), "% than expected in high travel areas in model adjusted for",
                 covars))
  }
  if(family=="binomial"){
    did.term.adj <- exp(coef(linmod_adj)[length(coef(linmod_adj))])
    direction <- ifelse(did.term.adj <1, "lower", "higher")
    print(paste0("Odds of infection was", round(did.term.adj,2), "times", direction, "than expected in high travel areas in model adjusted for", covars))
  }
  
}

# for outputting only the model outpts
did_model <- function(data, covars=NULL, family = "gaussian") {
  c_data <- data[complete.cases(data[covars]), ] #make a dataframe with only the complete cases of the variables we're interested in.
  svy.d <- svydesign(id= ~psuId+~parent_key, strata= ~stratum, weights=~wt, data=c_data) #make the survey design object
  # Construct the formula for the linear model
  linmod <- svyglm(falc_pos~trav*year.b, design = svy.d , family = family)
  if(!is.null(covars)){
    cov.list <- paste0(covars, collapse='+')
    formula_linmod <- formula(paste0("falc_pos", "~trav*year.b", "+", cov.list))
    # Fit the linear model
    linmod <- svyglm(formula_linmod, design = svy.d , family = family)}
  else{
    linmod <- svyglm(falc_pos~trav*year.b, design = svy.d , family = family)
  }
  return(linmod)
}

# for calculating prevalence estimates using linear combinations
prev.est <- function(model, coeffs) {
  # coeffs is a vector of coefficients (e.g., c(b0, b1, b2, b3))
  est <- svycontrast(model, coeffs)
  prev <- est[1]
  se <- SE(est)
  lcl <- prev - 1.96 * se
  ucl <- prev + 1.96 * se
  vec <- cbind(prev, lcl, ucl)
  result <- paste0(round(prev*100, 1), " (", round(lcl*100,1), ",", round(ucl*100,1), ")")
  return(result)
}

#===========DID MODELS=================== 
# Run the main analyses ----
## Linear models ----
analyze_data(df, c("inbefore7", "spry_perc", "aircon", "travelledisland"))

unad.mod <- did_model(df[complete.cases(df[,cc_vars]),])
adj.mod <- did_model(df, c("inbefore7", "spry_perc", "aircon", "travelledisland"))

summary(unad.mod)
summary(adj.mod)

## Odds ratio models ----
analyze_data(df, c("inbefore7", "spry_perc", "aircon", "travelledisland"), "binomial")

mod1 <- did_model(df[complete.cases(df[,cc_vars]),], family="binomial")
mod2 <- did_model(df, c("inbefore7", "spry_perc", "aircon", "travelledisland"), family="binomial")

# Sensitivity analysis 1 - Land use change ----
df.sens <- df %>% filter(land_use_change==0) #remove areas with known landuse changes

analyze_data(df.sens, c("inbefore7", "spry_perc", "aircon", "travelledisland"))

unad.mod.s <- did_model(df.sens[complete.cases(df.sens[,cc_vars]),])
adj.mod.s <- did_model(df.sens, c("inbefore7", "spry_perc", "aircon", "travelledisland"))

# =========SELECT TABLES ================
# Table 2 calculations ----
## unadjusted estimates ----
low2019 <- prev.est(unad.mod, c(1,0,0,0))
low2020 <- prev.est(unad.mod, c(1,0,1,0))
lowdiff <- prev.est(unad.mod, c(0,0,1,0))
high2019 <- prev.est(unad.mod, c(1,1,0,0))
high2020 <- prev.est(unad.mod, c(1,1,1,1))
highdiff <- prev.est(unad.mod, c(0,0,1,1))
did.unadjusted <- prev.est(unad.mod, c(0,0,0,1))

prev.unadjusted <- data.frame(rbind(low2019, low2020, high2019,  high2020), row.names=c("low2019", "low2020", "high2019",  "high2020"))
prev.unadjusted <- cbind(prev.unadjusted, rbind(lowdiff, lowdiff, highdiff, highdiff), rbind(did.unadjusted))

colnames(prev.unadjusted) <- c("Prevalence", "Difference by Year", "Difference in Differences")

## adjusted estimates ----
low2019 <- prev.est(adj.mod, c(1,0,0,0,0,0,0,0))
high2019 <- prev.est(adj.mod, c(1,1,0,0,0,0,0,0))
low2020 <- prev.est(adj.mod, c(1,0,1,0,0,0,0,0))
high2020 <- prev.est(adj.mod, c(1,1,1,0,0,0,0,1))

adj.prev.est <- cbind(low2019, high2019, low2020, high2020)


# Table 3 calculations ----
diff.results <- matrix(nrow=6, ncol=4, NA)

## unadjusted----
un.mods <- c("unad.mod", "unad.mod.s")

for (name in un.mods){
  i <- which(un.mods==name)
  mod <- get(name)
  high20high19 <- prev.est(mod,c(0,0,1,1))
  low20low19 <- prev.est(mod, c(0,0,1,0))
  high20low19 <- prev.est(mod, c(0,1,1,1))
  high20low20 <- prev.est(mod, c(0,1,0,1))
  high19low19 <- prev.est(mod, c(0,1,0,0))
  did <- prev.est(mod, c(0,0,0,1))
  diff.results[,i] <- rbind(high20high19, low20low19, high20low19, high20low20, high19low19, did)
}

## adjusted ----
adj.mods <- c("adj.mod", "adj.mod.s" )

for (name in adj.mods){
  i <- which(adj.mods==name)+2
  mod <- get(name)
  high20high19 <- prev.est(mod, c(0,0,1,0,0,0,0,1))
  low20low19 <- prev.est(mod, c(0,0,1,0,0,0,0,0))
  high20low19 <- prev.est(mod, c(0,1,1,0,0,0,0,1))
  high20low20 <- prev.est(mod, c(0,1,0,0,0,0,0,1))
  high19low19 <- prev.est(mod, c(0,1,0,0,0,0,0,0))
  did <- prev.est(mod, c(0,0,0,0,0,0,0,1))
  diff.results[,i] <- rbind(high20high19, low20low19, high20low19, high20low20, high19low19, did)
}

## Make data frame ----
diff.results <- as.data.frame(diff.results)
diff.results <- diff.results[,c(1,3,2,4)] #move around the columns
names(diff.results) <- c("main_unadj", "main_adj", "sens_unadj", "sens_adj") #rename
comparison <- c("2020 vs. 2019 in high travel areas", "2020 vs. 2019 in low travel areas", "high travel 2020 - low travel 2019", "high travel vs. low travel in 2020", "high travel vs. low travel in 2019", "Difference in differences")
diff.results <- cbind(comparison, diff.results)



