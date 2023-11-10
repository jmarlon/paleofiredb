#==============================================================================#
# terra_intro.R ####
#==============================================================================#
# This script walks through how to: 
## Load a NetCDF file into R as a raster
## Load a shapefile into R as an sf obect
## Project a raster file to a crs
## Convert a dataframe with latitude and longitude into an sf object with point data
## Convert sf objects to SpatVectors
## Convert raster objects to SpatRasters
## Project SpatVectors and SpatRasters using terra
## Intersect point vector data with raster data using terra
## Intersect point vector data with polygon vector data using terra

# NOTE: Most of these datapaths are fake, just examples! 
# Please update with your own data!

# Last modified: November 8, 2023, EG
#==============================================================================#
# Load Libraries ####
#==============================================================================#
rm(list=ls())

library(sf)
library(terra)
library(raster)
library(tidyverse)
#==============================================================================#
# Load Data ####
#==============================================================================#
# Load NetCDF in as a raster brick
## first argument is file path & file with extension
## second argument is the variable name that you want to be presented in the raster
raster <- raster::brick(paste0("~/Dropbox (YSE)/ypcccdb/_data/external/usa/VULCAN/Vulcan_V3_Annual_Emissions_1741/data/Vulcan_v3_US_annual_1km_total_mn.nc4"), 
                     varname="carbon_emissions")

# Load shapefile as an sf object
## first argument is the file path
## second argument is the file name WITHOUT the .shp extension
shape <- sf::read_sf(dsn = "~/GitHub/ypccc_us/scripts_raghu/_data/", 
                 layer = "example_shapefile")

# Load csv with lat/long coordinates
data <- read.csv("~/GitHub/ypccc_us/_data/xwalks/usa/temp/data.csv")

#==============================================================================#
# Convert Data Types ####
#==============================================================================#
# Convert dataframe to sf object
## first argument is dataframe
## coords are the names of the longitude and latitude columns
## crs is the coordinate reference system to be used
data_sf <- sf::st_as_sf(data, coords = c("longitude", "latitude"), 
                        crs = 4269, agr = "constant")
# 4326 is the coordinate reference system for WGS84
# 4269 is the coordinate reference system for NAD83

# Convert raster data to SpatRaster
spatrast <- terra::rast(raster)

# Convert raster data to SpatExtent
spatext <- terra::ext(raster)

# Convert sf object to SpatVector
spatvect_poly <- terra::vect(shape)
spatvect_point <- terra::vect(data_sf)

#==============================================================================#
# Project Data ####
#==============================================================================#
# Project raster data BEFORE converting it to a SpatRaster
## first argument is raster data
## crs is the coordinate reference system to be used
raster_project <- raster::projectRaster(raster, crs="EPSG:4269")
# 4326 is the coordinate reference system for WGS84
# 4269 is the coordinate reference system for NAD83

# Project raster data as a SpatRaster
rast_proj <- terra::project(spatrast,"epsg:4326")

# Project vector data as a SpatVector
vect_poly_proj <- terra::project(spatvect_poly,"epsg:4326")
vect_point_proj <- terra::project(spatvect_point,"epsg:4326")

# Check the Coordinate Reference Systems of SpatVector and SpatRaster objects
terra::crs(rast_proj)
terra::crs(vect_poly_proj)
terra::crs(vect_point_proj)

#==============================================================================#
# Modify and Merge Data using Terra ####
#==============================================================================#
# Intersect points with raster data
point_rast <- terra::intersect(vect_point_proj,spatext)

# Intersect points with polygon data
point_poly <- terra::intersect(vect_point_proj,vect_poly_proj)

# Change data back to sf objects 
point_rast_sf <- sf::st_as_sf(point_rast)
point_poly_sf <- sf::st_as_sf(point_poly)

#==============================================================================#
# END OF FILE ####
#==============================================================================#
