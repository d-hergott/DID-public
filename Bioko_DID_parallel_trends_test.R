##### Bioko DiD parallel trends analysis ####
##   Author: dhergott@uw.edu
##   Last update: 09SEP2024
##   Purpose: Code used to test parallel trends assumption
##            of data from 2015-2019 in low and high travel areas
#################################################################

# Set-up ----
rm(list=ls())
if(!require(pacman)){install.packages("pacman")}
pacman::p_load(dplyr, ggplot2, lme4, lmerTest)

df <- read.csv("bioko_did_all_years_parallel_trends_data.csv")


# Create model ----
# By interacting year*travel, we can see if the difference is consistent between years
mod.lmer <- lmer(falc_pos~as.factor(year.f)*trav + (1|psuId), data=subset(df,year.f<2020))
summary(mod.lmer)
nobs(mod.lmer)

## Sensitivity analysis ----
# Remove the PsuIDs that had land use changes in 2017
mod.lmer.sens <- lmer(falc_pos~as.factor(year.f)*trav + (1|psuId), data=subset(df,year.f<2020 & land_use_change_2017==0))
summary(mod.lmer.sens)
nobs(mod.lmer.sens)

# Plot ----
## Preparations ----
pred <- c(2,2020,0.201794, NA, NA, NA) #predictions from Bioko_DID_travel_code.R model
h.2019 <- c(2,	2019,	0.144, NA, NA, NA)
sum3 <- aggregate(df$falc_pos, by=list(df$trav, df$year.f), FUN=mean, na.rm=TRUE)
se3 <- aggregate(df$falc_pos, by=list(df$trav, df$year.f), function(x) sd(x, na.rm=TRUE) / sqrt(length(x)))
sum3$se <- se3$x
sum3 <- sum3 %>%
  mutate(lcl=x-1.96*se,
         ucl=x+1.96*se)
sum3 <- rbind(sum3, pred, h.2019)
names(sum3) = c("Group", "Year", "Pf_prevalence", "se", "lcl", "ucl")

psu_prevalence <- df %>%
  group_by(psuId, year.f, trav) %>%
  summarise(psu_prevalence = mean(falc_pos, na.rm = TRUE),
            n = n(),
            .groups = 'drop')

# Plot to visualize
ggplot(data=sum3, aes(x=Year, y=Pf_prevalence, group=Group, color=as.factor(Group)))+
  geom_point(data=psu_prevalence, aes(x=year.f, y=psu_prevalence, color=as.factor(trav), group=trav, size=n),
             position=position_jitterdodge(jitter.width=0.1, jitter.height=0, dodge.width=0.2), alpha=0.5)+
  geom_errorbar(data=subset(sum3, Group==0 | Group==1), aes(ymin=lcl, ymax=ucl), width=0.2, linewidth=0.7)+
  geom_line(data=subset(sum3, Group==0 | Group==1),linewidth=1)+
  geom_line(data=subset(sum3, Group==2), linewidth=1, linetype="1111")+
  
  scale_y_continuous(name=expression(paste(italic("Pf")," Prevalence")), limits=c(0,.55), labels=scales::percent)+
  scale_x_continuous(limits=c(2014.9, 2020.1), breaks=c(2015, 2016, 2017, 2018, 2019, 2020))+
  theme_classic()+
  scale_color_manual(name="Prevalence Estimates", 
                     labels = c("Low Travel Areas- mean prevalence",
                                "High travel Areas- mean prevalence",
                                "High travel Areas- predicted prevalence with no ban"),
                     values = c("0"="#E1BE6A",
                                "1"="#40B0A6",
                                "2"="#40B0A6"))+
  scale_fill_manual(name=element_blank(), 
                    labels = c("Low Travel Areas- mean prevalence",
                               "High travel Areas- mean prevalence",
                               "High travel Areas- predicted prevalence with no ban"),
                    values = c("0"="#E1BE6A",
                               "1"="#40B0A6",
                               "2"="#40B0A6"),
                    guide="none")+
  scale_size_area(name ='Total tested in EA', 
                  breaks=c(30, 60, 100, 200, 500, max(psu_prevalence$n)),
                  labels = c('<30', '30-59', '60-99', '100-199', '200-499', '>500'),
                  max_size=2)+
  theme(text = element_text(family="sans", size=7))

