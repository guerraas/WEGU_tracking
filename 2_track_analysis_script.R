#Analyze WEGU gps tracks

## load packages

library(tidyverse)
library(readr)
library(lubridate)
library(here)
library(stringr)
library(purrr)

#########################
#track loading and clean up
## load tracks

#generate list of the track files in the folder
files <- list.files(path=here('data','trackfiles'), pattern="*.csv") 


# read in and process each gps track
tracks_combined <- map_dfr(files, function(file) {
  df <- read_csv(here('data','trackfiles',file)) %>%
    mutate(
      id = tools::file_path_sans_ext(basename(file)),  # Extract filename without extension
      island = str_sub(id, 1, 2)  # Extract first two characters for "island"
    )
})


# adjust timestamp and condense

tracks_combined <- tracks_combined %>% 
  mutate(datetime = as.POSIXct(paste0(.$Date, .$Time), tz="PST")) %>% 
  dplyr::select(id, island, Latitude, Longitude, datetime) %>% 
  rename("lat" = Latitude, "lon" = Longitude)
  

## load tagging times (deployment and retrieval) for each bird

tagmeta <- read_csv(here('data','WEGU_2016_taggingmeta.csv')) %>% 
  mutate(deploy1 = as.POSIXct(deploy, format = "%m/%d/%y %H:%M", tz="PST"), 
         retrieve1 = as.POSIXct(retrieve, format = "%m/%d/%y %H:%M", tz="PST"))

#source functions script
source('1_functions_script.R')

#apply function to all
trimmed_list<- map(unique(tracks_combined$id), ~ trim_tracks(tracks_combined, tagmeta, .x)) %>% 
  compact() #remove null

# bind all into one dataframe
trimmed_tracks <- bind_rows(trimmed_list)

##########################
## Track analysis

#### calculate tracking duration

tracks_summary <- trimmed_tracks %>%
  group_by(island,id) %>%
  summarise(
    tag.dur.hr = as.numeric(difftime(max(datetime),min(datetime),  units = "hours")),
    tag.dur.days = as.numeric(difftime(max(datetime),min(datetime),  units = "days"))
  )


## Load trip analysis data

meta_s <- read_csv(here('data','CHIS2016_Metadata_trackanalysis.csv')) %>% 
 dplyr::select(-c(...6)) %>% 
  rename('s.birdID' = s.BirdID)

track_s <- read_csv(here('data','CHIS2016_TrackData.csv')) %>% 
  dplyr::select(s.birdID, nbrTrips, tripNbr, durMins, distKm)

habitat_s <- read_csv(here('data','CHIS2016_HabitatType.SN.csv')) %>% 
  dplyr::select(habitat, tripID, colony, tag, bandID) %>% 
  rename('s.bandID' = bandID , 's.birdID' = tag) %>% 
  mutate(
    foraging.habitat = case_when(
      habitat == 3000 ~ "mainland",
      habitat == 1000 ~ "ocean",
      habitat == 2000 ~ "SNIS",
      habitat == 4000 ~ "SCIS",
      TRUE ~ NA_character_  # 
    ),# 0 for ocean or intertidal foraging, 1 for mainland foraging
    habitat = case_when(
      habitat == 3000 ~ 1,
      habitat %in% c(1000, 2000, 4000) ~ 0,
      TRUE ~ habitat  
    )
  )

#join metadata
tracks_summary <- left_join(tracks_summary, meta_s, by="id") 

# join track analysis summary
tracks_summary <- left_join(tracks_summary , track_s, by = "s.birdID")

## time spent on travel and colony
tracks_summary <- tracks_summary %>% 
  group_by(s.birdID) %>% 
  #calculate the whole time birds were on foraging trips (during entire tagging time)
  mutate(all.trip.hr = sum(durMins)/60) %>% 
  #calculate how many hours they were at the colony (on land) as tag duration - trip duration sum
  mutate(colony.time.hr = tag.dur.hr - all.trip.hr,
         #colony time per hour of tagged time (proportion) proportion of all time tagged that was on the island. 
         colony.time.perhr = (tag.dur.hr - all.trip.hr)/tag.dur.hr) %>% 
  ungroup()


################# 
# Commensal behavior analysis


habitat_summary <- habitat_s %>% 
  group_by(s.birdID) %>% 
  summarize(commens = mean(habitat), #commensalism score (1 = very commensal, 0 = wild)
            sum.commens = sum(habitat), # how many trips were commensal
            n.trips=n()) %>% #total number of trips 
  left_join(.,meta_s, by='s.birdID') %>% #add in metadata file to join to tracks
  dplyr::select(-c(s.colony,s.bandID,bird.ID))
  


## Commensal behavior with tracks

tracks_habitat_summary <- left_join(tracks_summary, habitat_summary, by="s.birdID")

trimmed_tracks <- left_join(trimmed_tracks, habitat_summary, by = "id")
