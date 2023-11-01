# The goal of this script is to use gridded classifications of ecoregions to define 
# regional groups of paleofire sites in the RPD for trend analysis of North American 
# wildfires since the last deglaciation 

# Pre-script requirements: 

# Pull all of the North America sites from the RPD and return their lat, lon 
# coordinates. For this I imagine we will use an SQL query to return entity ID, site 
# name, lat, lon filtering by the North America continent. Save this info as a csv file
# to read into this R script 

# Script breakdown: 

# Step 1: import a variety of gridded ecoregion datasets from netCDF, raster, or TIFF file 

# Step 2: Plot some maps of the various datasets as a first pass look

# Step 3: Import the site data from a csv file, use the coordinates to find the ecoregion
# classifications for each site by merging with the gridded ecoregion data 


# ============================= Setup Environment ============================= ####
rm(list = ls()) #This clears all variables in the environment 
cat("\014")  #Clear any junk out of the console window 
# Close all open plots
while (dev.cur() != 1) {
  dev.off()
}

library(stars)
library(ncdf4)
library(tidyverse)


date_str <- format(Sys.Date(), format = "%y%m%d") #Get today's date for saving plots 

# Set the working directory as the git repo local clone

wd <- "/Users/Nick/Google_Drive/RESEARCH_PROJECTS/NAmerica_wildfire_trends/git_repo/paleofiredb/scripts/north_america"
setwd(wd)

# ============================= Load in the Data ============================= ####

# Set the path of the netCDF files 
griddat_path <- "/Users/Nick/Google_Drive/RESEARCH_PROJECTS/NAmerica_wildfire_trends/Local_work/Region_classification/EcoClim_spatial_data/Thompson_2023/Agriddeddatabas/Thompson_and_others_2023_Atlas_data_release_netCDF_files"

# play with dynamic loading and naming later using a character array of file names 
# and putting them into a structure like griddat.bailey_eco, griddat.kuchler_eco, ...

# Set the file name of the netCDF and use the stars package to read the netCDF into 
# R as a stars object 
fname <- "Bailey_ecoregions_on_25km_grid.nc"
eco_grd.bailey <- read_stars(paste(griddat_path, fname, sep = "/"))

fname <- "WWF_ecoregions_on_25km_grid.nc"
eco_grd.wwf <- read_stars(paste(griddat_path, fname, sep = "/"))

# ========================= Explore Data Structure ========================== ####

# ----------------------------- Bailey Scheme ---------------------------------- # 
str(eco_grd.bailey)
summary(eco_grd.bailey) #This gives an easy to read list of the variable names 
st_dimensions(eco_grd.bailey) #Show the dimensions of the object 
st_crs(eco_grd.bailey) #Coordinate reference system of the object 

plot(eco_grd.bailey) # This plots the first layer which seems to be the site ID

# Pull out variables of interest 

eco_grd.bailey.glacial_ice <- eco_grd.bailey["Glacial_ice", ]
eco_grd.bailey.bor_for <- eco_grd.bailey["Tayga_(boreal_forests)", ]
eco_grd.bailey.all <- eco_grd.bailey["ALL_BAILEY_ECOREGIONS", ]

plot(eco_grd.bailey.glacial_ice)
plot(eco_grd.bailey.bor_for)
plot(eco_grd.bailey.all)

# Ahh okay I am starting to get this. So, there are three ecoregion classifications 
# in this data product. 
# (1) Bailey's ecoregions (Bailey, 1997, 1998)
# (2) WWF's ecoregions (Ricketts and others, 1999)
# (3) Kuchler's potential natural vegetation regions (Kuchler, 1985)

# Each has their own approach to how they classify the eco regions, and would need to 
# consult the pubs to see their decisions. NOTE: only (1) and (2) include Canada and 
# Alaska, (3) the Kuchler scheme only has the lower 48, which basically means we will 
# ignore it for now 

# Each ecoregion map is divided into three levels with increasing specificity in Bailey
# they are Domain, division, province; WWF is level 1, major habitat types, and ecoregion

# ------------------------------- WWF Scheme ----------------------------------- #

str(eco_grd.wwf)
summary(eco_grd.wwf) #This gives an easy to read list of the variable names 
st_dimensions(eco_grd.wwf) #Show the dimensions of the object 
st_crs(eco_grd.wwf) #Coordinate reference system of the object 

plot(eco_grd.wwf) # This plots the first layer which seems to be the site ID

# BIG NOTE: The wwf scheme includes a classification for "Lake_or_Rock_and_ice" 
# so if the RPD locations are mapped really well, then we might get results 
# of this variable when we do a grid search, we will need to find the nearest 
# neighbor that has a terrestrial ecosystem classification 







