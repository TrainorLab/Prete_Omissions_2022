library(plyr)
library(tidyverse)
library(ggpubr)
library(rstatix)
library(emmeans)
library(ggplot2)
library(multcomp)
library(coin)

rm(list = ls())
setwd("C:/Users/its_d/Desktop/infant_omit_rates/")#//trainorserv.mcmaster.ca/trainorlab/David_Prete/Infant_Omit_rates/ICA means/")
dir()


# CONVERT TO data_long FORMAT ####

#CHANGE TO READ IN EITHER THE MMN DATA FOR THE P3a DATA
#data = read.csv("P3_ICA_One_latency_per_region_per_condition_typical_filte2r.csv")
data = read.csv("MMN_ICA_One_latency_per_region_per_condition_typical_filte2r.csv")



data = data[,c(1:7,11:16)] #removes the DIFF data columns
data = data[,c(1,8:10,17:19)] # Keeps only the diff


data_long = data %>% pivot_longer(
  cols = names(data[c(2:7)]),
  names_to = c("Silence", "Centrality","Laterality"),
  names_sep="_",
  values_to="Mean_Amp"
)

#ONLY RUN WHEN ANALYZING 
data_long = subset(data_long, select = -c(Silence) )


data$diff_avg <- rowMeans(data[c(2:7)], na.rm=TRUE) #Participant averages across all conditions 
data$cent_diff_avg <- rowMeans(data[c(2:4)], na.rm=TRUE) #Participant averages for the 3 central regions 
data$front_diff_avg <- rowMeans(data[c(5:7)], na.rm=TRUE) #Participant averages for the 3 frontal regions 
data$frontLM_diff_avg <- rowMeans(data[c(5:6)], na.rm=TRUE) #Participant averages for the Left ad middle frontal regions 

# DESCRIPTIVES AND VISUALISATION ####

data_long %>%
  group_by(Centrality, Laterality) %>%
  get_summary_stats(Mean_Amp, type = "mean_sd") 

# PLOT ALL CONDITIONS
bxp <- ggboxplot(
  data_long, x = "Centrality",xlab = "Centrality",
  y = "Mean_Amp",ylab = expression(paste("Amplitude (", mu, "v)")),
  palette = "jco",notch= FALSE,
  facet.by = "Laterality", short.panel.labs = TRUE, 
  legend = "right"
)
bxp

# TEST FOR NORMALITY (SHAPIRO OR VISUAL INSPECTION) ####

#LOOKS FOR OUTLIERS IN THE DATA
z = data_long %>%
  group_by(Centrality) %>%
  identify_outliers(Mean_Amp)

#CONDUCT SHAPRIO-WILK TEST TO TEST ASSUMPTION OF NORMALITY 
data_long %>%
  group_by(Silence,Laterality,Centrality) %>%
  shapiro_test(Mean_Amp)

#VIZUAL PLOT OF THE ASSUMTION OF NORMALITY 
ggqqplot(data_long, "Mean_Amp", ggtheme = theme_bw()) +
  facet_grid(Centrality~ Laterality, labeller = "label_both")

# REPEARTED MEASURES ANOVA ####

# 3X2 REPEAT MEASURES ANOVA WITH PARTIAL ETA SQUARAED EFFECT SIZE 
res.aov <- anova_test(
  data = data_long, dv = Mean_Amp, wid = Participants,
  within = c(Centrality, Laterality),
  effect.size ="pes"
)
get_anova_table(res.aov)

#SAME AS ABOVE BUT OUTPUTS GENERALIZED ETD SQUARED EFFECT SIZE 
res.aov <- anova_test(
  data = data_long, dv = Mean_Amp, wid = Participants,
  within = c(Centrality, Laterality),
  effect.size ="ges"
)
get_anova_table(res.aov)

#SELECT THE FRONTAL DATA ONLY AND RUN A ONE WAY WITHIN SUBJECT ANOVA 
front_data = filter(data_long,data_long$Centrality=="Frontal")
front.aov <- anova_test(
  data = front_data, dv = Mean_Amp, wid = Participants,
  within = c(Laterality),
  effect.size ="pes"
)
get_anova_table(front.aov)

#SELECT THE CENTRAL DATA ONLY AND RUN A ONE WAY WITHIN SUBJECT ANOVA
cent_data = filter(data_long,data_long$Centrality=="Central")
cent.aov <- anova_test(
  data = cent_data, dv = Mean_Amp, wid = Participants,
  within = c(Laterality),
  effect.size ="pes"
)
get_anova_table(cent.aov)


#TEST OF NORMALITY ON THE AVERAGE ACROSS ALL CONDITIONS
shapiro.test(data$diff_avg)
#TEST AVERAGES AGINST 0 AKA NO DIFFERNENCE BETWEEN CONDITIONS USING PARAMETEITC AND NON_PARAMETIC TEST 
t.test(data$diff_avg, mu = 0, alternative = "two.sided")
wilcox.test(data$diff_avg, mu = 0, alternative = "two.sided",conf.int = TRUE)


#TEST OF NORMALITY ON THE AVERAGE ACROSS CENTRAL CONDITIONS 
shapiro.test(data$cent_diff_avg)

#TEST AVERAGES AGINST 0 AKA NO DIFFERNENCE BETWEEN CONDITIONS USING PARAMETEITC AND NON_PARAMETIC TEST 
t.test(data$cent_diff_avg, mu = 0, alternative = "two.sided")
wilcox.test(data$cent_diff_avg, mu = 0, alternative = "two.sided", conf.int = TRUE)

# FRONT DATA POST HOC TEST ####

# PAIRWISE COMPARISON OF THE FRONTAL DATA 

left_data  = front_data %>% filter(Laterality =="Left")
mid_data   = front_data %>% filter(Laterality =="Midline")
right_data = front_data %>% filter(Laterality =="Right")

d1 <- left_data$Mean_Amp- mid_data$Mean_Amp
d2 <- left_data$Mean_Amp - right_data$Mean_Amp
d3 <- mid_data$Mean_Amp - right_data$Mean_Amp   

# Shapiro-Wilk normality test for the differences
shapiro.test(d1)
shapiro.test(d2) 
shapiro.test(d3)

t.test(mid_data$Mean_Amp ,left_data$Mean_Amp, paired = TRUE, alternative = "two.sided")
t.test(left_data$Mean_Amp, right_data$Mean_Amp , paired = TRUE, alternative = "two.sided")
t.test(mid_data$Mean_Amp ,right_data$Mean_Amp , paired = TRUE, alternative = "two.sided")


# PLOTIING ####

tiff("indi_amps2.tiff", units="in", width=5, height=3, res=600)

bxplt = ggplot(data_long, aes(x = Centrality,y = Mean_Amp,fill = Centrality)) +
  geom_boxplot() +
  geom_jitter(width = 0.15)+
  labs( y = expression(paste("Amplitude (", mu, "v)")))+
  facet_grid(cols = vars(Laterality))+
  scale_fill_grey(start=0.33)+
  theme ( axis.text.y  = element_text(size=14),
          axis.text.x  = element_text(size=14),
          #axis.title.x = element_text(size=18),
          axis.title.y = element_text(size=18),
          strip.text.x = element_text(size=14),
          legend.position  = "none")
bxplt
dev.off()

  
