
# The purpose of this script is to scrape charter data from fishingbooker.com 
  # The data set produced will be at the individual trip level where the following variables 
  # will be unique to each trip 
    # - TRIP_NO: Trip Number 
    # - PRICE: Price for trip per day
    # - TRIP_TYPE 
    # - CANCELATION_POLICY 
    # - TRIP_LENGTH 
    # - PRIVATE_SHARED_TRIP: Indication if this a private or shared charter 
        # - PRIVATE: Entire boat is privately chartered and individual can bring 
              # up to 6 people including children 
  # The remaining variables are static with respect to each charter and values will be repeated 
  # trips taken by the same charter vessel.  
  # Refer to the website listing to find more information on each variable 



rm(list=ls())

library(tidyverse)
library(dplyr)
library(readxl)


source(file.path(".",
                 "hlprfnc_scraping_charter_data.R"))

#--------
# Pull in excel file that has charter name and url-web number 
  charters <- readxl::read_xlsx(file.path(".",
                                             "data",
                                             "charter_web_numbers.xlsx")) 
  
  web_numbers <- charters$charter_number
  
#--------
# As a test, well look at one charter 
  charters[1, ]
  one_charter <- scrape_charter_info.f(web_charter = web_numbers[1])

#--------
# Test if this will work on multiple charters 
  
  lapply(1:nrow(charters), FUN = function(i){
    print(i)
    scrape_charter_info.f(web_charter = charters$charter_number[i])
  })


#--------
# Pull files in and combine for a complete df 
  mult_charters.l <- lapply(1:nrow(charters), FUN = function(i){
    
    web_charter <- charters$charter_number[i]
    
    one_listing <- readRDS(file= file.path(".", 
                                           "data", 
                                           "charter_final_data", 
                                           paste0("webcharter_", web_charter, ".rds")))
    print(i)
    
    return(one_listing)
  })
  
  mult_charter.df <- do.call("rbind", mult_charters.l)

  write.csv(mult_charter.df, file.path(".", 
                                     "data", 
                                     "charter_final_data", 
                                     "FINAL_webcharter.csv"))
