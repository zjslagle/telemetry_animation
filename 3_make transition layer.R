source("2_map - setup.R")


### Make bounding boxes      #################
bound_box <- sf_detections %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>% st_bbox()
boundary_size = 0.1 # use this to adjust how big the map is around the bounding box

### Reduce size of simple features for faster animations   ###############
bigger_frame <- c(bound_box[c(1,2)]-.5, bound_box[c(3,4)]+.5) # add/subtract 0.1 to above bounding box
bigger_frame <- st_bbox(bigger_frame) %>%
  st_as_sfc() %>% 
  st_set_crs(4326) %>%
  st_transform(crs = 32617)


land_clip <- st_transform(us_and_can, crs = 32617) %>% 
  st_intersection(bigger_frame)
lake_clip <- st_transform(lake_erie, crs = 32617) %>% 
  st_intersection(bigger_frame)
receivers_clip <- st_transform(sf_receivers, crs = 32617) %>% 
  st_intersection(bigger_frame)

# transform back to WGS 84
land_clip <- st_transform(land_clip, crs = 4326)
lake_clip <- st_transform(lake_clip, crs = 4326)
receivers_clip <- st_transform(receivers_clip, crs = 4326)


### Make Transition layer    ##################################
# make transition layer with shapefile. res = resolution (units = degrees with this shapefile)
# provide receiver_points so the receivers are forced to be in water
map_transition <- make_transition(poly = lake_clip,
                                         receiver_points = receivers_clip,
                                         res = c(0.001, 0.001))

# save transition layer (so we don't have to do it every time)
saveRDS(map_transition, "data derived/map_transition.rds")

# doublecheck how it looks
mapview(map_transition$rast)+mapview(lake_clip)
