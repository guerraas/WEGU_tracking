## visualizing tracks

### load packages
library(tidyverse) #install.packages("tidyverse")
library(here)
library(lubridate)
library(sf) #install.packages("sf", dependencies=TRUE)
library(ggspatial) #install.packages("ggspatial")
library(ggmap) #install.packages("ggmap")
library(maps)
library(mapdata) #install.packages('mapdata')
library(rnaturalearth)
library(rnaturalearthdata)
library(tmap) #install.packages('tmap')
library(rworldmap)#install.packages("rworldmap")
library(sp)#install.packages("sp")
library(raster)#install.packages("raster")
library(leaflet) #install.packages("leaflet")

source('2_track_analysis_script.R')

### load basemaps

cal <- coastis <- ne_download(
  scale=10,
  type = 'land',
  category = "physical",
  returnclass = "sf")

is <- ne_download(
  scale=10,
  type = 'minor_islands',
  category = "physical",
  returnclass = "sf")

ocean <- ne_download(
  scale=10,
  type = 'ocean',
  category = "physical",
  returnclass = "sf")

ocean <- st_make_valid(ocean)



bbox <- st_bbox(c(xmin = -119.8, ymin = 33.2, xmax = -117.75, ymax = 34.3), crs = st_crs(is))


# Crop the coastline to the bounding box
is_crop <- st_crop(is, bbox)
cal_crop <- st_crop(cal,bbox)
ocean_crop <- st_crop(ocean,bbox)


### visualize tracks

#both colonies, with commensal behavior fill

 bothis_plot <-  ggplot() +
    geom_sf(data = is_crop, fill = "darkgreen", color = "lightgreen", alpha = 0.5) + 
    geom_sf(data = cal_crop, fill = "darkgoldenrod", color = "gold", alpha = 0.5) + 
    geom_point(aes(x = lon, y = lat, color = commens),
               data = trimmed_tracks,
               size = 0.2, alpha = 0.7) +
    scale_color_gradient(low="white", high = "red")+
    geom_point(aes(x = -118.2, y = 33.85), color = "black", size = 2) +
    geom_text(aes(x = -118, y = 33.95), label = "Los \nAngeles") +
    geom_text(aes(x = -119.5, y = 33.8), label = "ANIS", color = 'white') +
    geom_text(aes(x = -119, y = 33.7), label = "SBIS", color = "white") +
    theme_minimal() +
    theme(
      panel.background = element_rect(fill = "gray10", color = NA), # Darker background
      plot.background = element_rect(fill = "gray25", color = NA), # Darker plot area
      panel.grid = element_blank(),
      legend.position = "right", # Added legend position
      legend.background = element_rect(fill = "gray25", color = NA),
      legend.text = element_text(color = "white"),
      legend.title = element_text(color = "white"),
      axis.text = element_text(color = "white"),
      axis.title = element_blank(),
      plot.title = element_text(color = "white"),
      plot.subtitle = element_text(color = "white")
    ) +
    labs(title = "Western gull tracks",
         subtitle = "foraging behavior",
         color = "urban:wild") 

bothis_plot
#ggsave('island_tracks.png', bothis_plot)
#### anacapa

anacapa_tracks <- trimmed_tracks %>% filter(island=="AN")

an_bbox <- st_bbox(c(xmin = -119.8, ymin = 33.8, xmax = -118.1, ymax = 34.5), crs = st_crs(is))


# Crop the coastline to the bounding box
is_crop <- st_crop(is, an_bbox)
cal_crop <- st_crop(cal,an_bbox)
ocean_crop <- st_crop(ocean,an_bbox)



anis_plot <-  ggplot() +
  geom_sf(data = is_crop, fill = "darkgreen", color = "lightgreen", alpha = 0.5) + 
  geom_sf(data = cal_crop, fill = "darkgoldenrod", color = "gold", alpha = 0.5) + 
  geom_point(aes(x = lon, y = lat, color = commens),
             data = anacapa_tracks,
             size = 0.2, alpha = 0.7) +
  scale_color_gradient(low="white", high = "red")+
#  geom_point(aes(x = -118.2, y = 33.85), color = "black", size = 2) +
 # geom_text(aes(x = -118, y = 33.95), label = "Los \nAngeles") +
  theme_minimal() +
  theme(
    panel.background = element_rect(fill = "gray10", color = NA), # Darker background
    plot.background = element_rect(fill = "gray25", color = NA), # Darker plot area
    panel.grid = element_blank(),
    legend.position = "right", # Added legend position
    legend.background = element_rect(fill = "gray25", color = NA),
    legend.text = element_text(color = "white"),
    legend.title = element_text(color = "white"),
    axis.text = element_text(color = "white"),
    axis.title = element_blank(),
    plot.title = element_text(color = "white"),
    plot.subtitle = element_text(color = "white")
  ) +
  labs(title = "Western gull tracks (Anacapa island)",
       subtitle = "foraging behavior",
       color = "urban:wild") 
anis_plot


#### SB Island 
sb_tracks <- trimmed_tracks %>% filter(island=="SB")

sb_bbox <- st_bbox(c(xmin = -119.55, ymin = 33.2, xmax = -117.9, ymax = 34), crs = st_crs(is))


# Crop the coastline to the bounding box
is_crop <- st_crop(is, sb_bbox)
cal_crop <- st_crop(cal,sb_bbox)
ocean_crop <- st_crop(ocean,sb_bbox)



sbis_plot <-  ggplot() +
  geom_sf(data = is_crop, fill = "darkgreen", color = "lightgreen", alpha = 0.5) + 
  geom_sf(data = cal_crop, fill = "darkgoldenrod", color = "gold", alpha = 0.5) + 
  geom_point(aes(x = lon, y = lat, color = commens),
             data = sb_tracks,
             size = 0.2, alpha = 0.7) +
  scale_color_gradient(low="white", high = "red")+
  #geom_point(aes(x = -118.2, y = 33.85), color = "black", size = 2) +
 # geom_text(aes(x = -118, y = 33.95), label = "Los \nAngeles") +
  theme_minimal() +
  theme(
    panel.background = element_rect(fill = "gray10", color = NA), # Darker background
    plot.background = element_rect(fill = "gray25", color = NA), # Darker plot area
    panel.grid = element_blank(),
    legend.position = "right", # Added legend position
    legend.background = element_rect(fill = "gray25", color = NA),
    legend.text = element_text(color = "white"),
    legend.title = element_text(color = "white"),
    axis.text = element_text(color = "white"),
    axis.title = element_blank(),
    plot.title = element_text(color = "white"),
    plot.subtitle = element_text(color = "white")
  ) +
  labs(title = "Western gull tracks (SB island)",
       subtitle = "foraging behavior",
       color = "urban:wild") 
sbis_plot



