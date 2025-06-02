
source("1_load data.R")
sf_use_s2(FALSE)


### read in shapefiles   ###################################
us_and_can = st_read("data sources/shapefiles/ne_10m_admin_1_states_provinces.shp")%>% 
  filter(gu_a3 == "CAN"|gu_a3 == "USA")
lakes = st_read("data sources/shapefiles/Lake_Erie_Shoreline.shp", sep = "")
# IMPORTANT: use your own shapefile for your lake/river system; natural earth doesn't have any shapefiles
#           with fine enough scale

# make larger bounding box for clipping areas that we don't need to animate (makes it faster)
    # use this website to make it easy; select "CSV" in bottom left for formatted bounding pts
bigger_bounds <- st_bbox(c(xmin = -83.091817, ymin = 41.487468, xmax = -82.320714, ymax = 41.931888)) %>% 
  st_as_sfc() %>% st_set_crs(4326)

# make smaller bounding box for actual animation
erie_bounds = c(xmin = -82.994313, ymin = 41.557384, xmax = -82.519841, ymax = 41.876184)
erie_bounds = st_bbox(erie_bounds) %>% #create new polygon of bounding box for inset map
  st_as_sfc() %>% 
  st_set_crs(4326)

### Make Simple Feature for acoustic receivers   ################################
# create SF of receivers
sf_receivers <- data_receivers %>%
  mutate(deploy_date = date(deploy_date_time)) %>% 
  st_as_sf(coords = c("deploy_long", "deploy_lat"), crs = 4326)


##### summarize individual fish movements with points and lines between them   ##############################

# join tagged location and detected locations, make SF
data_detections <- data_detections %>%
  mutate(type = "detection") %>%
  full_join(data_tagging %>% filter(!is.na(deploy_lat))) %>% #join in locations tagged
  group_by(animal_id) %>%
  arrange(animal_id, detection_timestamp_utc) %>% 
  dplyr::select(animal_id, detection_timestamp_utc, detection_date, deploy_lat, deploy_long, receiver_sn, type) %>% 
  unique() %>%
  mutate(month_year = paste(month(detection_date, label = TRUE, abbr = TRUE), year(detection_date))) 

sf_detections <- data_detections %>%
  st_as_sf(coords = c("deploy_long", "deploy_lat"), crs = 4326) %>% #make sf
  arrange(animal_id, detection_date) #sort by date

# Check and see how these turned out
mapview(lake_erie)+mapview(sf_detections)
