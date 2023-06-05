

library(rvest)
library(tidyverse)
library(dplyr)
library(openxlsx)
#library(splashr)
#library(magick)


#web_charter <- 16907
#web_charter <- 6225

  scrape_charter_info.f <- function(web_charter,
                                    booking_days = 1,
                                    booking_person = 2,
                                    booking_children = 0){
    
    # Read the url into R 
    url.str <- paste0(
      "https://fishingbooker.com/charters/view/", web_charter, 
      "?booking_days=", booking_days, 
      "&booking_persons=", booking_person,
      "&booking_children=", booking_children
    )
    
    url <- read_html(url.str)
    
    #------------------------------------------------------
    # Scrape Vessel specifics 
    # These variables will not change within the same vessel (eg vessel length, 
    # vessel name, target species, vessel capacity, amenities, what the trip includes, 
    # number of trips this vessel offers)
    
    # Grab the name of charter 
    xpath.char <- '//*[contains(concat( " ", @class, " " ), concat( " ", "headline", " " ))]'
    charter_name <- url %>%
      html_nodes(xpath = xpath.char) %>% 
      html_text()
    charter_name_clean <- strsplit(charter_name, "\\s*\n+\\s*")[[1]][2]
    
    #---------
    # Grab charter location 
    xpath.char <- '//*[contains(concat( " ", @class, " " ), concat( " ", "col-middle", " " ))]//small'
    location <- url %>%
      html_nodes(xpath = xpath.char) %>% 
      html_text()
    
    address <- strsplit(location, "\\s*\n+\\s*")[[2]][1]
    city_state <- strsplit(location, "\\s*\n+\\s*")[[3]][1]
    
    #---------
    # Find out how many trips this charter offers 
    xpath.char <- '//*[contains(concat( " ", @class, " " ), concat( " ", "package-item", " " ))]'
    all_trips <- url %>%
      html_nodes(xpath = xpath.char) %>% 
      html_text()
    number_trips_offered <- length(all_trips)
    
    #---------
    # Target Species 
    xpath.char <- '//*[contains(concat( " ", @class, " " ), concat( " ", "fish-name", " " ))]'
    target_species <- url %>%
      html_nodes(xpath = xpath.char) %>% 
      html_text()
    
    target_species_clean <- gsub("\n", "", target_species) %>% 
      paste(collapse = '... ')
    
    #---------
    # Boat Specifics
    xpath.char <- '//*[contains(concat( " ", @class, " " ), concat( " ", "charterDetails-item", " " )) and (((count(preceding-sibling::*) + 1) = 5) and parent::*)]'
    boat_specifics <- url %>%
      html_nodes(xpath = xpath.char) %>% 
      html_text()
    
    boat_specifics_clean <- strsplit(boat_specifics, "\\s*\n+\\s*")[[1]][-c(1:2)]
    
    vessel_specs <- boat_specifics_clean[1]
    vessel_length <- boat_specifics_clean[3]
    vessel_capacity <- boat_specifics_clean[5]
    
    #---------
    # Types of fishing 
    xpath.char <- '//*[contains(concat( " ", @class, " " ), concat( " ", "charterDetails-item", " " )) and (((count(preceding-sibling::*) + 1) = 6) and parent::*)]'
    fishing_type <- url %>%
      html_nodes(xpath = xpath.char) %>% 
      html_text()
    
    fishing_type_clean <- strsplit(fishing_type, "\\s*\n+\\s*")[[1]][-c(1:2)] %>% 
      paste(collapse = '... ')
    
    #---------
    # Fishing Techniques
    xpath.char <- '//*[contains(concat( " ", @class, " " ), concat( " ", "charterDetails-item", " " )) and (((count(preceding-sibling::*) + 1) = 7) and parent::*)]'
    fishing_techniques <- url %>%
      html_nodes(xpath = xpath.char) %>% 
      html_text()
    
    fishing_techniques_clean <- strsplit(fishing_techniques, "\\s*\n+\\s*")[[1]][-c(1:2)] %>% 
      paste(collapse = '... ')
    
    #---------
    # Amenities
    xpath.char <- '//*[contains(concat( " ", @class, " " ), concat( " ", "charterDetails-item", " " )) and (((count(preceding-sibling::*) + 1) = 8) and parent::*)]'
    amenities <- url %>%
      html_nodes(xpath = xpath.char) %>% 
      html_text()
    
    amenities_clean <- strsplit(amenities, "\\s*\n+\\s*")[[1]][-c(1:2)] %>% 
      paste(collapse = '... ')
    
    #---------
    # Trip Includes
    xpath.char <- '//*[contains(concat( " ", @class, " " ), concat( " ", "charterDetails-item", " " )) and (((count(preceding-sibling::*) + 1) = 9) and parent::*)]'
    trip_include <- url %>%
      html_nodes(xpath = xpath.char) %>% 
      html_text()
    
    trip_include_clean <- strsplit(trip_include, "\\s*\n+\\s*")[[1]][-c(1:2)] %>% 
      paste(collapse = '... ')
    
    #-----------
    # Combine vessel specific attributes that are elements to a data frame 
    # Most of these vessel specific attributes are a vector (eg target species).  This will vary 
    # for each trip so leave these variables as a vector.  For the element variables (eg vessel name,
    # number of trips offered, vessel length, and vessel capacity) combine them into a 
    # data frame to include in the final list.  
    
    about <- data.frame(
      VESSEL_NAME = charter_name_clean,
      LENGTH = vessel_length,
      CAPACITY = vessel_capacity,
      STREET = address,
      CITY_STATE = city_state
    )
    
    
    
    #-----------------------------------------
    # About the individual trips 
    # For each vessel, they offere a number of different trips 
    # scrape the trip level information (eg price, private/shared, trip length, etc)
    
    #---------
    # Find the price for each trip 
    xpath.char <- '//*[contains(concat( " ", @class, " " ), concat( " ", "js-package-recalculated-price", " " ))]'
    price <- url %>%
      html_nodes(xpath = xpath.char) %>% 
      html_text()
    
    # some reason the trip prices repeat, only grab the every other value
    logical_vector <- rep(c(TRUE, FALSE), number_trips_offered)
    trip_price <- price[logical_vector]
    trip_price_clean <- gsub("\n", "", trip_price)
    
    #---------
    # Trip type 
    xpath.char <- '//*[contains(concat( " ", @class, " " ), concat( " ", "package-title", " " ))]'
    trip_type <- url %>%
      html_nodes(xpath = xpath.char) %>% 
      html_text()
    
    trip_type_clean <- gsub("\n", "", trip_type)
    
    #---------
    # Trip length 
    xpath.char <- '//*[contains(concat( " ", @class, " " ), concat( " ", "description-content", " " ))]'
    trip_length <- url %>%
      html_nodes(xpath = xpath.char) %>% 
      html_text()
    
    # We want to get rid of the \n in each element 
    trip_length_clean <- gsub("\n", "", trip_length)
    
    # Separate the cancellation policy and the trip length for each trip 
    season_trips <- grep("Seasonal", trip_length_clean, value = TRUE)
    cancelation_policy <- grep(paste(c("FREE", "Low"), collapse="|"), trip_length_clean, value = T)
    trip_length <- trip_length_clean[!(trip_length_clean %in% c(cancelation_policy, season_trips))]
      # For some reason setdiff(trip_length_clean, c(cancelation_policy, season_trips))
      # was dropping repeated values in trip_length_clean 
    
    #---------
    # Private or Shared 
    xpath.char <- '//*[contains(concat( " ", @class, " " ), concat( " ", "private", " " ))]'
    logical_private <- url %>%
      html_nodes(xpath = xpath.char) %>% 
      html_text()
    
    logical_private_clean <- logical_private[logical_vector] %>% 
      is.na() %>% 
      ifelse("Shared trip", logical_private)
    
    #---------------
    # Combine all trip attributes to a single data frame 
    # Each observation will be an individual trip offered by this specific vessel
    
    TRIP_DETAILS <- data.frame(
      TRIP_NO = 1:number_trips_offered,
      WEB_ID = web_charter, 
      PRICE = trip_price_clean,
      TRIP_TYPE = trip_type_clean, 
      CANCELATION_POLICY = cancelation_policy,
      TRIP_LENGTH = trip_length,
      PRIVATE_SHARED_TRIP = logical_private_clean
    )
    
    #----------
    # Create a flat data frame at the charter (trip) level.  Vessel level characteristics will 
      # be repeated for charters done by the same vessel. 
    
    TRIP_JOIN <- TRIP_DETAILS %>% 
      merge(about) %>% 
      mutate(TARGET_SPECIES = target_species_clean,
             VESSEL_SPECIFICS = vessel_specs,
             FISHING_TYPE = fishing_type_clean,
             FISHING_TECHNIQUES = fishing_techniques_clean,
             AMENITIES = amenities_clean,
             INC_IN_TRIP = trip_include_clean)
    
    
    
    # save workbook to disk once all worksheets and data have been added
    saveRDS(TRIP_JOIN, file= file.path(".", 
                                    "data", 
                                    "charter_final_data", 
                                    paste0("webcharter_", web_charter, ".rds")))
    
  # ---------------------------
  # Return scraped charter data into the R environment 
    #return(TRIP_JOIN)
  
  }
