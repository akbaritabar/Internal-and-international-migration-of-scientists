###############################################################################
# Supplementary Code for PNAS Paper                                           #
# Title: Global Subnational Estimates of Migration of Scientists              #
#        Reveal Large Disparities in Internal and International Flows         #
#                                                                             #
# Author:  Maciej J. Danko                                                    #
# Affiliation: Max Planck Institute for Demographic Research                  #
# Contact: danko@demogr.mpg.de | maciej.danko@gmail.com                       #
# Date: 2025-01-30                                                            #
###############################################################################

###############################################################################
# Kendall correlation                                                         #
###############################################################################

# additional World Bank variable for SI
# you can select vari from c('income','SE.XPD.TOTL.GB.ZS','NY.GDP.PCAP.KD',
# 'NY.GDP.PCAP.CD','SL.UEM.TOTL.ZS','SL.UEM.TOTL.NE.ZS','SL.UEM.ADVN.ZS',
# 'SE.XPD.TERT.ZS','SE.XPD.TOTL.GB.ZS','IC.LGL.CRED.XQ','SI.POV.GINI')
vari <- 'income'

imm_kendall_v12<-prepare_plot(K_IN_Total_in, 
                              K_INT_Total_in, 
                              variable='continent', 
                              name_est='kendall.cor', 
                              name_var='kendall.var',
                              reverse = FALSE, 
                              show.fit= FALSE, 
                              xlim=c(-1,1), ylim=c(-1,1))
closeAllConnections(); g<-gc()

emi_kendall_v12<-prepare_plot(K_IN_Total_out, 
                              K_INT_Total_out, 
                              variable='continent', 
                              name_est='kendall.cor', 
                              name_var='kendall.var',
                              reverse = FALSE, 
                              show.fit= FALSE, 
                              xlim=c(-1,1), ylim=c(-1,1))
closeAllConnections(); g<-gc()

kendall_INvsINT_v12<-prepare_plot(K_INvsINT_out_rate, 
                                  K_INvsINT_in_rate, 
                                  variable='continent', 
                                  name_est='kendall.cor', 
                                  name_var='kendall.var',
                                  reverse = FALSE, 
                                  show.fit= FALSE,
                                  xlim=c(-1,1), ylim=c(-1,1))
closeAllConnections(); g<-gc()

kendall_INvsINT_v12_income<-prepare_plot(K_INvsINT_out_rate, 
                                         K_INvsINT_in_rate, 
                                         variable=paste0('cat_',vari), 
                                         name_est='kendall.cor', 
                                         name_var='kendall.var',
                                         reverse = FALSE, 
                                         show.fit= FALSE, 
                                         xlim=c(-1,1), ylim=c(-1,1))
closeAllConnections(); g<-gc()

suppressWarnings(dir.create('./figPNAS25'))

# Immigration continent 
pdf(file='./figPNAS25/ImmigrationRate_Kendall_MultipleModels_PanelPlot_continent_v12.pdf', 8,6.1)
par(mfrow=c(2,3),oma=c(4.1,3.9,0.5,1),mar=c(0.8,1,2,0.1))
Plot_Multi_Panel(plot_object = imm_kendall_v12,
                 ylab =" ",
                 xlab =" ",
                 add_quart_fraq = TRUE, 
                 xlim=c(-1,1), 
                 ylim=c(-1,1)
)
par(mfrow=c(1,1),oma=c(2.8,2.3,0,0.55))
mtext("Internal", side = 2, line = 2.5, cex = 0.9, font = 2)  # Bold top line
mtext("Kendall correlation coefficients for in-migration rate time trends", side = 2, line = 1.7, cex = 0.9)  # Regular bottom line
mtext("International", side = 1, line = 1.8, cex = 0.9, font = 2)  # Bold top line
mtext("Kendall correlation coefficients for in-migration rate time trends", side = 1, line = 2.6, cex = 0.9)
dev.off()

# Emigration continent 
pdf(file='./figPNAS25/EmigrationRate_Kendall_MultipleModels_PanelPlot_continent_v12.pdf', 8,6.1)
par(mfrow=c(2,3),oma=c(4.1,3.9,0.5,1),mar=c(0.8,1,2,0.1))
Plot_Multi_Panel(plot_object = emi_kendall_v12,
                 add_quart_fraq = TRUE,
                 ylab =" ",
                 xlab =" ",
                 xlim=c(-1,1), 
                 ylim=c(-1,1)
)

par(mfrow=c(1,1),oma=c(2.8,2.3,0,0.55))
mtext("Internal", side = 2, line = 2.5, cex = 0.9, font = 2)  # Bold top line
mtext("Kendall correlation coefficients for out-migration rate time trends", side = 2, line = 1.7, cex = 0.9)  # Regular bottom line
mtext("International", side = 1, line = 1.8, cex = 0.9, font = 2)  # Bold top line
mtext("Kendall correlation coefficients for out-migration rate time trends", side = 1, line = 2.6, cex = 0.9)
dev.off()

# INvsINT continent 
pdf(file='./figPNAS25/FIG4_Immi-Emi-grationRates_INvsINT_Kendall_MultipleModels_PanelPlot_continent_v12.pdf', 8,6.1)
par(mfrow=c(2,3),oma=c(4.1,3.9,0.5,1),mar=c(0.8,1,2,0.1))
Plot_Multi_Panel(plot_object = kendall_INvsINT_v12,
                 add_quart_fraq = TRUE,
                 xlim=c(-1,1), ylim=c(-1,1),
                 ylab =" ",
                 xlab =" "#,
                 #xlab='Out-migration',ylab='In-migration'
)
par(mfrow=c(1,1),oma=c(2.8,2.3,0,0.55))
mtext("In-migration", side = 2, line = 2.5, cex = 0.9, font = 2)  # Bold top line
mtext("Kendall rank correlation coefficients between internal and international trends", side = 2, line = 1.7, cex = 0.9)  # Regular bottom line
mtext("Out-migration", side = 1, line = 1.8, cex = 0.9, font = 2)  # Bold top line
mtext("Kendall rank correlation coefficients between internal and international trends", side = 1, line = 2.6, cex = 0.9)
dev.off()
#Kendall rank correlation coefficients between internal and international trends

# INvsINT income 
pdf(file=paste0('./figPNAS25/FIG4_ALTERNATIVE_Immi-Emi-grationRates_INvsINT_Kendall_MultipleModels_PanelPlot_',vari,'_v12.pdf'), 6.1,6.1)
par(mfrow=c(2,2),oma=c(3.9,3.4,0.5,1),mar=c(0.8,1,2,0.1))
Plot_Multi_Panel(plot_object = kendall_INvsINT_v12_income,
                 add_quart_fraq = TRUE,
                 xlim=c(-1,1), 
                 ylim=c(-1,1),
                 ylab =" ",
                 xlab =" ",
                 remove.xax=c(1,1,0,0), 
                 remove.yax=c(0,1,0,1)#,
                 #xlab='Out-migration',ylab='In-migration'
)
par(mfrow=c(1,1),oma=c(3.1,2.7,0,0.8))
mtext("In-migration", side = 2, line = 2.9, cex = 0.9, font = 2)  # Bold top line
mtext("Kendall rank correlation coefficients between internal and international trends", side = 2, line = 2.1, cex = 0.9)  # Regular bottom line
mtext("Out-migration", side = 1, line = 1.9, cex = 0.9, font = 2)  # Bold top line
mtext("Kendall rank correlation coefficients between internal and international trends", side = 1, line = 2.7, cex = 0.9)
dev.off()