  
  # Scrape Charter Data
  The purpose of this repo is to scrape public data capturing fishing charters from fishingbooker.com 
  
  #------------------
  
  *Procedures and Background*  
  The code will scrape the information listed above, bring it into your R environment, and save each charter data set as an excel workbook.  Each file will be saved using the url-web number taken from the url of each listing and each sheet name will be organized based on the scraped-details listed above. 
  
    - How to use
      - Store "charter id numbers" in the data/charter_web_numbers.xlsx file
      - Open up the "Charter Data.Rproj"
      - Run charter_data.R
      - Review output in data/charter_final_data
    
  *Inputs required*
      - Charter id number
      - Booking number of days 
      - Booking number of persons
      - Booking number of children 
   
   *Output Generated*
    - The code will scrape various details from the website: 
      - About
        - Name of vessel (Name)
        - Number of trips offered (no_trips_offered)
        - Length of vessel (length)  
        - Capacity 
       - Target Species 
       - Vessel Specifications 
       - Fishing Type 
       - Fishing Techniques
       - Amenities
       - Included in Trip 
       - Individual Trip Details- For each individual trip this charter offers we have 
          - Price 
          - Trip type 
          - Cancelation policy 
          - Trip length 
          - Private or Shared 

