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
# Quasi-Poisson slopes                                                        #
###############################################################################

# additional World Bank variable for SI
# you can select vari from c('income','SE.XPD.TOTL.GB.ZS','NY.GDP.PCAP.KD',
# 'NY.GDP.PCAP.CD','SL.UEM.TOTL.ZS','SL.UEM.TOTL.NE.ZS','SL.UEM.ADVN.ZS',
# 'SE.XPD.TERT.ZS','SE.XPD.TOTL.GB.ZS','IC.LGL.CRED.XQ','SI.POV.GINI')
vari <- 'income'

if (!file.exists('slope_fits_v12.rdat') || Recalcualte_all) {
  start_time <- Sys.time()
  imm_slope_v12<-prepare_plot(p_IN_Total_in, 
                              p_INT_Total_in, 
                              variable='continent', 
                              reverse = FALSE, 
                              name_est='b', 
                              name_var='v',
                              show.fit=TRUE)
  closeAllConnections(); g<-gc()
  
  emi_slope_v12<-prepare_plot(p_IN_Total_out, 
                              p_INT_Total_out,
                              variable='continent', 
                              reverse = FALSE, 
                              name_est='b', 
                              name_var='v',
                              show.fit=TRUE)
  closeAllConnections(); g<-gc()
  
  imm_slope_v12_income<-prepare_plot(p_IN_Total_in, 
                                     p_INT_Total_in, 
                                     variable=paste0('cat_',vari), 
                                     reverse = FALSE, 
                                     name_est='b', 
                                     name_var='v',
                                     show.fit=TRUE)
  closeAllConnections(); g<-gc()
  
  emi_slope_v12_income<-prepare_plot(p_IN_Total_out, 
                                     p_INT_Total_out, 
                                     variable=paste0('cat_',vari), 
                                     reverse = FALSE, 
                                     name_est='b', 
                                     name_var='v',
                                     show.fit=TRUE)
  closeAllConnections(); g<-gc()
  
  save(list=c('imm_slope_v12','emi_slope_v12','imm_slope_v12_income','emi_slope_v12_income'),
       file='slope_fits_v12.rdat')
  end_time <- Sys.time()
  
  duration_hours <- as.numeric(difftime(end_time, start_time, units = "hours"))
  print(duration_hours)
} else {
  load(file='slope_fits_v12.rdat')
}

graphics.off()

suppressWarnings(dir.create('./figPNAS25'))

# Immigration continent signif
pdf(file='./figPNAS25/FIG3_A_ImmigrationRate_Slopes_QuasiPoisson_MultipleModels_PanelPlot_continent_v12_signif.pdf', 8,6.1)
par(mfrow=c(2,3),oma=c(4.1,3.9,0.5,1),mar=c(0.8,1,2,0.1))
Plot_Multi_Panel(plot_object=imm_slope_v12,
                 transform.mult = TRUE,
                 show.naive.fit = FALSE,
                 show.only.signif = TRUE,
                 add_quart_fraq = TRUE,
                 ylab =" ",
                 xlab =" ",
                 CI_Type='solid', COL_CI= "#00000011",
                 shift.y = c(-0.08,0.005,0.005,0.001,-0.05,-0.005),
                 shift.x = c(0.22,-0.03,-0.03,-0.03,0,-0.03))

par(mfrow=c(1,1),oma=c(2.8,2.3,0,0.55))
mtext("Internal", side = 2, line = 2.5, cex = 0.9, font = 2)  # Bold top line
mtext("Annual percentage change in in-migration rates", side = 2, line = 1.7, cex = 0.9)  # Regular bottom line
mtext("International", side = 1, line = 1.8, cex = 0.9, font = 2)  # Bold top line
mtext("Annual percentage change in in-migration rates", side = 1, line = 2.6, cex = 0.9)
dev.off()

# Emigration continent signif
pdf(file='./figPNAS25/FIG3_B_EmigrationRate_Slopes_QuasiPoisson_MultipleModels_PanelPlot_continent_v12_signif.pdf', 8,6.1)
par(mfrow=c(2,3),oma=c(4.1,3.9,0.5,1),mar=c(0.8,1,2,0.1))
Plot_Multi_Panel(plot_object=emi_slope_v12,
                 transform.mult = TRUE,
                 show.naive.fit = FALSE,
                 show.only.signif = TRUE,
                 add_quart_fraq = TRUE,
                 ylab =" ",
                 xlab =" ",
                 CI_Type='solid', COL_CI= "#00000011",
                 shift.y = c(1.0,0.005,0.005,0.005,-0.001,0.005),
                 shift.x = c(-0.416,0.265,0.265,0.265,0.2,0.265))

par(mfrow=c(1,1),oma=c(2.8,2.3,0,0.55))
mtext("Internal", side = 2, line = 2.5, cex = 0.9, font = 2)  # Bold top line
mtext("Annual percentage change in out-migration rates", side = 2, line = 1.7, cex = 0.9)  # Regular bottom line
mtext("International", side = 1, line = 1.8, cex = 0.9, font = 2)  # Bold top line
mtext("Annual percentage change in out-migration rates", side = 1, line = 2.6, cex = 0.9)
dev.off()

# Immigration income signif
pdf(file=paste0('./figPNAS25/FIG3_A_ALTERNATIVE_ImmigrationRate_Slopes_QuasiPoisson_MultipleModels_PanelPlot_',vari,'_v12_signif.pdf'), 6.1,6.1)
par(mfrow=c(2,2),oma=c(3.9,3.4,0.5,1),mar=c(0.8,1,2,0.1))
Plot_Multi_Panel(plot_object=imm_slope_v12_income,
                 transform.mult = TRUE,
                 show.naive.fit = FALSE,
                 add_quart_fraq = TRUE,
                 show.only.signif = TRUE,
                 remove.xax=c(1,1,0,0), 
                 remove.yax=c(0,1,0,1),
                 ylab =" ",
                 xlab =" ",
                 CI_Type='solid', COL_CI= "#00000011",
                 shift.y = c(-0.125,0.15,-0.02,-0.01,-0.005,-0.005),
                 shift.x = c(0.695,-0.9,+0.15,0.03,-0.03,-0.03))

par(mfrow=c(1,1),oma=c(3.1,2.7,0,0.8))
mtext("Internal", side = 2, line = 2.9, cex = 0.9, font = 2)  # Bold top line
mtext("Annual percentage change in in-migration rates", side = 2, line = 2.1, cex = 0.9)  # Regular bottom line
mtext("International", side = 1, line = 1.9, cex = 0.9, font = 2)  # Bold top line
mtext("Annual percentage change in in-migration rates", side = 1, line = 2.7, cex = 0.9)
dev.off()

# Emigration income signif
pdf(file=paste0('./figPNAS25/FIG3_B_ALTERNATIVE_EmigrationRate_Slopes_QuasiPoisson_MultipleModels_PanelPlot_',vari,'_v12_signif.pdf'), 6.1,6.1)
par(mfrow=c(2,2),oma=c(3.9,3.4,0.5,1),mar=c(0.8,1,2,0.1))
Plot_Multi_Panel(plot_object=emi_slope_v12_income,
                 transform.mult = TRUE,
                 show.naive.fit = FALSE,
                 add_quart_fraq = TRUE,
                 show.only.signif = TRUE,
                 remove.xax=c(1,1,0,0), 
                 remove.yax=c(0,1,0,1),
                 ylab =" ",
                 xlab =" ",
                 CI_Type='solid', COL_CI= "#00000011",
                 shift.y = c(-0.09,-0.05,-0.05,-0.05,0.05,0.005),
                 shift.x = c(0.243,0.265,0.355,0.305,0.2,0.265))

par(mfrow=c(1,1),oma=c(3.1,2.7,0,0.8))
mtext("Internal", side = 2, line = 2.9, cex = 0.9, font = 2)  # Bold top line
mtext("Annual percentage change in out-migration rates", side = 2, line = 2.1, cex = 0.9)  # Regular bottom line
mtext("International", side = 1, line = 1.9, cex = 0.9, font = 2)  # Bold top line
mtext("Annual percentage change in out-migration rates", side = 1, line = 2.7, cex = 0.9)
dev.off()


