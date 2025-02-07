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

quasipoisson_single_fit<-function(formula, data, unit='region'){
  formula<-as.formula(formula)
  data[[as.character(formula)[2]]]<-as.numeric(data[[as.character(formula)[2]]])
  data[,unit]<-as.factor(data[,unit])
  reg <- levels(droplevels(data[,unit]))
  res <- lapply(reg, function(k) {
    sbset <- data$sbset <- data[,unit]==k
    data<-model.frame(formula, data=data, na.action = na.omit, subset = sbset)
    oi <- grep('offset',colnames(data))
    colnames(data)[oi]<-substr(colnames(data)[oi],8,nchar(colnames(data)[oi])-1)
    if (nrow(data)>0){
      cat(k)
      if (length(unique(data$region))==1 && unit!='region') {
        formula<-update(formula,'.~.-region-year:region-region:year') 
        print(formula)
      }
      m <- glm(formula, family = quasipoisson(),
               data=data, #na.action = na.omit,
               control = glm.control(maxit=1000))
      model <- summary(m)$coefficients
      model
    } else try(stop(),silent=TRUE)
  })
  names(res) <- reg
  z<-which(sapply(sapply(res,class),paste,collapse='')=="try-error")
  if (length(z)) res[z]<-NULL
  res
}

o_IN_Total_in <- quasipoisson_single_fit(formula=in_internal ~ year + offset(ln_pop_internal), 
                                         data=remove_short_series_zero('IN','imm',DT))
o_INT_Total_in <- quasipoisson_single_fit(in_international ~ year + offset(ln_pop_international), 
                                          remove_short_series_zero('INT','imm',DT))
o_IN_Total_out <- quasipoisson_single_fit(out_internal ~ year + offset(ln_pop_internal),
                                          remove_short_series_zero('IN','emi',DT))
o_INT_Total_out <- quasipoisson_single_fit(out_international ~ year + offset(ln_pop_international),
                                           remove_short_series_zero('INT','emi',DT))

beta2degree <- function (x) atan(x)/pi*180
beta.var2degree.var<- function(x,v, B=1e5) 
  sapply(seq_along(x),function(k) var(beta2degree(rnorm(B,x[k],sqrt(v[k])))))

extract_slopes_single<-function(modellist) {
  Nam <- names(modellist)
  means <- sapply(modellist, function(k) k["year",1])
  variances <- sapply(modellist, function(k) k["year",2])^2
  names(means)<-names(variances)<-Nam
  data.frame(b=means, v=variances, dm = beta2degree(means), dv=beta.var2degree.var(means,variances))
}

p_IN_Total_in <- extract_slopes_single(o_IN_Total_in)
p_INT_Total_in <- extract_slopes_single(o_INT_Total_in)
p_IN_Total_out <- extract_slopes_single(o_IN_Total_out)
p_INT_Total_out <- extract_slopes_single(o_INT_Total_out)

