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
print('!')
DT_Oceania_in_IN <- remove_short_series_NA('IN','imm',DT_Oceania)
DT_Oceania_in_INT <- remove_short_series_NA('INT','imm',DT_Oceania)
DT_Oceania_out_IN <- remove_short_series_NA('IN','emi',DT_Oceania)
DT_Oceania_out_INT <- remove_short_series_NA('INT','emi',DT_Oceania)

DT_Africa_in_IN <- remove_short_series_NA('IN','imm',DT_Africa)
DT_Africa_in_INT <- remove_short_series_NA('INT','imm',DT_Africa)
DT_Africa_out_IN <- remove_short_series_NA('IN','emi',DT_Africa)
DT_Africa_out_INT <- remove_short_series_NA('INT','emi',DT_Africa)

DT_NA_in_IN <- remove_short_series_NA('IN','imm',DT_NA)
DT_NA_in_INT <- remove_short_series_NA('INT','imm',DT_NA)
DT_NA_out_IN <- remove_short_series_NA('IN','emi',DT_NA)
DT_NA_out_INT <- remove_short_series_NA('INT','emi',DT_NA)

DT_SA_in_IN <- remove_short_series_NA('IN','imm',DT_SA)
DT_SA_in_INT <- remove_short_series_NA('INT','imm',DT_SA)
DT_SA_out_IN <- remove_short_series_NA('IN','emi',DT_SA)
DT_SA_out_INT <- remove_short_series_NA('INT','emi',DT_SA)

DT_Asia_in_IN <- remove_short_series_NA('IN','imm',DT_Asia)
DT_Asia_in_INT <- remove_short_series_NA('INT','imm',DT_Asia)
DT_Asia_out_IN <- remove_short_series_NA('IN','emi',DT_Asia)
DT_Asia_out_INT <- remove_short_series_NA('INT','emi',DT_Asia)

DT_Europe_in_IN <- remove_short_series_NA('IN','imm',DT_Europe)
DT_Europe_in_INT <- remove_short_series_NA('INT','imm',DT_Europe)
DT_Europe_out_IN <- remove_short_series_NA('IN','emi',DT_Europe)
DT_Europe_out_INT <- remove_short_series_NA('INT','emi',DT_Europe)


if (file.exists('models_fs_Oceania_v12.RDA') && !Recalcualte_all) load('models_fs_Oceania_v12.RDA') else {
  try({model_Oceania_in_IN=mgcv::bam(in_internal ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Oceania_in_IN, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_Oceania_in_INT=mgcv::bam(in_international ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Oceania_in_INT, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_Oceania_out_IN=mgcv::bam(out_internal ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Oceania_in_IN, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_Oceania_out_INT=mgcv::bam(out_international ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Oceania_in_INT, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  save(list=ls()[grep('Oceania',ls())], file='models_fs_Oceania_v12.RDA')
  })
}

if (file.exists('models_fs_Africa_v12.RDA') && !Recalcualte_all) load('models_fs_Africa_v12.RDA') else {
  try({
    model_Africa_in_IN=mgcv::bam(in_internal ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Africa_in_IN, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
    model_Africa_in_INT=mgcv::bam(in_international ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Africa_in_INT, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
    model_Africa_out_IN=mgcv::bam(out_internal ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Africa_in_IN, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
    model_Africa_out_INT=mgcv::bam(out_international ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Africa_in_INT, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
    save(list=ls()[grep('Africa',ls())], file='models_fs_Africa_v12.RDA')
  })
}

if (file.exists('models_fs_Europe_v12.RDA') && !Recalcualte_all) load('models_fs_Europe_v12.RDA') else {
  try({model_Europe_in_IN=mgcv::bam(in_internal ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Europe_in_IN, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_Europe_in_INT=mgcv::bam(in_international ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Europe_in_INT, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_Europe_out_IN=mgcv::bam(out_internal ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Europe_in_IN, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_Europe_out_INT=mgcv::bam(out_international ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Europe_in_INT, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  save(list=ls()[grep('Europe',ls())], file='models_fs_Europe_v12.RDA')
  })
}

if (file.exists('models_fs_Asia_v12.RDA') && !Recalcualte_all) load('models_fs_Asia_v12.RDA') else {
  try({model_Asia_in_IN=mgcv::bam(in_internal ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Asia_in_IN, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_Asia_in_INT=mgcv::bam(in_international ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Asia_in_INT, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_Asia_out_IN=mgcv::bam(out_internal ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Asia_in_IN, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_Asia_out_INT=mgcv::bam(out_international ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_Asia_in_INT, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  save(list=ls()[grep('Asia',ls())], file='models_fs_Asia_v12.RDA')
  })
}

if (file.exists('models_fs_NA_v12.RDA') && !Recalcualte_all) load('models_fs_NA_v12.RDA') else {
  try({model_NA_in_IN=mgcv::bam(in_internal ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_NA_in_IN, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_NA_in_INT=mgcv::bam(in_international ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_NA_in_INT, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_NA_out_IN=mgcv::bam(out_internal ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_NA_in_IN, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_NA_out_INT=mgcv::bam(out_international ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_NA_in_INT, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  save(list=ls()[grep('NA_',ls())], file='models_fs_NA_v12.RDA')
  })
}

if (file.exists('models_fs_SA_v12.RDA') && !Recalcualte_all) load('models_fs_SA_v12.RDA') else {
  try({model_SA_in_IN=mgcv::bam(in_internal ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_SA_in_IN, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_SA_in_INT=mgcv::bam(in_international ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_SA_in_INT, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_SA_out_IN=mgcv::bam(out_internal ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_SA_in_IN, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  model_SA_out_INT=mgcv::bam(out_international ~ s(year, bs='ps', m=2) + s(year, region, bs='fs',m=1, k=5) + offset(ln_pop_internal), data=DT_SA_in_INT, family=quasipoisson(), nthreads=ncores, method = 'fREML',discrete = TRUE)
  save(list=ls()[grep('SA_',ls())], file='models_fs_SA_v12.RDA')
  })
}

plot_GAMM<-function(model_IN, model_INT, data_IN, data_INT, 
                    col_IN='red', col_INT='blue', 
                    lty_IN=1, lty_INT=1,
                    xlab='', ylab='',
                    plotgrayrect = TRUE,
                    mult = 1000,
                    cname='',
                    xaxt='s',yaxt='s',
                    ylim=c(-10,0), plot_reg=FALSE){
  
  sterms_IN<-rownames(summary(model_IN)$s.tab)
  sterms_INT<-rownames(summary(model_INT)$s.tab)
  excludeterms_IN<-sterms_IN[grep('region', sterms_IN)]
  excludeterms_INT<-sterms_INT[grep('region', sterms_INT)]
  yy <- seq(0, max(data_IN$year), length.out=100)
  plot(yy+MINY,
       log10(mult)+log10(exp(predict(model_IN, data.frame(year=yy, region=data_IN$region[1], ln_pop_internal=0), 
                                     exclude=excludeterms_IN, type='link'))),
       type='l', ylim=ylim,lwd=2,col=col_IN,xlab='',ylab='', yaxt='n', xaxt=xaxt)
  mtext(ylab,2,2.5)
  mtext(xlab,1,2.5)
  
  if (plotgrayrect) {
    rect(par("usr")[1], par("usr")[3],
         par("usr")[2], par("usr")[4],
         col = "#f2f2f2")
    lines(yy+MINY,
          log10(mult)+log10(exp(predict(model_IN, data.frame(year=yy, region=data_IN$region[1], ln_pop_internal=0), 
                                        exclude=excludeterms_IN, type='link'))),type='l',lwd=2,col=col_IN)
  }
  
  lines(yy+MINY,
        log10(mult)+log10(exp(predict(model_INT, data.frame(year=yy, region=data_INT$region[1], ln_pop_internal=0), 
                                      exclude=excludeterms_INT, type='link'))),type='l',lwd=2,col=col_INT)
  
  if (yaxt=='s') magicaxis::magaxis(2,unlog = TRUE, las=1) else  magicaxis::magaxis(2,unlog = TRUE, las=1, labels=FALSE)
  if (plot_reg){
    for (j in unique(data_IN$region)){
      Y <- range(data_IN$year[data_IN$region==j])
      lines((Y[1]:Y[2])+MINY,
            log10(mult)+log10(exp(predict(model_IN, data.frame(year=(Y[1]:Y[2]), region=j, ln_pop_internal=0), 
                                          type='link'))),type='l',col=adjustcolor(col_IN,alpha.f = 0.2))
      
    }
    for (j in unique(data_INT$region)){
      Y <- range(data_INT$year[data_INT$region==j])
      lines((Y[1]:Y[2])+MINY,
            log10(mult)+log10(exp(predict(model_INT, data.frame(year=(Y[1]:Y[2]), region=j, ln_pop_internal=0), 
                                          type='link'))),type='l',col=adjustcolor(col_INT,alpha.f = 0.2))
      
    }
  }
  top_text(cname, size=0.086, lwd=2, font=2, col=1, border=1, fill=0, boxtype=0)
}

plot_conditional<-function(model_in_IN, 
                           model_in_INT, 
                           model_out_IN, 
                           model_out_INT,
                           data_in_IN, 
                           data_in_INT, 
                           data_out_IN, 
                           data_out_INT,
                           cname = '',
                           xaxt='s', yaxt='s',
                           ylab='',
                           xlab='',
                           ylim=c(-2.2,-0.85)+3,
                           leg=FALSE
){
  c_red<-'#f36f83'; c_blue<-'#1550b0'; c_yellow<-'#d79a20'; c_green<-'#006b00';
  
  plot_GAMM(model_in_IN, 
            model_in_INT, 
            col_IN = c_red,
            col_INT = c_blue,
            data_in_IN, 
            data_in_INT,
            ylab=ylab,
            xlab=xlab,
            xaxt=xaxt,yaxt=yaxt,
            cname=cname,
            ylim=ylim)
  par(new=TRUE)
  plot_GAMM(model_out_IN, 
            model_out_INT, 
            col_IN = c_yellow,
            col_INT = c_green,
            data_out_IN, 
            data_out_INT,
            plotgrayrect = FALSE,
            cname=cname,
            xaxt=xaxt,yaxt=yaxt,
            ylim=ylim)
  if(leg) legend('topright',bty='n',legend=c('Internal in-migration','International in-migration',
                                             'Internal out-migration','International out-migration'),
                 col=c(c_red,c_blue,c_yellow,c_green),lty=1,lwd=2, ncol=1, cex=0.875)
}

suppressWarnings(dir.create('./figPNAS25'))

graphics.off()
closeAllConnections()

pdf(file='./figPNAS25/GAMM_fs_v12.pdf', 8,6.1)
par(mfrow=c(2,3),oma=c(2.8,3.7,0.5,1),mar=c(0.8,1,2,0.1))
plot_conditional(model_Africa_in_IN, model_Africa_in_INT, model_Africa_out_IN, model_Africa_out_INT,
                 DT_Africa_in_IN, DT_Africa_in_INT, DT_Africa_out_IN, DT_Africa_out_INT,
                 cname = 'Africa', ylab='',xaxt='n')

plot_conditional(model_Asia_in_IN, model_Asia_in_INT, model_Asia_out_IN, model_Asia_out_INT,
                 DT_Asia_in_IN, DT_Asia_in_INT, DT_Asia_out_IN, DT_Asia_out_INT,
                 cname = 'Asia',xaxt='n',yaxt='n')

plot_conditional(model_Europe_in_IN, model_Europe_in_INT, model_Europe_out_IN, model_Europe_out_INT,
                 DT_Europe_in_IN, DT_Europe_in_INT, DT_Europe_out_IN, DT_Europe_out_INT,
                 cname = 'Europe',xaxt='n',yaxt='n',leg=TRUE)

plot_conditional(model_NA_in_IN, model_NA_in_INT, model_NA_out_IN, model_NA_out_INT,
                 DT_NA_in_IN, DT_NA_in_INT, DT_NA_out_IN, DT_NA_out_INT,
                 cname = 'North America',ylab='', xlab='')

plot_conditional(model_Oceania_in_IN, model_Oceania_in_INT, model_Oceania_out_IN, model_Oceania_out_INT,
                 DT_Oceania_in_IN, DT_Oceania_in_INT, DT_Oceania_out_IN, DT_Oceania_out_INT,
                 cname = 'Oceania',yaxt='n', xlab='Year')

plot_conditional(model_SA_in_IN, model_SA_in_INT, model_SA_out_IN, model_SA_out_INT,
                 DT_SA_in_IN, DT_SA_in_INT, DT_SA_out_IN, DT_SA_out_INT,
                 cname = 'South America',yaxt='n', xlab='')
par(mfrow=c(1,1),oma=c(2.8,3.7,0.5,1),mar=c(0.8,1,2,0.1))
mtext("Migration rate per 1000 scholars", side = 2, line = 3, cex = 1)

dev.off()
