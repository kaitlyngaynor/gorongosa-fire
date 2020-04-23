library(tidyverse)
library(raster)
library(sp)

# import and tidy camera locations
camera_locs <- read_csv("cam_metadata_norm_031519.csv") %>% 
    dplyr::select(StudySite, Latitude, Longitude) %>% 
    rename(Site = "StudySite") %>% 
    mutate(LocationType = "Camera")

# import and tidy Maria plot locations
site_locs <- read_csv("site coords.csv") %>% 
    rename(Latitude = "Lat", Longitude = "Long", Site = "Plot No") %>% 
    mutate(LocationType = "Plot", Site = as.factor(Site))

# combine all locations
all_locs <- bind_rows(camera_locs, site_locs)

# quick plot to make sure that Maria's sites fall within the camera grid (they do)
plot(Latitude ~ Longitude, data = all_locs)

# convert GPS coordinates to UTM
locations <- all_locs[, c('Longitude', 'Latitude')] %>%  # take the two columns with coordinates in them
    SpatialPoints(proj4string=CRS("+proj=longlat +ellps=WGS84")) %>%  # Create spatial points
    spTransform(CRS("+proj=utm +south +zone=36 +ellps=WGS84")) %>%  # convert to UTM
    coordinates() # take coordinates of these points

# bring in all rasters

# first import all files in a single folder as a list 
rastlist <- list.files(path = "~/Documents/github-repos/gorongosa/gorongosa-camera-traps/gis/Rasters for stacking/Masked rasters",
                       pattern='.tif$', all.files=TRUE, full.names=FALSE)

# import rasters into raster stack
raster_stack <- raster::stack(paste0("~/Documents/github-repos/gorongosa/gorongosa-camera-traps/gis/Rasters for stacking/Masked rasters/", rastlist))

# extract raster values
raster_values <- raster::extract(raster_stack, locations) 

# merge with the original files imported earlier
data_all_rasters <- cbind(all_locs, raster_values) # combine with camera names and locations

# rename
data_all_rasters_rename <- rename(data_all_rasters,
                                  boundary_dist = "boundary.dist.mask",
                                  chitengo_dist = "chitengo.dist.mask",
                                  fire_frequency = "fire.crop.res.mask",
                                  fire_2014 = "fire2014.crop.res.mask",
                                  fire_2015 = "fire2015.crop.res.mask",
                                  fire_2016 = "fire2016.crop.res.mask",
                                  fire_2017 = "fire2017.crop.res.mask",
                                  fire_2018 = "fire2018.crop.res.mask",
                                  pans_100m = "pans.crop.100m.res.mask",
                                  pans_250m = "pans.crop.250m.res.mask",
                                  pans_500m = "pans.crop.500m.res.mask",
                                  pans_1km = "pans.crop.1km.res.mask",
                                  pans_conservative_250m = "panscon.offflood.250m.mask",
                                  pans_large_250m = "panslarge.250m.mask",
                                  pans_dist = "pans.dist.mask",
                                  river_dist = "rivers.dist.mask",
                                  road_dist = "road.dist.mask",
                                  road_major_dist = "roadsmajor.dist.mask",
                                  settlement_dist = "settlement.dist.mask",
                                  termites_100m = "termites.crop.100m.mask",
                                  termites_250m = "termites.crop.250m.mask",
                                  termites_500m = "termites.crop.500m.mask",
                                  termites_1km = "termites.crop.1km.mask",
                                  tree_100m = "tree.crop.100m.res.mask",
                                  tree_250m = "tree.crop.250m.res.mask",
                                  tree_500m = "tree.crop.500m.res.mask",
                                  tree_1km = "tree.crop.1km.res.mask",
                                  tree_hansen = "tree.hansen.crop.res.mask",
                                  urema_dist = "urema.dist.mask"
                                   )

names(data_all_rasters_rename)

# export
write.csv(data_all_rasters_rename, "raster_values_extracted.csv", row.names = F)
