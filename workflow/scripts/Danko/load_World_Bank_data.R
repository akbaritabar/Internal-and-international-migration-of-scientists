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

load('./data/WorldBank.RDA')

WorldBank<-data.frame(WorldBank,stringsAsFactors = FALSE)
WorldBank$iso2c<-paste(WorldBank$iso2c)
WorldBank[WorldBank$iso2c=='NA',]
WB<-data.frame(iso2=WorldBank$iso2c,
               cat_income=WorldBank$income, 
               WorldBank[,grep('cat',colnames(WorldBank))],
               stringsAsFactors = FALSE)
DT$iso2<-paste(DT$iso2)
WB<-WB[WB$iso2%in%DT$iso2,]

DT2<-dplyr::left_join(DT, WB, by='iso2',relationship = "many-to-many")

