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

unrowname<-function(x) { rownames(x)<-NULL; x}

DataNoThresh <- read.csv('./data/20240531_data_without_threshold_all_regions_worldwide.csv')
DataNoThresh <- DataNoThresh[DataNoThresh$year %in% 1998:2017, ]

# Tabulate by mean number of scientist in observed time series within each region
FilterDat<-sapply(unique(DataNoThresh$region), function(k) {
  ind <- which(DataNoThresh$region==k)
  z1<-DataNoThresh$y_pop_IN[ind]
  z2<-DataNoThresh$y_pop_INT[ind]
  z1[is.na(z1)]<-z2[is.na(z1)]
  INTi<-DataNoThresh$in_y_flow_INT[ind]
  INi<-DataNoThresh$in_y_flow_IN[ind]
  INTo<-DataNoThresh$out_y_flow_INT[ind]
  INo<-DataNoThresh$out_y_flow_IN[ind]
  c(region=k,pop=max(z1, na.rm=TRUE),
    serielength=max(
      sum(!is.na(INi)),
      sum(!is.na(INTi)),
      sum(!is.na(INo)),
      sum(!is.na(INTo))),
    serienon0length=max(
      sum(!paste(INi)%in%c('0',NA)),
      sum(!paste(INTi)%in%c('0',NA)),
      sum(!paste(INo)%in%c('0',NA)),
      sum(!paste(INTo)%in%c('0',NA))),
    pop_IN=sum(!is.na(z2)),
    pop_INT=sum(!is.na(z1)))
})
FilterDat<-data.frame(t(FilterDat), stringsAsFactors = FALSE)
FilterDat$serielength<-as.integer(FilterDat$serielength)
FilterDat$serienon0length<-as.integer(FilterDat$serienon0length)
FilterDat$pop <- as.integer(FilterDat$pop)

# apply filtering
filter_ind<-(FilterDat$pop>=25)# & (FilterDat$serielength>=5)
filter_reg <- rownames(FilterDat)[which(filter_ind)]

DataWithThresh<-DataNoThresh[which(DataNoThresh$region%in%filter_reg),]
DataWithThresh<-DataWithThresh[which(!is.na(DataWithThresh$year)),]
DataWithThresh$y_pop_IN[is.na(DataWithThresh$y_pop_IN)]<-DataWithThresh$y_pop_INT[is.na(DataWithThresh$y_pop_IN)]
DataWithThresh$y_pop_INT[is.na(DataWithThresh$y_pop_INT)]<-DataWithThresh$y_pop_IN[is.na(DataWithThresh$y_pop_INT)]
DataWithThresh<-DataWithThresh[!is.na(DataWithThresh$y_pop_INT),]

DT<-data.frame(region = factor(DataWithThresh$region),
               country = DataWithThresh$country_name,
               iso2 = factor(DataWithThresh$country_2letter_code),
               continent = DataWithThresh$continent_name,
               year = DataWithThresh$year - min(DataWithThresh$year, na.rm=TRUE),
               in_internal = DataWithThresh$in_y_flow_IN,
               in_international = DataWithThresh$in_y_flow_INT,
               out_internal = DataWithThresh$out_y_flow_IN,
               out_international = DataWithThresh$out_y_flow_INT,
               
               cmi_internal = DataWithThresh$in_y_flow_IN+DataWithThresh$out_y_flow_IN,
               cmi_international = DataWithThresh$in_y_flow_INT+DataWithThresh$out_y_flow_INT,
               anmr_internal = abs(DataWithThresh$in_y_flow_IN-DataWithThresh$out_y_flow_IN),
               anmr_international = abs(DataWithThresh$in_y_flow_INT-DataWithThresh$out_y_flow_INT),
               
               rate_in_internal = DataWithThresh$in_y_flow_IN/DataWithThresh$y_pop_IN,
               rate_in_international = DataWithThresh$in_y_flow_INT/DataWithThresh$y_pop_INT,
               rate_out_internal = DataWithThresh$out_y_flow_IN/DataWithThresh$y_pop_IN,
               rate_out_international = DataWithThresh$out_y_flow_INT/DataWithThresh$y_pop_INT,
               
               rate_cmi_internal = (DataWithThresh$in_y_flow_IN+DataWithThresh$out_y_flow_IN)/DataWithThresh$y_pop_IN,
               rate_cmi_international = (DataWithThresh$in_y_flow_INT+DataWithThresh$out_y_flow_INT)/DataWithThresh$y_pop_INT,
               rate_anmr_internal = abs(DataWithThresh$in_y_flow_IN-DataWithThresh$out_y_flow_IN)/DataWithThresh$y_pop_IN/2,
               rate_anmr_international = abs(DataWithThresh$in_y_flow_INT-DataWithThresh$out_y_flow_INT)/DataWithThresh$y_pop_INT/2,
               
               pop_internal = DataWithThresh$y_pop_IN,
               pop_international = DataWithThresh$y_pop_INT,
               ln_pop_internal = log(DataWithThresh$y_pop_IN),
               ln_pop_international = log(DataWithThresh$y_pop_INT),
               ln_2pop_internal = log(2*DataWithThresh$y_pop_IN),
               ln_2pop_international = log(2*DataWithThresh$y_pop_INT),
               rate_internal = DataWithThresh$net_y_flow_IN / DataWithThresh$y_pop_IN,
               rate_international = DataWithThresh$net_y_flow_INT / DataWithThresh$y_pop_INT
)

DT<-DT[order(DT$year),]
DT$country<-as.factor(DT$country)

DT_Asia <- DT[DT$continent=='Asia',]; DT_Asia$region <- droplevels(DT_Asia$region); DT_Asia$country <- droplevels(DT_Asia$country)
DT_Africa <- DT[DT$continent=='Africa',]; DT_Africa$region <- droplevels(DT_Africa$region); DT_Africa$country <- droplevels(DT_Africa$country)
DT_Europe <- DT[DT$continent=='Europe',]; DT_Europe$region <- droplevels(DT_Europe$region); DT_Europe$country <- droplevels(DT_Europe$country)
DT_SA <- DT[DT$continent=="South America",]; DT_SA$region <- droplevels(DT_SA$region); DT_SA$country <- droplevels(DT_SA$country)
DT_NA <- DT[DT$continent=="North America",]; DT_NA$region <- droplevels(DT_NA$region); DT_NA$country <- droplevels(DT_NA$country)
DT_Oceania <- DT[DT$continent=="Oceania",]; DT_Oceania$region <- droplevels(DT_Oceania$region); DT_Oceania$country <- droplevels(DT_Oceania$country)

# Data filtering for slope models
remove_short_series_zero<-function(type='IN',mig='imm',data, thresh=5){
  if (type=='IN' && mig=='imm') {
    REG <- unique(data$region)
    m<-sapply(REG, function(k) {
      ind <- which(data$region==k)
      g<-sum(data$rate_in_internal[ind]!=0, na.rm = TRUE)
      g
    })
    res<-data[which(data$region %in% REG[m>=thresh]),]
  } else if (type=='INT' && mig=='imm') {
    REG <- unique(data$region)
    m<-sapply(REG, function(k) {
      ind <- which(data$region==k)
      g<-sum(data$rate_in_international[ind]!=0, na.rm = TRUE)
      g
    })
    res<-data[which(data$region %in% REG[m>=thresh]),]
  } else if (type=='IN' && mig=='emi') {
    REG <- unique(data$region)
    m<-sapply(REG, function(k) {
      ind <- which(data$region==k)
      g<-sum(data$rate_out_internal[ind]!=0, na.rm = TRUE)
      g
    })
    res<-data[which(data$region %in% REG[m>=thresh]),]
  } else if (type=='INT' && mig=='emi') {
    REG <- unique(data$region)
    m<-sapply(REG, function(k) {
      ind <- which(data$region==k)
      g<-sum(data$rate_out_international[ind]!=0, na.rm = TRUE)
      g
    })
    res<-data[which(data$region %in% REG[m>=thresh]),]
  } else if (type=='INT' && mig=='both') {
    REG <- unique(data$region)
    m<-sapply(REG, function(k) {
      ind <- which(data$region==k)
      g1<-sum(data$rate_in_international[ind]!=0, na.rm = TRUE)
      g2<-sum(data$rate_out_international[ind]!=0, na.rm = TRUE)
      g<-min(g1,g2)
      g
    })
    res<-data[which(data$region %in% REG[m>=thresh]),]  
  } else if (type=='IN' && mig=='both') {
    REG <- unique(data$region)
    m<-sapply(REG, function(k) {
      ind <- which(data$region==k)
      g1<-sum(data$rate_in_internal[ind]!=0, na.rm = TRUE)
      g2<-sum(data$rate_out_internal[ind]!=0, na.rm = TRUE)
      g<-min(g1,g2)
      g
    })
    res<-data[which(data$region %in% REG[m>=thresh]),]  
  } else stop()
  res$region<-droplevels(factor(res$region))
  print(REG[!REG %in% res$region])
  res$continent<-droplevels(factor(res$continent))
  res$country<-droplevels(factor(res$country))
  res
}

# Data filtering for GAMMs
remove_short_series_NA<-function(type='IN',mig='imm',data, thresh=5){
  if (type=='IN' && mig=='imm') {
    REG <- unique(data$region)
    m<-sapply(REG, function(k) {
      ind <- which(data$region==k)
      g<-sum(!is.na(data$rate_in_internal[ind]))
      g
    })
    res<-data[which(data$region %in% REG[m>=thresh]),]
  } else if (type=='INT' && mig=='imm') {
    REG <- unique(data$region)
    m<-sapply(REG, function(k) {
      ind <- which(data$region==k)
      g<-sum(!is.na(data$rate_in_international[ind]))
      g
    })
    res<-data[which(data$region %in% REG[m>=thresh]),]
  } else if (type=='IN' && mig=='emi') {
    REG <- unique(data$region)
    m<-sapply(REG, function(k) {
      ind <- which(data$region==k)
      g<-sum(!is.na(data$rate_out_internal[ind]))
      g
    })
    res<-data[which(data$region %in% REG[m>=thresh]),]
  } else if (type=='INT' && mig=='emi') {
    REG <- unique(data$region)
    m<-sapply(REG, function(k) {
      ind <- which(data$region==k)
      g<-sum(!is.na(data$rate_out_international[ind]))
      g
    })
    res<-data[which(data$region %in% REG[m>=thresh]),]
  } else if (type=='INT' && mig=='both') {
    REG <- unique(data$region)
    m<-sapply(REG, function(k) {
      ind <- which(data$region==k)
      g<-sum((!is.na(data$rate_out_international[ind])) & (!is.na(data$rate_in_international[ind])))
      g
    })
    res<-data[which(data$region %in% REG[m>=thresh]),]
  } else if (type=='IN' && mig=='both') {
    REG <- unique(data$region)
    m<-sapply(REG, function(k) {
      ind <- which(data$region==k)
      g<-sum((!is.na(data$rate_out_internal[ind])) & (!is.na(data$rate_in_internal[ind])))
      g
    })
    res<-data[which(data$region %in% REG[m>=thresh]),]
  } else stop()
  res$region<-droplevels(factor(res$region))
  print(REG[!REG %in% res$region])
  res$continent<-droplevels(factor(res$continent))
  res$country<-droplevels(factor(res$country))
  res
}

################################################################################
# Not used in the manuscript
################################################################################
Aggregate_by_country <- function(DATA){
  CNTR<-unique(DATA$country)
  r1<-lapply(CNTR, function(k){
    tmp <- DATA[DATA$country==k,]
    r2<-lapply(sort(unique(tmp$year)), function(y){
      tmp2 <- tmp[tmp$year==y,]
      data.frame(country=k,
                 year = y,
                 count_in_IN = sum(tmp2$in_internal,na.rm=TRUE),
                 count_in_INT = sum(tmp2$in_international,na.rm=TRUE),
                 count_out_IN = sum(tmp2$out_internal,na.rm=TRUE),
                 count_out_INT = sum(tmp2$out_international,na.rm=TRUE),
                 pop = sum(tmp2$pop_internal,na.rm=TRUE),stringsAsFactors = FALSE)
    })
    data.frame(data.table::rbindlist(r2),stringsAsFactors = FALSE)
  })
  r3<-data.frame(data.table::rbindlist(r1),stringsAsFactors = FALSE) 
  r3$rate_in_internal <- r3$count_in_IN / r3$pop
  r3$rate_out_internal <- r3$count_out_IN / r3$pop
  r3$rate_in_international <- r3$count_in_INT / r3$pop
  r3$rate_out_international <- r3$count_out_INT / r3$pop
  r3  
}

ADT_Asia <- Aggregate_by_country(DT_Asia)
ADT_Africa <- Aggregate_by_country(DT_Africa)
ADT_Europe <- Aggregate_by_country(DT_Europe)
ADT_NA <- Aggregate_by_country(DT_NA)
ADT_Oceania <- Aggregate_by_country(DT_Oceania)
ADT_SA <- Aggregate_by_country(DT_SA)

