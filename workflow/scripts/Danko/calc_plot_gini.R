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

top_text<-function(label, size=0.1, lwd=2, font=2, col=1, border=1, fill=0, boxtype=0){
  usr<-par('usr')
  rect(usr[1],usr[4],usr[2],usr[4]+size*diff(usr[3:4]),xpd=TRUE,lwd=lwd, col=fill, border=border)
  text(x=usr[1]+diff(usr[1:2])/2, y=usr[4]+size*diff(usr[3:4])/2,adj=c(0.5,0.5), 
       labels=label, xpd=TRUE, font = font, col=col)
  if (boxtype==1) box() else
    if (boxtype==2) rect(usr[1],usr[3],usr[2],usr[4]+size*diff(usr[3:4])*0.9999,lwd=lwd, border=1, xpd=TRUE) else
      if (boxtype!=0) stop()
}

MINY<-min(DataNoThresh$year)

wGini_Asia_in_IN<-sapply(sort(unique(DT_Asia$year)), function(y) 
  DescTools::Gini(DT_Asia$rate_in_internal[DT_Asia$year==y],
                  weights = DT_Asia$pop_internal[DT_Asia$year==y]))
wGini_Asia_out_IN<-sapply(sort(unique(DT_Asia$year)), function(y) 
  DescTools::Gini(DT_Asia$rate_out_internal[DT_Asia$year==y],
                  weights = DT_Asia$pop_internal[DT_Asia$year==y]))
wGini_Asia_in_INT<-sapply(sort(unique(DT_Asia$year)), function(y) 
  DescTools::Gini(DT_Asia$rate_in_international[DT_Asia$year==y],
                  weights = DT_Asia$pop_internal[DT_Asia$year==y]))
wGini_Asia_out_INT<-sapply(sort(unique(DT_Asia$year)), function(y) 
  DescTools::Gini(DT_Asia$rate_out_international[DT_Asia$year==y],
                  weights = DT_Asia$pop_internal[DT_Asia$year==y]))

wGini_Asia_in_ININT<-sapply(sort(unique(DT_Asia$year)), function(y) 
  DescTools::Gini(DT_Asia$rate_in_internal[DT_Asia$year==y] + 
                    DT_Asia$rate_in_international[DT_Asia$year==y],
                  weights = DT_Asia$pop_internal[DT_Asia$year==y]))
wGini_Asia_out_ININT<-sapply(sort(unique(DT_Asia$year)), function(y) 
  DescTools::Gini(DT_Asia$rate_out_internal[DT_Asia$year==y] + 
                    DT_Asia$rate_out_international[DT_Asia$year==y],
                  weights = DT_Asia$pop_internal[DT_Asia$year==y]))

wGini_Africa_in_IN<-sapply(sort(unique(DT_Africa$year)), function(y) 
  DescTools::Gini(DT_Africa$rate_in_internal[DT_Africa$year==y],
                  weights = DT_Africa$pop_internal[DT_Africa$year==y]))
wGini_Africa_out_IN<-sapply(sort(unique(DT_Africa$year)), function(y) 
  DescTools::Gini(DT_Africa$rate_out_internal[DT_Africa$year==y],
                  weights = DT_Africa$pop_internal[DT_Africa$year==y]))
wGini_Africa_in_INT<-sapply(sort(unique(DT_Africa$year)), function(y) 
  DescTools::Gini(DT_Africa$rate_in_international[DT_Africa$year==y],
                  weights = DT_Africa$pop_internal[DT_Africa$year==y]))
wGini_Africa_out_INT<-sapply(sort(unique(DT_Africa$year)), function(y) 
  DescTools::Gini(DT_Africa$rate_out_international[DT_Africa$year==y],
                  weights = DT_Africa$pop_internal[DT_Africa$year==y]))

wGini_Africa_in_ININT<-sapply(sort(unique(DT_Africa$year)), function(y) 
  DescTools::Gini(DT_Africa$rate_in_internal[DT_Africa$year==y] + 
                    DT_Africa$rate_in_international[DT_Africa$year==y],
                  weights = DT_Africa$pop_internal[DT_Africa$year==y]))
wGini_Africa_out_ININT<-sapply(sort(unique(DT_Africa$year)), function(y) 
  DescTools::Gini(DT_Africa$rate_out_internal[DT_Africa$year==y] + 
                    DT_Africa$rate_out_international[DT_Africa$year==y],
                  weights = DT_Africa$pop_internal[DT_Africa$year==y]))

wGini_Europe_in_IN<-sapply(sort(unique(DT_Europe$year)), function(y) 
  DescTools::Gini(DT_Europe$rate_in_internal[DT_Europe$year==y],
                  weights = DT_Europe$pop_internal[DT_Europe$year==y]))
wGini_Europe_out_IN<-sapply(sort(unique(DT_Europe$year)), function(y) 
  DescTools::Gini(DT_Europe$rate_out_internal[DT_Europe$year==y],
                  weights = DT_Europe$pop_internal[DT_Europe$year==y]))
wGini_Europe_in_INT<-sapply(sort(unique(DT_Europe$year)), function(y) 
  DescTools::Gini(DT_Europe$rate_in_international[DT_Europe$year==y],
                  weights = DT_Europe$pop_internal[DT_Europe$year==y]))
wGini_Europe_out_INT<-sapply(sort(unique(DT_Europe$year)), function(y) 
  DescTools::Gini(DT_Europe$rate_out_international[DT_Europe$year==y],
                  weights = DT_Europe$pop_internal[DT_Europe$year==y]))

wGini_Europe_in_ININT<-sapply(sort(unique(DT_Europe$year)), function(y) 
  DescTools::Gini(DT_Europe$rate_in_internal[DT_Europe$year==y] + 
                    DT_Europe$rate_in_international[DT_Europe$year==y],
                  weights = DT_Europe$pop_internal[DT_Europe$year==y]))
wGini_Europe_out_ININT<-sapply(sort(unique(DT_Europe$year)), function(y) 
  DescTools::Gini(DT_Europe$rate_out_internal[DT_Europe$year==y] + 
                    DT_Europe$rate_out_international[DT_Europe$year==y],
                  weights = DT_Europe$pop_internal[DT_Europe$year==y]))

wGini_NA_in_IN<-sapply(sort(unique(DT_NA$year)), function(y) 
  DescTools::Gini(DT_NA$rate_in_internal[DT_NA$year==y],
                  weights = DT_NA$pop_internal[DT_NA$year==y]))
wGini_NA_out_IN<-sapply(sort(unique(DT_NA$year)), function(y) 
  DescTools::Gini(DT_NA$rate_out_internal[DT_NA$year==y],
                  weights = DT_NA$pop_internal[DT_NA$year==y]))
wGini_NA_in_INT<-sapply(sort(unique(DT_NA$year)), function(y) 
  DescTools::Gini(DT_NA$rate_in_international[DT_NA$year==y],
                  weights = DT_NA$pop_internal[DT_NA$year==y]))
wGini_NA_out_INT<-sapply(sort(unique(DT_NA$year)), function(y) 
  DescTools::Gini(DT_NA$rate_out_international[DT_NA$year==y],
                  weights = DT_NA$pop_internal[DT_NA$year==y]))

wGini_NA_in_ININT<-sapply(sort(unique(DT_NA$year)), function(y) 
  DescTools::Gini(DT_NA$rate_in_internal[DT_NA$year==y] + 
                    DT_NA$rate_in_international[DT_NA$year==y],
                  weights = DT_NA$pop_internal[DT_NA$year==y]))
wGini_NA_out_ININT<-sapply(sort(unique(DT_NA$year)), function(y) 
  DescTools::Gini(DT_NA$rate_out_internal[DT_NA$year==y] + 
                    DT_NA$rate_out_international[DT_NA$year==y],
                  weights = DT_NA$pop_internal[DT_NA$year==y]))

wGini_SA_in_IN<-sapply(sort(unique(DT_SA$year)), function(y) 
  DescTools::Gini(DT_SA$rate_in_internal[DT_SA$year==y],
                  weights = DT_SA$pop_internal[DT_SA$year==y]))
wGini_SA_out_IN<-sapply(sort(unique(DT_SA$year)), function(y) 
  DescTools::Gini(DT_SA$rate_out_internal[DT_SA$year==y],
                  weights = DT_SA$pop_internal[DT_SA$year==y]))
wGini_SA_in_INT<-sapply(sort(unique(DT_SA$year)), function(y) 
  DescTools::Gini(DT_SA$rate_in_international[DT_SA$year==y],
                  weights = DT_SA$pop_internal[DT_SA$year==y]))
wGini_SA_out_INT<-sapply(sort(unique(DT_SA$year)), function(y) 
  DescTools::Gini(DT_SA$rate_out_international[DT_SA$year==y],
                  weights = DT_SA$pop_internal[DT_SA$year==y]))

wGini_SA_in_ININT<-sapply(sort(unique(DT_SA$year)), function(y) 
  DescTools::Gini(DT_SA$rate_in_internal[DT_SA$year==y] + 
                    DT_SA$rate_in_international[DT_SA$year==y],
                  weights = DT_SA$pop_internal[DT_SA$year==y]))
wGini_SA_out_ININT<-sapply(sort(unique(DT_SA$year)), function(y) 
  DescTools::Gini(DT_SA$rate_out_internal[DT_SA$year==y] + 
                    DT_SA$rate_out_international[DT_SA$year==y],
                  weights = DT_SA$pop_internal[DT_SA$year==y]))

wGini_Oceania_in_IN<-sapply(sort(unique(DT_Oceania$year)), function(y) 
  DescTools::Gini(DT_Oceania$rate_in_internal[DT_Oceania$year==y],
                  weights = DT_Oceania$pop_internal[DT_Oceania$year==y]))
wGini_Oceania_out_IN<-sapply(sort(unique(DT_Oceania$year)), function(y) 
  DescTools::Gini(DT_Oceania$rate_out_internal[DT_Oceania$year==y],
                  weights = DT_Oceania$pop_internal[DT_Oceania$year==y]))
wGini_Oceania_in_INT<-sapply(sort(unique(DT_Oceania$year)), function(y) 
  DescTools::Gini(DT_Oceania$rate_in_international[DT_Oceania$year==y],
                  weights = DT_Oceania$pop_internal[DT_Oceania$year==y]))
wGini_Oceania_out_INT<-sapply(sort(unique(DT_Oceania$year)), function(y) 
  DescTools::Gini(DT_Oceania$rate_out_international[DT_Oceania$year==y],
                  weights = DT_Oceania$pop_internal[DT_Oceania$year==y]))

wGini_Oceania_in_ININT<-sapply(sort(unique(DT_Oceania$year)), function(y) 
  DescTools::Gini(DT_Oceania$rate_in_internal[DT_Oceania$year==y] + 
                    DT_Oceania$rate_in_international[DT_Oceania$year==y],
                  weights = DT_Oceania$pop_internal[DT_Oceania$year==y]))
wGini_Oceania_out_ININT<-sapply(sort(unique(DT_Oceania$year)), function(y) 
  DescTools::Gini(DT_Oceania$rate_out_internal[DT_Oceania$year==y] + 
                    DT_Oceania$rate_out_international[DT_Oceania$year==y],
                  weights = DT_Oceania$pop_internal[DT_Oceania$year==y]))

################################################################################
suppressWarnings(dir.create('./figPNAS25'))

pdf(file='./figPNAS25/FIG2_GINI_by_region_v12.pdf', 8,6.1)
c_red<-'#f36f83'; c_blue<-'#1550b0'; c_yellow<-'#d79a20'; c_green<-'#006b00';
PAL<-c("#1B9E77FF", "#D95F02FF", "#7570B3FF", "#E7298AFF", "#2297E6FF", "#E6AB02FF")
par(mfrow=c(2,3),oma=c(2.8,4.7,0.5,1),mar=c(0.8,1,2,0.1))
Y<-seq_along(wGini_Africa_in_IN)-1+MINY
LegPos<-'topright'

plot(Y,wGini_Africa_in_IN, type='l', ylim=c(0,0.8), lwd=2, xaxt='n')
rect(par("usr")[1], par("usr")[3],
     par("usr")[2], par("usr")[4],
     col = "#f2f2f2")
abline(h=seq(0,1,0.2),lty=3, col='darkgray')
lines(Y,wGini_Africa_in_IN, type='l', ylim=c(0,0.8), lwd=2, col=PAL[1])
lines(Y,wGini_Africa_in_INT, type='l', ylim=c(0,0.8), lwd=2, col=PAL[2])
lines(Y,wGini_Africa_in_ININT, type='l', ylim=c(0,0.8), lwd=2, col=PAL[5])
lines(Y,wGini_Africa_out_IN, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[1],lty=2)
lines(Y,wGini_Africa_out_INT, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[2],lty=2)
lines(Y,wGini_Africa_out_ININT, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[5],lty=2)
top_text('Africa', size=0.086, lwd=2, font=2, col=1, border=1, fill=0, boxtype=0)
#mtext('Inequality in migration rates\n(Gini coefficient)',2,2.5)

plot(Y,wGini_Asia_in_IN, type='l', ylim=c(0,0.8), lwd=2, xaxt='n', yaxt='n')
rect(par("usr")[1], par("usr")[3],
     par("usr")[2], par("usr")[4],
     col = "#f2f2f2")
abline(h=seq(0.2,1,0.2),lty=3, col='darkgray')
lines(Y,wGini_Asia_in_IN, type='l', ylim=c(0,0.8), lwd=2, col=PAL[1])
lines(Y,wGini_Asia_in_INT, type='l', ylim=c(0,0.8), lwd=2, col=PAL[2])
lines(Y,wGini_Asia_in_ININT, type='l', ylim=c(0,0.8), lwd=2, col=PAL[5])
lines(Y,wGini_Asia_out_IN, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[1],lty=2)
lines(Y,wGini_Asia_out_INT, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[2],lty=2)
lines(Y,wGini_Asia_out_ININT, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[5],lty=2)
top_text('Asia', size=0.086, lwd=2, font=2, col=1, border=1, fill=0, boxtype=0)

plot(Y,wGini_Europe_in_IN, type='l', ylim=c(0,0.8), lwd=2, xaxt='n', yaxt='n')
rect(par("usr")[1], par("usr")[3],
     par("usr")[2], par("usr")[4],
     col = "#f2f2f2")
abline(h=seq(0.2,1,0.2),lty=3, col='darkgray')
lines(Y,wGini_Europe_in_IN, type='l', ylim=c(0,0.8), lwd=2, col=PAL[1])
lines(Y,wGini_Europe_in_INT, type='l', ylim=c(0,0.8), lwd=2, col=PAL[2])
lines(Y,wGini_Europe_in_ININT, type='l', ylim=c(0,0.8), lwd=2, col=PAL[5])
lines(Y,wGini_Europe_out_IN, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[1],lty=2)
lines(Y,wGini_Europe_out_INT, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[2],lty=2)
lines(Y,wGini_Europe_out_ININT, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[5],lty=2)
legend(LegPos,bty='n',legend=c('Internal migration','International migration',
                               'Internal + international migration','in-migration','out-migration'),
       col=c(PAL[c(1,2,5)], 1,1),lty=c(1,1,1,1,2),lwd=c(2,2,2,2,1.5), ncol=1, cex=0.875)
top_text('Europe', size=0.086, lwd=2, font=2, col=1, border=1, fill=0, boxtype=0)

plot(Y,wGini_NA_in_IN, type='l', ylim=c(0,0.8), lwd=2)
rect(par("usr")[1], par("usr")[3],
     par("usr")[2], par("usr")[4],
     col = "#f2f2f2")
abline(h=seq(0.2,1,0.2),lty=3, col='darkgray')
lines(Y,wGini_NA_in_IN, type='l', ylim=c(0,0.8), lwd=2, col=PAL[1])
lines(Y,wGini_NA_in_INT, type='l', ylim=c(0,0.8), lwd=2, col=PAL[2])
lines(Y,wGini_NA_in_ININT, type='l', ylim=c(0,0.8), lwd=2, col=PAL[5])
lines(Y,wGini_NA_out_IN, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[1],lty=2)
lines(Y,wGini_NA_out_INT, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[2],lty=2)
lines(Y,wGini_NA_out_ININT, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[5],lty=2)
top_text('North America', size=0.086, lwd=2, font=2, col=1, border=1, fill=0, boxtype=0)
#mtext('Inequality in migration rates\n(Gini coefficient)',2,2.5)
#mtext('Year',1,2.5)
plot(Y,wGini_Oceania_in_IN, type='l', ylim=c(0,0.8), lwd=2, yaxt='n')
rect(par("usr")[1], par("usr")[3],
     par("usr")[2], par("usr")[4],
     col = "#f2f2f2")
abline(h=seq(0.2,1,0.2),lty=3, col='darkgray')
lines(Y,wGini_Oceania_in_IN, type='l', ylim=c(0,0.8), lwd=2, col=PAL[1])
lines(Y,wGini_Oceania_in_INT, type='l', ylim=c(0,0.8), lwd=2, col=PAL[2])
lines(Y,wGini_Oceania_in_ININT, type='l', ylim=c(0,0.8), lwd=2, col=PAL[5])
lines(Y,wGini_Oceania_out_IN, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[1],lty=2)
lines(Y,wGini_Oceania_out_INT, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[2],lty=2)
lines(Y,wGini_Oceania_out_ININT, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[5],lty=2)
top_text('Oceania', size=0.086, lwd=2, font=2, col=1, border=1, fill=0, boxtype=0)
mtext('Year',1,2.5)

plot(Y,wGini_SA_in_IN, type='l', ylim=c(0,0.8), lwd=2, yaxt='n')
rect(par("usr")[1], par("usr")[3],
     par("usr")[2], par("usr")[4],
     col = "#f2f2f2")
abline(h=seq(0.2,1,0.2),lty=3, col='darkgray')
lines(Y,wGini_SA_in_IN, type='l', ylim=c(0,0.8), lwd=2, col=PAL[1])
lines(Y,wGini_SA_in_INT, type='l', ylim=c(0,0.8), lwd=2, col=PAL[2])
lines(Y,wGini_SA_in_ININT, type='l', ylim=c(0,0.8), lwd=2, col=PAL[5])
lines(Y,wGini_SA_out_IN, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[1],lty=2)
lines(Y,wGini_SA_out_INT, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[2],lty=2)
lines(Y,wGini_SA_out_ININT, type='l', ylim=c(0,0.8), lwd=1.5, col=PAL[5],lty=2)

top_text('South America', size=0.086, lwd=2, font=2, col=1, border=1, fill=0, boxtype=0)
#mtext('Year',1,2.5)
par(mfrow=c(1,1),oma=c(2.8,2.7,0.5,1),mar=c(0.8,1,2,0.1))

mtext("Gini coefficient", side = 2, line = 2.6, cex = 1, font = 2)  # Bold top line
mtext("Inequality in migration rates", side = 2, line = 1.5, cex = 1)
#mtext('Inequality in migration rates\n(Gini coefficient)',2,1.2)
dev.off()

################################################################################

gini_data_table <- data.frame(
  year = Y,
  wGini_Asia_in_IN = wGini_Asia_in_IN,
  wGini_Asia_out_IN = wGini_Asia_out_IN,
  wGini_Asia_in_INT = wGini_Asia_in_INT,
  wGini_Asia_out_INT = wGini_Asia_out_INT,
  wGini_Asia_in_ININT = wGini_Asia_in_ININT,
  wGini_Asia_out_ININT = wGini_Asia_out_ININT,
  wGini_Africa_in_IN = wGini_Africa_in_IN,
  wGini_Africa_out_IN = wGini_Africa_out_IN,
  wGini_Africa_in_INT = wGini_Africa_in_INT,
  wGini_Africa_out_INT = wGini_Africa_out_INT,
  wGini_Africa_in_ININT = wGini_Africa_in_ININT,
  wGini_Africa_out_ININT = wGini_Africa_out_ININT,
  wGini_Europe_in_IN = wGini_Europe_in_IN,
  wGini_Europe_out_IN = wGini_Europe_out_IN,
  wGini_Europe_in_INT = wGini_Europe_in_INT,
  wGini_Europe_out_INT = wGini_Europe_out_INT,
  wGini_Europe_in_ININT = wGini_Europe_in_ININT,
  wGini_Europe_out_ININT = wGini_Europe_out_ININT,
  wGini_NA_in_IN = wGini_NA_in_IN,
  wGini_NA_out_IN = wGini_NA_out_IN,
  wGini_NA_in_INT = wGini_NA_in_INT,
  wGini_NA_out_INT = wGini_NA_out_INT,
  wGini_NA_in_ININT = wGini_NA_in_ININT,
  wGini_NA_out_ININT = wGini_NA_out_ININT,
  wGini_SA_in_IN = wGini_SA_in_IN,
  wGini_SA_out_IN = wGini_SA_out_IN,
  wGini_SA_in_INT = wGini_SA_in_INT,
  wGini_SA_out_INT = wGini_SA_out_INT,
  wGini_SA_in_ININT = wGini_SA_in_ININT,
  wGini_SA_out_ININT = wGini_SA_out_ININT
)

colnames(gini_data_table)<-gsub('_NA_','_NorthAmerica_',colnames(gini_data_table), fixed = TRUE)
colnames(gini_data_table)<-gsub('_SA_','_SouthAmerica_',colnames(gini_data_table), fixed = TRUE)
colnames(gini_data_table)<-gsub('_INT','_international',colnames(gini_data_table), fixed = TRUE)
colnames(gini_data_table)<-gsub('_ININT','_both',colnames(gini_data_table), fixed = TRUE)
colnames(gini_data_table)<-gsub('_IN','_internal',colnames(gini_data_table), fixed = TRUE)
suppressWarnings(dir.create('./tabPNAS25'))

write.table(gini_data_table,'./tabPNAS25/GiniTable_v12.csv',sep=';',dec='.')
openxlsx::write.xlsx(gini_data_table,'./tabPNAS25/GiniTable_v12.xlsx')

