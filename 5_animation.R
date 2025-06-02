source("2_map - setup.R")

#interpolated lines (must run 4_interpolate paths.R first)
interp_points <- readRDS(file = "data derived/interp_points.RDS")

# dimensions of animation, in inches
anim_width = 7
anim_height = 9

#### set up map - based on all fish static   #################################
# map title will be "year month" from this; "closest_state" is interpreted by gganimate as the date/time step
map_title = paste("{unique(interp_points$month[which(interp_points$time_step == closest_state)])}", #month
                       " ",
                       "{unique(interp_points$year[which(interp_points$time_step == closest_state)])}",
                  sep = "") #year

# make a test map and print it. 
map <- ggplot()+
  scale_x_continuous(limits = c(bound_box$xmin-boundary_size, bound_box$xmax+boundary_size))+
  scale_y_continuous(limits = c(bound_box$ymin-boundary_size, bound_box$ymax+boundary_size))+
  geom_sf(data = land_clip)+
  geom_sf(data = lake_clip, fill = "#c5dfed")+ #  #c5dfed = blue; change to "white" for best greyscale
  geom_sf(data = sf_receivers, shape = 21, fill = "darkgoldenrod1", size = 2, alpha = .6)+
  geom_point(data = interp_points,
             aes(x = longitude, y = latitude, # group is VERY important here - tells gganimate what to animate over
                 group = time_step, 
                 fill = animal_id),
             pch = 21, color = "black", size = 5)+
  scale_fill_viridis_d()+
  annotation_scale(unit_category = "imperial", # add scale bar
                   location = "br")+
  annotation_north_arrow(which_north = "true",  # add North arrow
                         height = unit(0.7, "cm"),
                         width = unit(0.7, "cm"),
                         pad_y = unit(0.75, "cm"),
                         location = "br")+
  theme(plot.title = element_text(size = 20, face = "bold"),
        axis.text = element_blank(), 
        axis.ticks = element_blank(), 
        axis.title = element_blank())+
  labs(title = map_title,
       fill = "Fish ID")

#inspect this map for issues. 
ggsave(map, filename = "figures/map - animation test.png",
       width = anim_width, height = anim_height, units = "in", dpi = 300)


### Animation - All fish ###########################################################################
# animation (w/ transition_states) needs number of frames to be similar to cols, otherwise will
#      give error about matching col numbers
interp_rows = interp_points %>% select(time_step) %>% unique %>% nrow()


#set up animation:
animated_setup <- map+
  transition_states(time_step, 
                    transition_length = 1,
                    wrap = FALSE,
                    state_length = 0)+ #default = 1
  enter_fade()+exit_fade()+
  ease_aes('cubic-in-out')

# nframes is VERY specific - start with X = nrows of unique(date) - above.
# nframes = (X * transition_length) + (X * state_length -1)

#create animation!
animated_map = animate(animated_setup, 
                       nframes = interp_rows,
                       fps = 10,
                       #start_pause = 20, 
                       #end_pause = 20,
                       width = anim_width,    # PNG setup
                       height = anim_height, 
                       units = "in",
                       renderer = magick_renderer(),
                       res = 300,
                       device = "png")  


#and save animation - may need to install magick package
anim_save("figures/animation - all fish.gif", 
          animation = animated_map)
