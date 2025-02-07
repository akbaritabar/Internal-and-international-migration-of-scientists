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
# Kendall                                                                     #
###############################################################################

Kendall_single<-function(formula, data, unit='region'){
  reg <- levels(droplevels(data[,unit]))
  res <- t(sapply(reg, function(k) {
    #print(k)
    sbset <- data$sbset <- data[,unit]==k
    y <- model.response(model.frame(formula, data=data, subset=sbset, na.action = na.pass))
    x <- data[sbset, as.character(formula[[3]])[1]]
    if (!all(is.na(y))) {
      n <- length(x)
      z <- Kendall::Kendall(x, y)
      z2 <- stats:::cor.test.default(x[!is.na(y)],y[!is.na(y)], method = 'pearson')
      var_z2 <- ((1-z2$estimate^2)/(n-2))
      # alternative calcualtion of Kendall variance from cor.test
      xties <- table(x[duplicated(x)]) + 1
      yties <- table(y[duplicated(y)]) + 1
      
      T0 <- n * (n - 1)/2
      T1 <- sum(xties * (xties - 1))/2
      T2 <- sum(yties * (yties - 1))/2
      D <- sqrt((T0 - T1) * (T0 - T2))
      S <- z$tau * D
      S <- sign(S) * (abs(S) - 1)
      v0 <- n * (n - 1) * (2 * n + 5)
      vt <- sum(xties * (xties - 1) * (2 * xties + 
                                         5))
      vu <- sum(yties * (yties - 1) * (2 * yties + 
                                         5))
      v1 <- sum(xties * (xties - 1)) * sum(yties * 
                                             (yties - 1))
      v2 <- sum(xties * (xties - 1) * (xties - 2)) * 
        sum(yties * (yties - 1) * (yties - 2))
      var_S <- (v0 - vt - vu)/18 + v1/(2 * n * 
                                         (n - 1)) + v2/(9 * n * (n - 1) * (n - 2))
      var_tau_alt<-var_S/D/D
      var_tau<-z$varS/z$D/z$D
      c(kendall.cor=z$tau, kendall.P=z$sl, kendall.var=(var_tau), kendall.var_alt=(var_tau_alt),
        pearson.cor=unname(z2$estimate), pearson.P=z2$p.value,pearson.var=unname(var_z2))
    } else { cat('******',k); rep(NA,7)}
  }))
  rownames(res) <- reg
  res<-na.omit(data.frame(res))
  res
}

K_IN_Total_in <- Kendall_single(rate_in_internal ~ year,remove_short_series_zero('IN','imm',DT))
K_INT_Total_in <- Kendall_single(rate_in_international ~ year,remove_short_series_zero('INT','imm',DT))
K_IN_Total_out <- Kendall_single(formula=rate_out_internal ~ year,data=remove_short_series_zero('IN','emi',DT))
K_INT_Total_out <- Kendall_single(rate_out_international ~ year,remove_short_series_zero('INT','emi',DT))

kendall_IN_vs_INT <- function(IN, INT, data, unit='region'){
  mf <- model.frame(as.formula(paste(IN,'~',INT,'+ year+region+iso2+continent')), data=data, na.action = na.omit)  
  mf <- mf[order(mf$year),]
  mf <- na.omit(mf)
  reg <- levels(droplevels(mf[,unit]))
  res <- t(sapply(reg, function(k) {
    sbset <- mf$sbset <- mf[,unit]==k
    y <- mf[sbset, INT]
    x <- mf[sbset, IN]
    if (!all(is.na(y))) {
      n <- length(x)
      z <- Kendall::Kendall(x, y)
      z2 <- stats:::cor.test.default(x[!is.na(y)],y[!is.na(y)], method = 'pearson')
      var_z2 <- ((1-z2$estimate^2)/(n-2))
      # alternative calcualtion of Kendall variance from cor.test
      xties <- table(x[duplicated(x)]) + 1
      yties <- table(y[duplicated(y)]) + 1
      
      T0 <- n * (n - 1)/2
      T1 <- sum(xties * (xties - 1))/2
      T2 <- sum(yties * (yties - 1))/2
      D <- sqrt((T0 - T1) * (T0 - T2))
      S <- z$tau * D
      S <- sign(S) * (abs(S) - 1)
      v0 <- n * (n - 1) * (2 * n + 5)
      vt <- sum(xties * (xties - 1) * (2 * xties + 
                                         5))
      vu <- sum(yties * (yties - 1) * (2 * yties + 
                                         5))
      v1 <- sum(xties * (xties - 1)) * sum(yties * 
                                             (yties - 1))
      v2 <- sum(xties * (xties - 1) * (xties - 2)) * 
        sum(yties * (yties - 1) * (yties - 2))
      var_S <- (v0 - vt - vu)/18 + v1/(2 * n * 
                                         (n - 1)) + v2/(9 * n * (n - 1) * (n - 2))
      var_tau_alt<-var_S/D/D
      var_tau<-z$varS/z$D/z$D
      c(kendall.cor=z$tau, kendall.P=z$sl, kendall.var=(var_tau), kendall.var_alt=(var_tau_alt),
        pearson.cor=unname(z2$estimate), pearson.P=z2$p.value,pearson.var=unname(var_z2),n=n)
    } else rep(NA,8)
  }))
  rownames(res) <- reg
  na.omit(data.frame(res))
}

K_INvsINT_out_rate <- kendall_IN_vs_INT(IN='rate_out_internal', INT='rate_out_international', 
                                        remove_short_series_zero('IN','imm',
                                                                 remove_short_series_zero('INT','imm',DT)), unit='region')
K_INvsINT_in_rate <- kendall_IN_vs_INT('rate_in_internal', 'rate_in_international',
                                       remove_short_series_zero('IN','emi',
                                                                remove_short_series_zero('INT','emi',DT)), unit='region')

