suppressMessages({
  library(ggplot2); library(dplyr); library(tidyr); library(scales)
  library(patchwork); library(ragg); library(ggrepel)
})
TEMP <- "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"
TAB  <- "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/output/tables"
OUT  <- "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/output/figures"
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

## ---- nature-figure theme + restrained palette ----
theme_pub <- theme_classic(base_size = 8) +
  theme(axis.line = element_line(linewidth = 0.35, colour = "grey20"),
        axis.ticks = element_line(linewidth = 0.35, colour = "grey20"),
        plot.title = element_text(size = 9, face = "bold"),
        plot.subtitle = element_text(size = 7, colour = "grey35"),
        legend.key.size = unit(3.2, "mm"),
        legend.position = "top",
        panel.grid = element_blank())
theme_set(theme_pub)
TEAL<-"#1f6f6f"; AMBER<-"#d98c3a"; CORAL<-"#b8473f"; SLATE<-"#46566b"; GREY<-"#9aa3ad"
savefig <- function(p, name, w=120, h=85){
  svglite::svglite(file.path(OUT,paste0(name,".svg")), width=w/25.4, height=h/25.4); print(p); dev.off()
  agg_png(file.path(OUT,paste0(name,".png")), width=w, height=h, units="mm", res=300); print(p); dev.off()
  agg_tiff(file.path(OUT,paste0(name,".tiff")), width=w, height=h, units="mm", res=600, compression="lzw"); print(p); dev.off()
}

## ===== F1: internet-use prevalence trend (framing break at 2020) =====
d1 <- data.frame(year=c(2011,2013,2015,2018,2020),
                 prev=c(2.8,4.2,6.9,13.4,40.7),
                 frame=c(rep("Social-activity item",4),"Dedicated question (2020)"))
F1 <- ggplot(d1, aes(year, prev, group=1))+
  geom_line(linewidth=0.5, colour=SLATE)+
  geom_point(aes(colour=frame), size=2.2)+
  geom_text(aes(label=paste0(prev,"%")), vjust=-0.9, size=2.5, colour="grey25")+
  scale_colour_manual(values=c("Social-activity item"=TEAL,"Dedicated question (2020)"=CORAL), name=NULL)+
  scale_x_continuous(breaks=d1$year)+ ylim(0,48)+
  labs(title="A  Internet use among adults 45+ , CHARLS 2011-2020",
       subtitle="2020 uses a different (dedicated) instrument - a measurement break, treated as supplementary",
       x=NULL, y="Prevalence (%)")
savefig(F1,"F1_internet_trend",120,80)

## ===== F2 (HERO): concentration index by wave x outcome =====
ci <- read.csv(file.path(TAB,"ci_bywave.csv"))
ci$outcome <- recode(ci$outcome, checkup="Preventive checkup", outpatient="Outpatient", inpatient="Inpatient")
ci$outcome <- factor(ci$outcome, levels=c("Preventive checkup","Outpatient","Inpatient"))
F2 <- ggplot(ci, aes(year, errCI, colour=outcome, group=outcome))+
  geom_hline(yintercept=0, linewidth=0.3, colour="grey70")+
  geom_ribbon(aes(ymin=errCI-1.96*se, ymax=errCI+1.96*se, fill=outcome), alpha=0.12, colour=NA)+
  geom_line(linewidth=0.6)+ geom_point(size=2)+
  scale_colour_manual(values=c(TEAL,AMBER,CORAL), name=NULL)+
  scale_fill_manual(values=c(TEAL,AMBER,CORAL), guide="none")+
  scale_x_continuous(breaks=c(2011,2013,2015,2018))+
  labs(title="B  Pro-rich inequality in healthcare access (Erreygers CI)",
       subtitle="CI > 0 = concentrated among higher-SES; checkup inequality strongest and narrowing",
       x=NULL, y="Erreygers concentration index")
savefig(F2,"F2_ci_trend",120,85)

## ===== F3: decomposition of checkup CI - contributors (2018) =====
dec <- read.csv(file.path(TAB,"decomp_wave.csv"))
d3 <- dec %>% filter(year==2018) %>%
  mutate(lab=recode(regressor, "internet_use"="Internet use", "iu_dfii"="Internet x DFII",
                    "edu"="Education", "ln_gdppc"="Regional GDP", "pension"="Pension",
                    "ln_doctors"="Doctor density", "dfii"="Regional DFII", "chronic"="Chronic disease",
                    "age"="Age", "ins"="Insurance", "total_cognitio"="Cognition", "total_cognition"="Cognition",
                    "rural"="Rural", "gender"="Sex", "marry"="Marital", "adlab_c"="ADL", "iadl"="IADL"),
         digital=regressor %in% c("internet_use","iu_dfii")) %>%
  arrange(share)
d3$lab <- factor(d3$lab, levels=d3$lab)
F3 <- ggplot(d3, aes(share*100, lab, fill=digital))+
  geom_col(width=0.7)+
  geom_vline(xintercept=0, linewidth=0.3, colour="grey60")+
  scale_fill_manual(values=c("FALSE"=GREY,"TRUE"=TEAL), labels=c("Other","Digital (internet)"), name=NULL)+
  labs(title="C  What drives checkup inequality? (2018 decomposition)",
       subtitle="Internet's main term contributes 25%, offset by the interaction; net digital ~12%",
       x="Contribution to concentration index (%)", y=NULL)
savefig(F3,"F3_decomp",120,85)

## ===== F4: marginal effect of internet on checkup by DFII =====
mg <- read.csv(file.path(TEMP,"margins_fig5.csv"))
F4 <- ggplot(mg, aes(dfii_c, estimate))+
  geom_hline(yintercept=0, linewidth=0.3, colour="grey70", linetype=2)+
  geom_ribbon(aes(ymin=min95, ymax=max95), alpha=0.15, fill=TEAL)+
  geom_line(linewidth=0.6, colour=TEAL)+
  labs(title="D  Internet's effect on checkup weakens as regional DFII rises",
       subtitle="Marginal effect of internet use; geographic moderation (interaction -0.085***)",
       x="Regional DFII (standardised)", y="dY/d(internet use)")
savefig(F4,"F4_margins",120,80)

## ===== F5: cross-level equity test (forest) =====
d5 <- data.frame(
  lab=c("Low-DFII regions: digital share","High-DFII regions: digital share",
        "Difference (high - low)","Continuous interaction contribution"),
  est=c(0.087,0.107,0.019,-0.044),
  lo =c(NA,NA,-0.105,-0.159), hi=c(NA,NA,0.109,0.040),
  type=c("Stratum","Stratum","Test","Test"))
d5$lab <- factor(d5$lab, levels=rev(d5$lab))
F5 <- ggplot(d5, aes(est, lab, colour=type))+
  geom_vline(xintercept=0, linetype=2, colour="grey70", linewidth=0.3)+
  geom_errorbarh(aes(xmin=lo, xmax=hi), height=0.18, na.rm=TRUE, linewidth=0.5)+
  geom_point(size=2.4)+
  scale_colour_manual(values=c("Stratum"=SLATE,"Test"=CORAL), guide="none")+
  scale_x_continuous(limits=c(-0.20, 0.17), breaks=c(-0.1,0,0.1))+
  labs(title="E  Cross-level equity test: not significant",
       subtitle="Difference not significant (p = 0.18-0.32)",
       x="Erreygers contribution share / difference", y=NULL)
savefig(F5,"F5_crosslevel",135,72)

## ===== F6: mechanisms (attenuation) =====
d6 <- data.frame(channel=c("Social participation","Consumption","Physical activity","Depression"),
                 share=c(20.8,7.9,7.7,1.1))
d6$channel <- factor(d6$channel, levels=rev(d6$channel))
F6 <- ggplot(d6, aes(share, channel))+
  geom_col(width=0.66, fill=TEAL)+
  geom_text(aes(label=paste0(share,"%")), hjust=-0.15, size=2.6, colour="grey25")+
  xlim(0,25)+
  labs(title="F  Channels: coefficient attenuation of internet->checkup",
       subtitle="Exploratory (not causal mediation); social participation dominant",
       x="Attenuation of internet coefficient (%)", y=NULL)
savefig(F6,"F6_mechanisms",120,62)

## ===== Composite main figure =====
comp <- (F2 | F3) / (F4 | F5) + plot_annotation(theme=theme(plot.margin=margin(2,2,2,2)))
svglite::svglite(file.path(OUT,"MAIN_composite.svg"), width=200/25.4, height=170/25.4); print(comp); dev.off()
agg_png(file.path(OUT,"MAIN_composite.png"), width=200, height=170, units="mm", res=300); print(comp); dev.off()

cat("FIGURES DONE ->", OUT, "\n"); cat(list.files(OUT), sep="\n")
