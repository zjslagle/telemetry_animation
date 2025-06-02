source("2_map - setup.R")

# read in transition layer
map_transition <- readRDS("data derived/map_transition.rds")

# interpolate fish paths - makes daily paths between detection events
# use transition layer to get fish to avoid land
interp_points = interpolate_path(data_detections, # this was detects_w_releases
                                 trans = map_transition$transition,
                                 out_class = "tibble",
                                 lnl_thresh = 12, # threshold for linear/nonlinear interp - default = .9, 
                                 # needs to be high to not have them swim over land!
                                 int_time_stamp = (86400)) #time step for interpolation; 86400 sec = 1 day. 
                                        #May need to reduce step if fish jump across land (means )



# reformat path points 
interp_points <- interp_points %>%
  mutate(date = date(bin_timestamp),
         time_step = as.integer(date - min(date)+1),
         month = month(date, label = TRUE, abbr = FALSE),
         year = year(date),
         transmitter_id = substr(animal_id, 10, 15))

# did interpolate_paths work?
sf_interp_points <- interp_points %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

mapview(sf_interp_points)+mapview(map_transition$rast, maxpixels =  10035900)

#now save it so we don't have to redo this (until next receiver download)
saveRDS(interp_points, file = "data derived/interp_points.RDS")
