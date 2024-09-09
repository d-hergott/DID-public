# DID-public
Data and code for difference in difference analysis on Bioko Island. 


# Overview
This repository contains a data set used to run the DID travel analysis as published in Hergott, D. et al. 

[bioko_did_analytic_dataset.csv](https://github.com/d-hergott/DID-public/blob/main/bioko_did_analytic_dataset.csv) has blinded, individual level data that was fed into the models. 
[Bioko_DID_travel_code.R](https://github.com/d-hergott/DID-public/blob/main/Bioko_DID_travel_code.R) contains the code for running the main DID analysis, land use sensitivity analysis, and generating Table 2 and Table 3 in the paper. 

[bioko_did_all_years_paralle_trends_data.csv](https://github.com/d-hergott/DID-public/blob/main/bioko_did_all_years_parallel_trends_data.csv) has blinded, individual level data for 2015-2020 used to test the parallel trends assumption. 
[Bioko_DID_parallel_trends_test.R](https://github.com/d-hergott/DID-public/blob/main/Bioko_DID_parallel_trends_test.R) contains the code for running the test of parallel trends and visualizing data. 

# Data Dictionary
The following variables are available in the analytic data set.

| Variable | Description                       |  Values     |
|----------|-----------------------------------|-------------|
| _stratum_  | Stratum assignment for EA.        | **1** = stratum 1 (low population density/high residual transmission); **2**= stratum 2 (high population density/low residual transmission)|
| _gender_   | Gender of respondent              | **1**= male; **2**= female
|_falc_pos_    | Binary variable indicating if respondent had _Pfalicarum_ infection by RDT    | **1**= positive; **0**=negative|
|_year_  |Numeric Year  |2019; 2020|
|_year.b_|Transformed binary year variable for DID analysis| **0**=2019; **1**= 2020|
|_inbefore7_| Binary variable indicating if respondent went into their home for the evening before 7pm night before survey|**1**=yes; **0**=no|
|_spry_perc_| Proportion of households in EA sprayed during spray round|0-1|
|_trav_| Binary variable indicating if EA is in high or low travel group|**0**= low travel; **1**= high travel|
|_trv_prev_| Smoothed prevalence of proportion of respondents reporting traveling to mainland in past 8 weeks (2015-2018 average)|0-1|
|_wt_| Survey weight reflecting sampling scheme of MIS|**1**=4.17 (5%); **2**=20.8 (24%) |
|_travelledisland_| Binary variable indicating if individual spent the night in a district other than their own (but within Island) in past 8 weeks|**1**=yes; **0**=no|
|_treat_| Binary indicator asking if individual sought treatment when sick. Only asked of those who were sick in past 14 days|**1**=yes; **0**=no|
|_prop_treat_| EA level variable, calculate as number of sick individual who sought treatment|0-1|
|_aircon_|Binary level variable indicating if household has airconditioning|**1**=yes; **0**=no|
|_land_use_change_| Flag for EAs with known land use changes in study period|**1**= land use change EA|
|_parent_key_| Household identifier used in creating survey object||
|_psuId_| Enumeration area identifier used in creating survey object||


# Code Questions
For any questions on code or data, please contact us using Github or email: dhergott@uw.edu. 
