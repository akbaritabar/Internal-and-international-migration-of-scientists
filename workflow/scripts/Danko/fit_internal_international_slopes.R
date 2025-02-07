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

library(brms)

fit_brms<-function(x_measured, y_measured, sigma_x, sigma_y,extend_x=0.2, 
                   method = c('se','mi')[1],xlim=NULL,
                   sig_sig_prior=0.7,...) {
  
  # Prepare data list for brms
  data_list <- list(
    N = length(x_measured),
    x_measured = x_measured,
    y_measured = y_measured,
    sigma_x = sigma_x,
    sigma_y = sigma_y
  )
  
  prlm<-stats::lm(formula = as.numeric(data_list$y_measured)  ~ as.numeric(data_list$x_measured))
  data_list$sigma_lm <- summary(prlm)$sigma
  data_list$log_sigma_lm <- log(data_list$sigma_lm)
  
  #sigma prior using estimates
  sigma_prior<-data.frame(
    prior=paste0('lognormal(',data_list$log_sigma_lm,', ',sig_sig_prior,')'),
    class="sigma",
    coef="",
    group="",
    resp="",
    dpar="",
    nlpar="",
    lb=NA,
    ub=NA,
    source="user")
  class(sigma_prior)<-c("brmsprior", "data.frame")
  
  if (method=='mi') {
    brm_formula <- y_measured | mi(sigma_y) ~ 1 + me(x_measured, sigma_x)
  } else if (method=='se') {
    brm_formula <- y_measured | se(sigma_y, sigma=TRUE) ~ 1 + me(x_measured, sigma_x)
  } else stop('Unknown method')
  
  # Fit the Bayesian regression model with measurement error
  model <- brm(
    formula = brm_formula,
    data = data_list,
    save_pars = save_pars(all=TRUE),
    family = gaussian(),
    prior = as.brmsprior(sigma_prior),
    iter = 10000, warmup = 6000, chains = 4, cores = 4,
    thin = 4,
    seed = 25, #save_pars = save_pars(latent = TRUE),
    control = list(adapt_delta = 0.99999, max_treedepth = 25)  
  )
  
  # Extract posterior samples for coefficients and parameters
  coefficients <- summary(model)$fixed
  
  posterior_samples <- as_draws(model)
  
  # Generate new values for X
  if (is.null(xlim)) {
    exten <- diff(range(x_measured)) * extend_x
    x_pred <- seq(from = min(x_measured) - exten, 
                  to = max(x_measured) + exten, length.out = 250)
  } else {
    exten <- diff(range(xlim)) * 0.1
    x_pred <- seq(from = min(xlim) - exten, 
                  to = max(xlim) + exten, length.out = 250)
  }
  # Initialize matrix for predictions
  predictions <- matrix(NA, nrow = 4000, ncol = length(x_pred))
  
  # Loop over posterior samples and chains
  # Calculate the predictions for each new X using the posterior parameters
  k<-0
  for (i in 1:4) {
    for (j in 1:1000) {
      k<- k + 1
      predictions[k, ] <- posterior_samples[[i]]$b_Intercept[j] + 
        posterior_samples[[i]]$bsp_mex_measuredsigma_x[j] * x_pred
    }
  }
  
  # Compute summary statistics for predictions (mean, 95% CI)
  y_mean <- apply(predictions, 2, mean)
  y_median <- apply(predictions, 2, median)
  y_lower <- apply(predictions, 2, quantile, probs = 0.025)
  y_upper <- apply(predictions, 2, quantile, probs = 0.975)
  y_lower10 <- apply(predictions, 2, quantile, probs = 0.05)
  y_upper10 <- apply(predictions, 2, quantile, probs = 0.95)
  
  # Prepare the result data frame
  result <- data.frame(
    estimate = c(coefficients[, "Estimate"][1], coefficients[, "Estimate"][2]),
    SE = c(coefficients[, "Est.Error"][1], coefficients[, "Est.Error"][2]),
    P = c(NA, NA),
    CI_lo = c(coefficients[, "l-95% CI"][1], coefficients[, "l-95% CI"][2]),
    CI_hi = c(coefficients[, "u-95% CI"][1], coefficients[, "u-95% CI"][2])
  )
  
  # Results
  return(list(
    coefficients = result,
    predictions = data.frame(x = x_pred, y = y_median, ya = y_mean, 
                             y_lo = y_lower, y_hi = y_upper,
                             y_lo_10 = y_lower10, y_hi_10 = y_upper10)
  ))
}

###############################################################################
# Additional methods not used in the manuscript                               #
###############################################################################

# Naive method, weighted OLS
fit_weighted<-function(x_measured,y_measured,sigma_x,sigma_y, method='weighted'){
  
  # Combine data into a data frame
  lm_data <- data.frame(
    x_measured = x_measured,
    y_measured = y_measured,
    sigma_x = sigma_x,
    sigma_y = sigma_y,
    weights = 1/(sigma_x^2 +sigma_y^2)
  )
  if (method=='none') lm_data$weights<-1
  
  # Apply lm regression using varying error values
  lm_fit <- lm(
    y_measured ~ x_measured, 
    data = lm_data, 
    weights = lm_data$weights
  )
  
  estimate<-summary(lm_fit)$coef
  
  list(coefficients = data.frame(estimate=estimate[,1], SE=estimate[,2], P=estimate[,4]))
}

# Deming method
fit_deming<-function(x_measured,y_measured,sigma_x,sigma_y,method='deming'){
  
  # Combine data into a data frame
  deming_data <- data.frame(
    x_measured = x_measured,
    y_measured = y_measured,
    sigma_x = sigma_x,
    sigma_y = sigma_y
  )
  
  if (method=='deming'){
    
    # Apply Deming regression using varying error values
    deming_fit <- deming::deming(
      y_measured ~ x_measured, 
      data = deming_data, 
      xstd = deming_data$sigma_x, 
      ystd = deming_data$sigma_y,
      jackknife = TRUE
    )
    
    # Extract the jackknife estimates (coefficients and variance)
    coefficients <- deming_fit$coef
    variance <- deming_fit$var
    
    # Compute the standard errors from the jackknife variance
    std_errors <- sqrt(diag(variance))
    
    # Compute p-values (assuming normality of coefficients)
    p_values <- 2 * (1 - pnorm(abs(coefficients / std_errors)))
    
  } else  if (method=='none'){
    
    # simple linear model
    model<-lm(y_measured ~ x_measured, 
              data = deming_data)
    model<-summary(model)$coefficients
    coefficients <- model[,1]
    std_errors <- model[,2]
    p_values <- model[,4]
    
  } else stop('Unknown method')
  
  list(coefficients = data.frame(estimate=coefficients, SE=std_errors, P=p_values))
}

init_edv <- function( X,Y,sX,sY, type='linear', df=5, covariate = NULL, secondcovariate=NULL){
  object<-NULL
  if (length(covariate) && !length(secondcovariate)){
    object$data <- data.frame(X=X, Y=Y, sX=sX, sY=sY, C=covariate, K = NA)
  } else if (!length(covariate) && !length(secondcovariate)){
    object$data <- data.frame(X=X, Y=Y, sX=sX, sY=sY, C=NA, K = NA)
  } else if (!length(covariate) && length(secondcovariate)){  
    object$data <- data.frame(X=X, Y=Y, sX=sX, sY=sY, C=NA, K = secondcovariate)
  } else  
    object$data <- data.frame(X=X, Y=Y, sX=sX, sY=sY, C=covariate, K = secondcovariate)
  object$mY <- Y
  if (type=='linear'){
    if (length(covariate) && !length(secondcovariate)){
      object$formula<- Y ~ X*C
    } else if (!length(covariate) && !length(secondcovariate)){
      object$formula<- Y ~ X
    } else if (!length(covariate) && length(secondcovariate)){
      object$formula<- Y ~ X+K
    } else
      object$formula<- Y ~ X*C + K
    object$mX <- model.matrix(object$formula, object$data)
  } else if (type == 'quadratic') {
    if (length(covariate)){ 
      object$formula<- Y ~ X*C + C*I(X^2)
    } else object$formula<- Y ~ X + I(X^2)
  } else if (type == 'quadratic2') {
    if (length(covariate)){ 
      object$formula<- Y ~ X*C + I(X^2)
    } else object$formula<- Y ~ X + I(X^2)  
  } else if (type == 'cubic') {
    if (length(covariate)){
      object$formula<- Y ~ X*C + C*I(X^2) + C*I(X^3)
    } else object$formula<- Y ~ X + I(X)^2 + I(X^3)
  } else if (type == 'cubic2') {
    if (length(covariate)){
      object$formula<- Y ~ X*C + I(X^2) + I(X^3)
    } else object$formula<- Y ~ X + I(X)^2 + I(X^3)  
  } else if (type == 'cubic3') {
    if (length(covariate)){
      object$formula<- Y ~ X*C + I(X^2) + C*I(X^3)
    } else object$formula<- Y ~ X + I(X)^2 + I(X^3)    
  } else if (type == 'b-spline') {
    if (length(covariate)) stop('Not implemented yet')
    B <- splines::bs(X, df=df, intercept = T)
    object$mX <- B
    object$knots <- attr(B,'knots')
  }
  object
}

# Hybrid method, under developement, need more testing.
# Based on Lewis and Linzer method. https://www.jstor.org/stable/25791822
lm_edv <- function(object, method = 'both_1') {
  data <- object$data
  edv_sd <-object$data$sY
  predictors_sd <- object$data$sX
  mY <- object$mY
  mX <- object$mX
  if (is.null(mY)) mY <- as.matrix(model.response(model.frame(object$formula, data, na.action = na.fail)))
  if (is.null(mX)) mX <- model.matrix(object$formula, data)
  
  df.resid <- length(mY) - ncol(mX)
  
  Inverse_0 <- solve(t(mX) %*% mX)
  beta_0 <- Inverse_0 %*% t(mX) %*% mY
  v_sqr_0 <- (mY - mX %*% beta_0)^2
  sigma_sqr_0 <- sum(v_sqr_0) / df.resid
  varcov_beta_0 <- sigma_sqr_0 * Inverse_0
  SE_beta_0 <- sqrt(diag(varcov_beta_0))
  
  predictor_weights <- 1/(predictors_sd^2)
  mW_P <- diag(predictor_weights)
  # coefficients
  Inverse_P <- solve(t(mX) %*% mW_P %*% mX)
  beta_P <- Inverse_P %*% t(mX) %*% mW_P %*% mY
  # squared residuals
  v_sqr_P <- (mY - mX %*% beta_P)^2
  sigma_sqr_P <- sum(v_sqr_P) / df.resid
  
  # Method 1
  reduced_chisq_P <- sum(predictor_weights * v_sqr_P) / df.resid
  # equivalently: 
  # reduced_chisq_P <- (t(sqrt(v_sqr_P)) %*% mW_P %*% sqrt(v_sqr_P))[1] / df.resid
  varcov_beta_P <-  reduced_chisq_P * Inverse_P  
  SE_beta_P <- (sqrt(diag(varcov_beta_P)))
  
  # Method 2  - doesn't work
  # diag_sigma_sqr_P <- (diag(length(mY))*sigma_sqr_P)
  # inner_P <- t(mX) %*% mW_P %*% diag_sigma_sqr_P %*% t(mW_P) %*% mX
  # varcov_beta_P <-  Inverse_P %*% inner_P %*% Inverse_P 
  # varcov_beta_P
  
  if (method == 'both_1'){
    
    trace <- lava::tr(Inverse_P %*% t(mX) %*% mW_P %*% diag(length(mY)) %*% mX)
    new_sig_sqr <- (sum(v_sqr_P) - sum(edv_sd^2) + trace) / df.resid
    new_sig_sqr[new_sig_sqr < 0] <- 0
    comb_w_method <- 2
    if (comb_w_method == 1) {
      new_weights <- 1/(predictors_sd^2 + edv_sd^2 + new_sig_sqr)
      stop('probably wrong method')
    } else if (comb_w_method == 2) {
      new_weights <- 1/((edv_sd^2 + new_sig_sqr) * predictors_sd^2)
    }
    
    mWn <- diag(new_weights)
    beta <- solve(t(mX) %*% mWn %*% mX) %*% t(mX) %*% mWn %*% mY
    
    # probably wrong :
    v_sqr_B <- (mY - mX %*% beta)^2
    Inverse_B <- solve(t(mX) %*% mWn %*% mX)
    reduced_chisq_B <- sum(new_weights * v_sqr_B) / df.resid
    varcov_beta_B <-  reduced_chisq_B * Inverse_B  
    SE_beta_B <- (sqrt(diag(varcov_beta_B)))
    
    res<-list(beta = beta, SE = SE_beta_B, varcov = varcov_beta_B, inv = Inverse_B)
  } else if (method == 'predictor_only'){
    res<-list(beta = beta_P, SE = SE_beta_P, varcov = varcov_beta_P, inv = Inverse_P)  
  } else if (method == 'none'){
    res<-list(beta = beta_0, SE = SE_beta_0, varcov = varcov_beta_0, inv = Inverse_0)  
  } else if (method == 'dependent_only_1'){
    trace <- lava::tr(solve(t(mX) %*% mX) %*% t(mX) %*% diag(length(mY)) %*% mX)
    new_sig_sqr <- (sum(v_sqr_0) - sum(edv_sd^2) + trace) / df.resid
    
    new_weights <- 1/(edv_sd^2 + new_sig_sqr) 
    mWn <- diag(new_weights)
    beta <- solve(t(mX) %*% mWn %*% mX) %*% t(mX) %*% mWn %*% mY
    
    # probably wrong :
    v_sqr_B <- (mY - mX %*% beta)^2
    Inverse_B <- solve(t(mX) %*% mWn %*% mX)
    reduced_chisq_B <- sum(new_weights * v_sqr_B) / df.resid
    varcov_beta_B <-  reduced_chisq_B * Inverse_B  
    SE_beta_B <- (sqrt(diag(varcov_beta_B)))
    
    res<-list(beta = beta, SE = SE_beta_B, varcov = varcov_beta_B, inv = Inverse_B)
  } else if (method == 'dependent_only_2'){
    # https://en.wikipedia.org/wiki/Generalized_least_squares
    tmp <- sigma_sqr_0
    tol <- 1e-7
    check <- 1
    while (check > tol){
      new_weights <- 1/(edv_sd^2 + tmp) 
      mWn <- diag(new_weights)
      beta <- solve(t(mX) %*% mWn %*% mX) %*% t(mX) %*% mWn %*% mY
      v_sqr_D <- (mY - mX %*% beta)^2
      last <- tmp
      tmp <- sum(v_sqr_D) / df.resid
      check <- abs(tmp-last)
    }
    v_sqr_B <- (mY - mX %*% beta)^2
    Inverse_B <- solve(t(mX) %*% mWn %*% mX)
    reduced_chisq_B <- sum(new_weights * v_sqr_B) / df.resid
    varcov_beta_B <-  reduced_chisq_B * Inverse_B  
    SE_beta_B <- (sqrt(diag(varcov_beta_B)))
    
    res<-list(beta = beta, SE = SE_beta_B, varcov = varcov_beta_B, inv = Inverse_B)
  } else if (method == 'both_2'){
    trace <- lava::tr(solve(t(mX) %*% mX) %*% t(mX) %*% diag(length(mY)) %*% mX)
    new_sig_sqr <- (sum(v_sqr_0) - sum(edv_sd^2) + trace) / df.resid
    
    comb_w_method <- 2
    if (comb_w_method == 1) {
      new_weights <- 1/(predictors_sd^2 + edv_sd^2 + new_sig_sqr)
      stop('probably wrong method')
    } else if (comb_w_method == 2) {
      new_weights <- 1/((edv_sd^2 + new_sig_sqr) * predictors_sd^2)
    }
    
    mWn <- diag(new_weights)
    beta <- solve(t(mX) %*% mWn %*% mX) %*% t(mX) %*% mWn %*% mY
    
    v_sqr_B <- (mY - mX %*% beta)^2
    Inverse_B <- solve(t(mX) %*% mWn %*% mX)
    reduced_chisq_B <- sum(new_weights * v_sqr_B) / df.resid
    varcov_beta_B <-  reduced_chisq_B * Inverse_B  
    SE_beta_B <- (sqrt(diag(varcov_beta_B)))
    res<-list(beta = beta, SE = SE_beta_B, varcov = varcov_beta_B, inv = Inverse_B)
  }
  res$tval <- res$beta/res$SE
  res$pval <- 2 * pt(abs(res$tval), df.resid, lower.tail = FALSE)
  list(coefficients = data.frame(estimate=res$beta, SE=res$SE, t=res$tval, P=res$pval),
       vcov = res$varcov, inverse_term = res$inv)
}
