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

if(!'DT' %in% ls()) stop('missing DT, need to load data first')
if(!'DT2' %in% ls()) stop('missing World Bank data, meed to load them first')

myadjustcolor<-function(col, 
                        alpha.f = 1, 
                        red.f = (1-black.f), 
                        green.f = (1-black.f), 
                        blue.f = (1-black.f), 
                        offset = c(0, 0, 0, 0), 
                        transform = diag(
                          c(red.f, green.f, blue.f, alpha.f)),
                        black.f=0, 
                        mix.white = 0){
  
  col <- adjustcolor(col,alpha.f,red.f,green.f,blue.f, offset, transform)
  rgbcol <- c(col2rgb(col, TRUE))/255
  a <- rgbcol[4]
  rgbcol[1:3] <- rgbcol[1:3]*(1-mix.white)+ c(1,1,1)*mix.white
  
  adjustcolor(rgb(rgbcol[1],rgbcol[2],rgbcol[3]),alpha.f=a)
}

fast.merge.df<-function(DF1, DF2, by, all.x = TRUE, all.y = TRUE){
  DT1 <- data.table :: data.table(DF1, key = by, stringsAsFactors = FALSE)
  DT2 <- data.table :: data.table(DF2, key = by, stringsAsFactors = FALSE)
  data.frame(data.table ::: merge.data.table(DT1, DT2,
                                             all.x = all.x, all.y = all.y),
             stringsAsFactors = FALSE)
}

add_pop_country <- function(object, granul = 'region') {
  object$ind <- rownames(object)
  sup <- t(sapply(unique(object$ind), function(k) {
    ind <- which(DT[[granul]] == k)
    
    P1 <- mean(DT$pop_internal[ind], na.rm = TRUE)
    P2 <- mean(DT$pop_international[ind], na.rm = TRUE)
    
    # Ensure NA handling
    if (all(is.na(DT$pop_internal[ind]))) P1 <- NA
    if (all(is.na(DT$pop_international[ind]))) P2 <- NA
    
    # If P1 is NA, fallback to P2
    if (is.na(P1)) P1 <- P2
    
    c(country = DT$iso2[ind][1], pop = P1)
  }))
  
  sup <- data.frame(sup, ind = rownames(sup))
  fast.merge.df(object, sup, 'ind')
}

select_betas<-function(object_IN, object_INT, Continent=NULL, reverse = TRUE, 
                       name_est='b', name_var='v',granul='region'){
  NIN<-rownames(object_IN)
  NINT<-rownames(object_INT)
  object_IN<-object_IN[NIN%in%NINT,]
  object_INT<-object_INT[NINT%in%NIN,]
  if (length(Continent)){
    if (! Continent %in% unique(DT$continent)) stop()
    NIN<-rownames(object_IN)
    NINT<-rownames(object_INT)
    sel<-unique(DT[[granul]][which(DT$continent==Continent)])
    object_INT<-object_INT[NINT %in% sel,]
    object_IN<-object_IN[NIN %in% sel,]
  }
  if (reverse) {
    res<-data.frame(X = object_IN[,name_est],
                    Y = object_INT[,name_est],
                    sX = object_IN[,name_var],
                    sY = object_INT[,name_var])
    
  } else {
    res<-data.frame(X = object_INT[,name_est],
                    Y = object_IN[,name_est],
                    sX = object_INT[,name_var],
                    sY = object_IN[,name_var])
    
    
  }
  rownames(res)<-rownames(object_IN)
  res$C<-sapply(rownames(res), function(k) DT$continent[DT[[granul]]==k][1])
  res
}

select_betas_2<-function(object_IN, object_INT, WBVariable='cat_income', reverse = TRUE, 
                         name_est='b', name_var='v',granul='region'){
  NIN<-rownames(object_IN)
  NINT<-rownames(object_INT)
  object_IN<-object_IN[NIN%in%NINT,]
  object_INT<-object_INT[NINT%in%NIN,]
  if (reverse) {
    res<-data.frame(X = object_IN[,name_est],
                    Y = object_INT[,name_est],
                    sX = object_IN[,name_var],
                    sY = object_INT[,name_var])
    
  } else {
    res<-data.frame(X = object_INT[,name_est],
                    Y = object_IN[,name_est],
                    sX = object_INT[,name_var],
                    sY = object_IN[,name_var])
    
    
  }
  rownames(res)<-rownames(object_IN)
  res$C<-sapply(rownames(res), function(k) DT2[DT2[[granul]]==k,WBVariable][1])
  res
}

prepare_plot<-function(object_IN, object_INT, variable='continent', 
                       reverse = FALSE, name_est='b', name_var='v',
                       show.fit=TRUE, 
                       xlim=NULL, ylim=NULL){
  
  type<-'linear'
  granul<-'region'
  edvmethod<-'both_2'
  if (variable=='continent')  object<-try(select_betas(object_IN, object_INT, NULL, reverse, name_est, name_var,granul)) else
    object<-try(select_betas_2(object_IN, object_INT, variable, reverse,name_est, name_var,granul))
  
  object<-add_pop_country(object,granul)
  object<-na.omit(object)
  
  if (variable=='continent') C<-as.factor(object$C) else C<-factor(object$C,levels=c('Low','Lower-middle','Upper-middle','High'))
  if (length(C)<4) stop()
  
  Y<-object$Y
  X<-object$X
  sY<-object$sY
  sX<-object$sX
  
  if (!length(xlim)) limX<-quantile(X,c(0.001,0.999)) else limX <- xlim
  if (!length(ylim)) limY<-quantile(Y,c(0.001,0.999)) else limY <- ylim
  limX[1]<-min(limX[1],limY[1])
  limY[1]<-min(limX[1],limY[1])
  limX[2]<-max(limX[2],limY[2])
  limY[2]<-max(limX[2],limY[2])
  
  
  lm_edv_coef<-list()
  lm_brms_fit<-list()
  lm_brms_coef<-list()
  lm_deming_coef<-list()
  lm_simple_coef<-list()
  
  ic <- 0
  if (show.fit)
    for (cntr in levels(C)) {
      ic <- ic + 1
      ind<-C==cntr
      print(cntr)
      if (sum(ind)>2) {
        
        # Only the BRMS method, as the most reliable, is used in the paper.
        
        lm_edv_coef[[ic]]<-lm_edv(object=init_edv(X[ind],Y[ind],sqrt(sX[ind]),sqrt(sY[ind]),type=type),method = edvmethod)$coefficients
        lm_brms_fit[[ic]]<-fit_brms(X[ind],Y[ind],sqrt(sX[ind]),sqrt(sY[ind]),xlim=limX, method='se')
        # Equivalent method:
        # lm_brms_fit_test[[ic]]<-fit_brms(X[ind],Y[ind],sqrt(sX[ind]),sqrt(sY[ind]),limx=limX, method='mi')
        lm_brms_coef[[ic]]<-lm_brms_fit[[ic]]$coefficients
        lm_deming_coef[[ic]]<-fit_deming(X[ind],Y[ind],sqrt(sX[ind]),sqrt(sY[ind]))$coefficients
        lm_simple_coef[[ic]]<-fit_weighted(X[ind],Y[ind],sqrt(sX[ind]),sqrt(sY[ind]),method = 'none')$coefficients
      }
    }
  
  list(object=object, lm_edv_coef=lm_edv_coef,
       lm_brms_fit=lm_brms_fit,
       lm_brms_coef=lm_brms_coef,
       lm_deming_coef=lm_deming_coef,
       lm_simple_coef=lm_simple_coef,
       C=C, object_IN=object_IN, object_INT=object_INT, variable=variable, 
       reverse = reverse, name_est=name_est, name_var=name_var,
       show.fit=show.fit,granul=granul,
       limX=limX,limY=limY)
}


Plot_Multi_Panel <- function(plot_object,
                             digits=0,
                             xlab=NULL, ylab=NULL, main='', laboffs=2.35, xlim=NULL, ylim=NULL,
                             add_quart_fraq = FALSE, shift.x=c(0,0,0,0,0,0),shift.y=c(0,0,0,0,0,0), remove.xax=c(1,1,1,0,0,0), 
                             remove.yax=c(0,1,1,0,1,1), title.shift=2.2, 
                             show.only.signif = FALSE,
                             show.naive.fit=FALSE, transform.mult=FALSE,
                             COL_CI = gray(0.55),
                             CI_Type = c('solid','spider')[1],
                             CI_density = 10,
                             use.tertiles.pop = FALSE
                             
){
  
  
  
  remove.xax<-c('s','n')[remove.xax+1]
  remove.yax<-c('s','n')[remove.yax+1]
  
  object<-plot_object$object
  
  C=plot_object$C
  object_IN=plot_object$object_IN 
  object_INT=plot_object$object_INT 
  variable=plot_object$variable
  reverse = plot_object$reverse 
  name_est=plot_object$name_est 
  name_var=plot_object$name_var
  show.fit=plot_object$show.fit
  granul=plot_object$granul
  limX=plot_object$limX
  limY=plot_object$limY
  
  Y<-object$Y
  X<-object$X
  sY<-object$sY
  sX<-object$sX
  
  # number of scholars classes, color codes for regions and countries 
  if (granul=='region') {
    tertiles <- c(0,quantile(as.numeric(object$pop), probs = c( 1/3, 2/3), na.rm = TRUE),1e7)
    if (use.tertiles.pop) {
      POP<-as.numeric(cut(as.numeric(object$pop),tertiles,include.lowest = TRUE))
    } else{
      POP<-as.numeric(cut(as.numeric(object$pop),c(0,100,1000,1000000),include.lowest = TRUE))
    }
  } else if (granul=='country') {
    POP<-as.numeric(cut(as.numeric(object$pop),c(0,1000,10000,100000000),include.lowest = TRUE))
  } else stop('Unknown granul')
  
  PAL2<-c("#2297E6FF", "#E6AB02FF","#E7298AFF")
  
  if (reverse) {
    if (!length(xlab)) xlab<-'Internal'
    if (!length(ylab)) ylab<-'International'
  } else {
    if (!length(xlab)) xlab<-'International'
    if (!length(ylab)) ylab<-'Internal'
  }
  
  x<-seq(min(limX),max(limX),length.out=100)
  
  ic <- 0
  if (length(C)<4) stop()
  for (cntr in levels(C)) {
    ic <- ic + 1
    ind<-C==cntr
    print(cntr)
    
    if (show.fit) {
      # Only the BRMS method, as the most reliable, is used in the paper.
      lm_edv_coef<-plot_object$lm_edv_coef[[ic]]
      lm_brms_fit<-plot_object$lm_brms_fit[[ic]]
      lm_brms_coef<-plot_object$lm_brms_fit[[ic]]$coefficients
      lm_deming_coef<-plot_object$lm_deming_coef[[ic]]
      lm_simple_coef<-plot_object$lm_simple_coef[[ic]]
      
      signif<-((lm_brms_fit$coefficients[2,'CI_lo']<0) & (lm_brms_fit$coefficients[2,'CI_hi']<0)) |
        ((lm_brms_fit$coefficients[2,'CI_lo']>0) & (lm_brms_fit$coefficients[2,'CI_hi']>0))
      show.fit.case<- (!show.only.signif || (show.only.signif && signif))  
    } else show.fit.case <- FALSE  
    
    # Build plot area, transform axis if transform.mult==TRUE
    if (transform.mult){
      plot(X[ind],Y[ind],col=1, xlab='', ylab='', xlim=limX, ylim=limY, pch=1, asp=1, 
           xaxt='n', yaxt = 'n')
      ax.log_values <- log(seq(1.6, 0.4, by = -0.1))
      ax.labels <- seq(60, -60, by = -10)
      
      if (remove.xax[ic] == 's') axis(1, at = ax.log_values, labels = ax.labels)
      if (remove.yax[ic] == 's') axis(2, at = ax.log_values, labels = ax.labels)
      
    } else {
      plot(X[ind],Y[ind],col=1, xlab='', ylab='', xlim=limX, ylim=limY, pch=1, asp=1, 
           xaxt=remove.xax[ic], yaxt = remove.yax[ic])
    }
    
    # gray background
    rect(par("usr")[1], par("usr")[3],
         par("usr")[2], par("usr")[4],
         col = "#f2f2f2")
    
    # calculate fractions on the corners
    f_tr<-paste0(format(round(f_trn<-100*sum(X[ind]>0&Y[ind]>0)/length(X[ind]),digits),nsmall = digits, digits = NULL),'%')
    f_tl<-paste0(format(round(f_tln<-100*sum(X[ind]<0&Y[ind]>0)/length(X[ind]),digits),nsmall = digits, digits = NULL),'%')
    f_br<-paste0(format(round(f_brn<-100*sum(X[ind]>0&Y[ind]<0)/length(X[ind]),digits),nsmall = digits, digits = NULL),'%')
    f_bl<-paste0(format(round(f_bln<-100*sum(X[ind]<0&Y[ind]<0)/length(X[ind]),digits),nsmall = digits, digits = NULL),'%')
    
    # which value is the highest ?
    bigg <- which.max(c(f_trn, f_tln, f_brn, f_bln))
    if(length(bigg)>1) stop()
    
    # Define positions
    x_left <- par("usr")[1]
    x_right <- par("usr")[2]
    y_bottom <- par("usr")[3]
    y_top <- par("usr")[4]
    cxy_y <- par("cxy")[2]
    
    # Color the highest value
    if (bigg == 1) { 
      rect(0, 0, x_right, y_top, col = "#e0f0e5", border = NA)
    } else if (bigg == 2) {
      rect(x_left, 0, 0, y_top, col = "#e0f0e5", border = NA)
    } else if (bigg == 3) {
      rect(0, y_bottom, x_right, 0, col = "#e0f0e5", border = NA)
    } else if (bigg == 4) {
      rect(x_left, y_bottom, 0, 0, col = "#e0f0e5", border = NA)
    }
    # plot title bar on the top of the panel
    top_text(cntr, size=0.086, lwd=2, font=2, col=1, border=1, fill=0, boxtype=0)
    
    box()
    
    # labels
    if (variable=='continent') { # 2 x 3 plot
      if (ic==2) mtext(main,3,title.shift)
      if (ic>3) mtext(xlab,1,laboffs)
      if (ic%in%c(1,4)) mtext(ylab,2,laboffs)
    } else {  # 2 x 2 plot
      if (ic==2) mtext(main,3,title.shift)
      if (ic>2) mtext(xlab,1,laboffs)
      if (ic%in%c(1,3)) mtext(ylab,2,laboffs)
    }
    
    # plot quadrants axes
    abline(h=0,v=0,lty=3,col=1,lwd=2)
    
    # Show confidence intervals for fit
    if (show.fit.case && sum(ind)>2) {
      if (CI_Type=='spider') {
        
        polygon(c(lm_brms_fit$predictions$x, rev(lm_brms_fit$predictions$x)), 
                c(lm_brms_fit$predictions$y_lo, rev(lm_brms_fit$predictions$y_hi)), 
                col = COL_CI, border = COL_CI, density = CI_density, angle = 25)
        polygon(c(lm_brms_fit$predictions$x, rev(lm_brms_fit$predictions$x)), 
                c(lm_brms_fit$predictions$y_lo, rev(lm_brms_fit$predictions$y_hi)), 
                col = COL_CI, border = COL_CI, density = CI_density, angle = 25-45)
        
      } else if (CI_Type=='solid') {
        polygon(c(lm_brms_fit$predictions$x, rev(lm_brms_fit$predictions$x)), 
                c(lm_brms_fit$predictions$y_lo, rev(lm_brms_fit$predictions$y_hi)), 
                col = COL_CI, border = COL_CI)
        
      } else stop('Unknow CI_Type')
      
    }
    
    # Plot data points + SE
    for (k in seq_along(X[ind])) {
      lines(c(X[ind][k]-sX[ind][k]^0.5,X[ind][k]+sX[ind][k]^0.5), c(Y[ind][k],Y[ind][k]), col=myadjustcolor(PAL2[POP[ind][k]],mix.white = 0.55),lwd=1)
      lines(c(X[ind][k],X[ind][k]), c(Y[ind][k]-sY[ind][k]^0.5,Y[ind][k]+sY[ind][k]^0.5), col=myadjustcolor(PAL2[POP[ind][k]],mix.white = 0.55),lwd=1)
    }
    lines(X[ind],Y[ind],col=PAL2[POP[ind]], xlab='', ylab='', xlim=limX, ylim=limY, pch=1, type='p',cex=1.1)
    
    # show fitted lines
    if (show.fit.case && sum(ind)>2) {
      
      lines(lm_brms_fit$predictions$x, 
            lm_brms_fit$predictions$y, 
            type = "l", col = "black", lwd = 2)
      
      # Not used in the manuscript
      if (show.naive.fit) { 
        
        lines(x,x*(lm_edv_coef$estimate[2])+lm_edv_coef$estimate[1],
              col='#22ae22', lwd=2)
        
        lines(x,x*(lm_simple_coef$estimate[2])+lm_simple_coef$estimate[1], 
              col="#2187A7", lwd=2,lty=2)
        
        lines(x,x*(lm_deming_coef$estimate[2])+lm_deming_coef$estimate[1],
              col="#EF0000", lwd=2)
        
      }
      
    }
    
    # Not used in the manuscript
    if (show.naive.fit && show.fit.case && sum(ind)>2) {
      # P-values for Deming
      for (inix in seq(0.08,1,0.01)){
        tx<-par("usr")[1]+(par("usr")[2]-par("usr")[1])*inix+shift.x[ic]
        ty<-tx*(lm_deming_coef$estimate[2])+lm_deming_coef$estimate[1]-(par("usr")[4]-par("usr")[3])*0.06
        check<-(ty>par("usr")[3]+(par("usr")[4]-par("usr")[3])*0.06) & (ty<par("usr")[4]-(par("usr")[4]-par("usr")[3])*0.06)
        if (check) break
      }
      
      asr<-par('pin')[2]/par('pin')[1]
      srt<-180*atan(lm_deming_coef$estimate[2]*asr)/pi
      plabels <- paste0('P = ',format(round(lm_deming_coef$P[2],4), nsmall = 4, scientific=FALSE))
      plabels[plabels=='P = 0.0000']<-'P < 0.0001'
      text(tx,ty+shift.y[ic],srt=srt,labels = plabels,col="#EF0000", adj=c(0,0),cex=1)
      
      # P-values for experimental method
      for (inix in seq(0.08,1,0.01)){
        txo2<-par("usr")[1]+(par("usr")[2]-par("usr")[1])*inix+shift.x[ic]
        tyo2<-txo2*(lm_edv_coef$estimate[2])+lm_edv_coef$estimate[1]-(par("usr")[4]-par("usr")[3])*0.06
        check<-(tyo2>par("usr")[3]+(par("usr")[4]-par("usr")[3])*0.06) & (tyo2<par("usr")[4]-(par("usr")[4]-par("usr")[3])*0.06)
        if (check) break
      }
      
      srto2<-180*atan(lm_edv_coef$estimate[2]*asr)/pi
      
      plabelso2 <- paste0('P = ',format(round(lm_edv_coef$P[2],4), nsmall = 4, scientific=FALSE))
      plabelso2[plabelso2=='P = 0.0000']<-'P < 0.0001'
      text(txo2,tyo2+shift.y[ic],srt=srto2,labels = plabelso2,col='#22ae22', adj=c(0,0),cex=1)
      
    }
    
    # plot quadrant proportions
    if (add_quart_fraq) {
      
      labels <- c(f_tr, f_tl, f_br, f_bl)  # Matching order to bigg
      x_pos <- c(x_right, x_left, x_right, x_left)
      y_pos <- c(y_top - cxy_y * 0.6, y_top - cxy_y * 0.6, y_bottom + cxy_y * 0.5, y_bottom + cxy_y * 0.5)
      pos_vals <- c(2, 4, 2, 4)  # Right (2) for TR and BR, left (4) for TL and BL
      
      text_width <- max(strwidth(labels, cex = par("cex")))
      text_height <- max(strheight(labels, cex = par("cex")))
      for (i in 1:4) {
        bg_color <- ifelse(i == bigg, "#e0f0e5", "#f2f2f2")
        if (CI_Type=='spider') {
          rect(x_pos[i] - (pos_vals==2)*text_width*2.1 + (pos_vals==4)*text_width*0.33, 
               y_pos[i] - text_height*1.15, 
               x_pos[i] + (pos_vals==4)*text_width*2.1- (pos_vals==2)*text_width*0.33, 
               y_pos[i] + text_height*1.15, 
               col = bg_color, border = NA)
        }
        text(x_pos[i], y_pos[i], labels[i], pos = pos_vals[i])
      }
      box()
      
    }
    
  }
}

