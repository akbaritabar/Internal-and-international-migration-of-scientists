library(dplyr)
library(purrr)

Tfunc <- function(x) 100 * (exp(x) - 1)

prepare_table_slopes<-function(slope_continent_in, 
                               slope_income_in, 
                               slope_continent_out, 
                               slope_income_out, 
                               table.file.name=''){

    # dim(slope_continent_in$object)
  # head(slope_continent_in$object,1)
  # 
  # dim(slope_continent_out$object)
  # head(slope_continent_out$object,1)
  # 
  # dim(slope_income_in$object)
  # head(slope_income_in$object,1)
  # 
  # dim(slope_income_out$object)
  # head(slope_income_out$object,1)
  # 
  # Rename columns for merging
  rename_cols <- function(df, suffix) {
    df %>%
      rename_with(~ paste0(., "_", suffix), c("X", "Y", "sX", "sY", "C", "country", "pop"))
  }
  
  slope_continent_in$object  <- rename_cols(slope_continent_in$object, "cont_in")
  slope_continent_out$object <- rename_cols(slope_continent_out$object, "cont_out")
  slope_income_in$object     <- rename_cols(slope_income_in$object, "inc_in")
  slope_income_out$object    <- rename_cols(slope_income_out$object, "inc_out")
  
  extender <- data.frame(ind=DT2$region, country5 = DT2$country, 
                         income5=DT2$cat_income, continent5 = DT$continent)
  #sapply(lapply(unique(extender$country5),function(k) unique(extender$income2[k==extender$country5])),length)
  extender<-extender[!duplicated(extender$ind),]
  extender<-extender[extender$ind%in%c(slope_continent_in$object$ind,
                                       slope_continent_out$object$ind,
                                       slope_income_in$object$ind,
                                       slope_income_out$object$ind),]
  
  
  # Merge by 'ind'
  merged_df <- reduce(
    list(slope_continent_in$object, slope_continent_out$object, 
         slope_income_in$object, slope_income_out$object, extender),
    full_join, by = "ind"
  )
  
  merged_df <- merged_df %>%
    mutate(C = coalesce(C_cont_in, C_cont_out, continent5)) %>%
    select(-C_cont_in, -C_cont_out, -continent5)  
  merged_df <- merged_df %>%
    mutate(income = coalesce( C_inc_in, C_inc_out, income5)) %>%
    select(-C_inc_in, -C_inc_out, -income5)  
  merged_df <- merged_df %>%
    mutate(country = coalesce(country_cont_in, country_cont_out, country_inc_in, country_inc_out, country5)) %>%
    select(-country_cont_in, -country_cont_out, -country_inc_in, -country_inc_out, -country5)  
  merged_df <- merged_df %>%
    mutate( pop = coalesce(pop_cont_in, pop_cont_out, pop_inc_in, pop_inc_out)) %>%
    select(-pop_cont_in, -pop_cont_out, -pop_inc_in, -pop_inc_out)  
  
  rename_patterns <- function(df) {
    df %>%
      rename_with(~ gsub("^X_", "international_", .x)) %>%
      rename_with(~ gsub("^sX_", "SE_international_", .x)) %>%
      rename_with(~ gsub("^Y_", "internal_", .x)) %>%
      rename_with(~ gsub("^sY_", "SE_internal_", .x)) %>%
      rename_with(~ gsub("_cont_", "_continent_", .x)) %>%
      rename_with(~ gsub("_inc_", "_income_", .x))
  }
  
  # Apply renaming
  merged_df <- rename_patterns(merged_df)
  
  merged_df <- merged_df %>%
    mutate(across(
      .cols = where(is.numeric) & !starts_with("SE_"),
      .fns = Tfunc,
      .names = "{.col}_transformed"
    )) %>%
    select(
      # Reorder the columns so transformed ones come before original ones
      contains("transformed"),
      everything()
    )
  
  merged_df<-merged_df[,order(colnames(merged_df))]
  merged_df<-merged_df[,c(4,2,1,3,5:ncol(merged_df))]
  ppos<-grep('pop',colnames(merged_df))
  rest<-grep('pop',colnames(merged_df)[5:ncol(merged_df)])
  #colnames(merged_df)[c(1:4,ppos,(5:ncol(merged_df))[-rest])]
  merged_df<-merged_df[c(1:4,ppos,(5:ncol(merged_df))[-rest])]
  colnames(merged_df)[1:5]<-c('region_iso','country','continent','income','number_of_scholars')
  
  merged_df$number_of_scholars<-round(as.numeric(merged_df$number_of_scholars),1)
  # Fill missing values in income class (income) within each country
  merged_df <- as.data.frame(merged_df %>%
                               group_by(country) %>%
                               mutate(income = ifelse(is.na(income), first(income[!is.na(income)]), income)) %>%
                               ungroup())
  merged_df <- as.data.frame(
    merged_df %>%
      group_by(country) %>%
      mutate(continent = ifelse(is.na(continent), 
                                first(continent[!is.na(continent)]), continent)) %>%
      ungroup())
  
  return(merged_df)
  
}

prepare_table_Kendall<-function(Kendall_imm, Kendall_emi, Kendall_vs, Kendall_vs_income){
  
  # rename columns
  colnames(Kendall_imm$object)<-c('region_iso',
                                  'Kendall_international_continent_in',
                                  'Kendall_internal_continent_in',
                                  'SE_Kendall_international_continent_in',
                                  'SE_Kendall_internal_continent_in',
                                  'continent1','country1','number_of_scholars1')
  
  colnames(Kendall_emi$object)<-c('region_iso',
                                  'Kendall_international_continent_out',
                                  'Kendall_internal_continent_out',
                                  'SE_Kendall_international_continent_out',
                                  'SE_Kendall_internal_continent_out',
                                  'continent2','country2','number_of_scholars2')
  
  colnames(Kendall_vs$object)<-c('region_iso',
                                 'Kendall_internal_vs_international_continent_out',
                                 'Kendall_internal_vs_international_continent_in',
                                 'SE_Kendall_international_continent_out',
                                 'SE_Kendall_internal_continent_in',
                                 'continent3','country3','number_of_scholars3')
  
  colnames(Kendall_vs_income$object)<-c('region_iso',
                                        'Kendall_internal_vs_international_income_out',
                                        'Kendall_internal_vs_international_income_in',
                                        'SE_Kendall_international_income_out',
                                        'SE_Kendall_internal_income_in',
                                        'income','country4','number_of_scholars4')
  
  extender <- data.frame(region_iso=DT2$region, country5 = DT2$country, 
                         income5=DT2$cat_income, continent5 = DT$continent)
  #sapply(lapply(unique(extender$country5),function(k) unique(extender$income2[k==extender$country5])),length)
  extender<-extender[!duplicated(extender$region_is),]
  extender<-extender[extender$region_iso%in%c(Kendall_vs_income$object$region_iso,
                                              Kendall_vs$object$region_iso,
                                              Kendall_imm$object$region_iso,
                                              Kendall_emi$object$region_iso),]
  
  merged_df <- reduce(
    list(Kendall_imm$object, Kendall_emi$object, 
         Kendall_vs$object, Kendall_vs_income$object,
         extender),
    full_join, by = "region_iso"
  )
  
  merged_df <- merged_df %>%
    mutate(country = coalesce(country1, country2, country3, country4, country5)) %>%
    select(-country1, -country2, -country3, -country4, -country5)  
  merged_df <- merged_df %>%
    mutate(continent = coalesce( continent1, continent2, continent3, continent5)) %>%
    select(-continent1, -continent2, -continent3, -continent5)  
  merged_df <- merged_df %>%
    mutate(number_of_scholars = coalesce(number_of_scholars1, number_of_scholars2, 
                                         number_of_scholars3, number_of_scholars4)) %>%
    select(-number_of_scholars1, -number_of_scholars2, 
           -number_of_scholars3, -number_of_scholars4)  
  merged_df <- as.data.frame(
    merged_df %>%
      group_by(country) %>%
      mutate(continent = ifelse(is.na(continent), 
                                first(continent[!is.na(continent)]), continent)) %>%
      ungroup())
  merged_df <- as.data.frame(merged_df %>%
                               group_by(country) %>%
                               mutate(income = ifelse(is.na(income), first(income[!is.na(income)]), income)) %>%
                               ungroup())
  
  merged_df<-merged_df[,order(colnames(merged_df))]
  colnames(merged_df)
  merged_df<-cbind(merged_df[,c('region_iso','country','continent','income','number_of_scholars')],
                   merged_df[grep('endal',colnames(merged_df))])
  merged_df$number_of_scholars<-round(as.numeric(merged_df$number_of_scholars),1)
  return(merged_df)
}

Tab_slope<-prepare_table_slopes(slope_continent_in=imm_slope_v12,
                                slope_continent_out=emi_slope_v12,
                                slope_income_in=imm_slope_v12_income,
                                slope_income_out=emi_slope_v12_income)


Tab_Kendall<-prepare_table_Kendall(Kendall_imm=imm_kendall_v12, # X international #Y internal
                                   Kendall_emi= emi_kendall_v12, # X international #Y internal
                                   Kendall_vs=kendall_INvsINT_v12, # out-migration vs. in-migration
                                   Kendall_vs_income=kendall_INvsINT_v12_income)

suppressWarnings(dir.create('./tabPNAS25'))

write.table(Tab_slope,'./tabPNAS25/SlopeTable_v12.csv',sep=';',dec='.')
write.table(Tab_Kendall,'./tabPNAS25/KendallTable_v12.csv',sep=';',dec='.')
openxlsx::write.xlsx(Tab_slope,'./tabPNAS25/SlopeTable_v12.xlsx')
openxlsx::write.xlsx(Tab_Kendall,'./tabPNAS25/KendallTable_v12.xlsx')

