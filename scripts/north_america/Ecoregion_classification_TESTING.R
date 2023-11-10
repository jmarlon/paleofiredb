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
library(terra)
library(raster)
library(sf)
library(ncdf4)
library(tidyverse)


date_str <- format(Sys.Date(), format = "%y%m%d") #Get today's date for saving plots 

# Set the working directory as the git repo local clone
wd <- "/Users/Nick/Google_Drive/RESEARCH_PROJECTS/YALE_PALEOFIRE/NAmerica_wildfire_trends/git_repo/paleofiredb"
setwd(wd)

# ============================= Load in the Data ============================= ####

# ------------------- Load the netCDF files as stars objects -------------------- #

# Set the path of the netCDF files 
netcdf_dat_path <- "/Users/Nick/Google_Drive/RESEARCH_PROJECTS/YALE_PALEOFIRE/NAmerica_wildfire_trends/Local_work/Region_classification/EcoClim_spatial_data/Thompson_2023/Agriddeddatabas/Thompson_and_others_2023_Atlas_data_release_netCDF_files"
shape_dat_path <- "/Users/Nick/Google_Drive/RESEARCH_PROJECTS/YALE_PALEOFIRE/NAmerica_wildfire_trends/Local_work/Region_classification/RESOLVE_ecoregions_2017/Ecoregions2017"

# play with dynamic loading and naming later using a character array of file names 
# and putting them into a structure like griddat.bailey_eco, griddat.kuchler_eco, ...

# Set the file name of the netCDF and use the stars package to read the netCDF into 
# R as a stars object 
fname_bailey <- "Bailey_ecoregions_on_25km_grid.nc"
eco_grd.bailey <- read_stars(paste(netcdf_dat_path, fname_bailey, sep = "/"))

fname_wwf <- "WWF_ecoregions_on_25km_grid.nc"
eco_grd.wwf <- read_stars(paste(netcdf_dat_path, fname_wwf, sep = "/"))

# The stars object is proving difficult for me to understand how to manip. After 
# consulting with Emily Goddard (YPCCC) she suggested I just load the variable I
# want from the netCDF as raster data and use "terra" 

# Note: Emily's method used raster, which is being deprecated, just follow this 
# option for now, but if you want this code to stand the test of time, check Riley's
# powerpoint and or ask Carla's group about the terra version of raster::brick 

# Load in the Bailey "ALL_BAILEY_ECOREGIONS" variable using raster 
bailey_er_rast <- raster::brick(paste(netcdf_dat_path, fname_bailey, sep = "/"), 
                                varname = "ALL_BAILEY_ECOREGIONS")

# ADD THE WWF DATA HERE, BUT I AM NOT SURE IF SINGLE VAR FOR ALL OR JUST BY CLASSIFCATION BREAKDOWN

# Load in the from the RESOLVE [Dinerstein et al. (2017)] classification scheme shapefile 
fname_resolve <- "Ecoregions2017"

resolve_shp <- read_sf(dsn = shape_dat_path, layer = fname_resolve)

# ADD HERE THE CSV FILE OF THE NORTH AMERICAN SITES
# ASK ALI TO DO THIS 

# ------------- Load the csv meta data files as data frames objects ------------- #

csv_path <- "/Users/Nick/Google_Drive/RESEARCH_PROJECTS/NAmerica_wildfire_trends/Local_work/Region_classification/EcoClim_spatial_data/Thompson_2023/Agriddeddatabas/Thompson_and_others_2023_Atlas_data_release_csv_files"
fname <- "Ecoregions_and_Potential_Natural_Vegetation_on_25km_Grid.csv"

# Load a data frame that contains classifier information, each ecoregion at the 
# highest level of specificity has a unique identifier, this data frame will serve
# to connect the unique IDs with the lower level classifications

eco_info <- read.csv(paste(csv_path, fname, sep = "/"), header = TRUE)

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

# Lets take a peak at the "Lake_or_Rock_and_ice" map 
eco_grd.wwf.lake_roc_ice <- eco_grd.wwf["Lake_or_Rock_and_ice", ]

test_mat <- as.matrix(eco_grd.wwf.lake_roc_ice)

plot(eco_grd.wwf.lake_roc_ice)
 
# Peak at maps of some other vars 

eco_grd.wwf.upMidwest_forsav_trans <- eco_grd.wwf["Upper_Midwest_Forest_Savanna_Transition_Zone", ]
plot(eco_grd.wwf.upMidwest_forsav_trans)

# ==================== Create lower level region groups ===================== ####

# Lets start by sub-setting the eco_info data frame to only include the Bailey identifier info
# we will use this to plot groups 
bailey_info <- eco_info %>%
  select(BAILEY_IDENTIFIER, BAILEY_DOMAIN_.LEVEL_I., BAILEY_DIVISION_.LEVEL_II., 
         BAILEY_PROVINCE_.LEVEL_III.)

# Rename the variables to make this a bit cleaner 
bailey_info <- bailey_info %>%
  rename(
    id = BAILEY_IDENTIFIER,
    domain_i = BAILEY_DOMAIN_.LEVEL_I.,
    division_ii = BAILEY_DIVISION_.LEVEL_II.,
    province_iii = BAILEY_PROVINCE_.LEVEL_III.
  )

# Set up a key for the vegetation classes by ecoregion identifier 
veg_class_key <- bailey_info %>%
  distinct() %>% 
  arrange(id)

# Find unique names of each region type 
types.domain <- unique(bailey_info$domain_i)
types.division <- unique(bailey_info$division_ii)
types.province <- unique(bailey_info$province_iii)

# Create empty lists to hold the unique ecoregion identifiers for each of the 
# region types 

domain_list <- list()
division_list <- list()
province_list <- list()

# Loop through the domains and find the ecoregion ids for each domain
for (i in seq_along(types.domain)){
  
  # Filter for each domain type
  filt_dat <- bailey_info %>%
    filter(domain_i == types.domain[i]) %>%
    distinct(id)
  
  # Add the unique ids to the list 
  domain_list[[types.domain[i]]] <- filt_dat
}

# Loop through the divisions and find the ecoregion ids for each division
for (i in seq_along(types.division)){
  
  # Filter for each domain type
  filt_dat <- bailey_info %>%
    filter(division_ii == types.division[i]) %>%
    distinct(id)
  
  # Add the unique ids to the list 
  division_list[[types.division[i]]] <- filt_dat
}

# Loop through the province and find the ecoregion ids for each province
for (i in seq_along(types.province)){
  
  # Filter for each domain type
  filt_dat <- bailey_info %>%
    filter(province_iii == types.province[i]) %>%
    distinct(id)
  
  # Add the unique ids to the list 
  province_list[[types.province[i]]] <- filt_dat
}








# Convert the stars object to an sf object 
eco_grd_sf <- st_as_sf(eco_grd.bailey.all)

# # Perform a join of the eco_info df with the sf object to get the domain info for each ecoregion
# eco_grd_sf_joined <- left_join(eco_grd_sf, eco_info, by = c("ALL_BAILEY_ECOREGIONS" 
#                                                             = "BAILEY_IDENTIFIER"))
# ^^^ fails because in the sf object the ALL_BAILEY_ECOREGIONS has <units> while the BAILEY_IDENTIFIER
# in the data frame is <integer> 

# # Convert back to stars object 
# eco_grd_stars_joined <- st_as_stars(eco_grd_sf_joined)
# 
# # Plot the ecoregions grouped by domain 
# plot(eco_grd_stars_joined["BAILEY_DOMAIN_.LEVEL_I."], key.pos = 1, reset = FALSE,
#      main = "Ecoregions Grouped by Domain Level I")


# Extract the attribute as a vector (numeric) without units
all_bailey_ecoregions <- as.numeric(stars::st_get_dimension_values(eco_grd.bailey.all, 'ALL_BAILEY_ECOREGIONS'))

# Create a new data frame that matches ALL_BAILEY_ECOREGIONS with BAILEY_IDENTIFIER
matching_df <- data.frame(ALL_BAILEY_ECOREGIONS = all_bailey_ecoregions)

# Join the matching data frame with eco_info
joined_df <- left_join(matching_df, eco_info, by = c("ALL_BAILEY_ECOREGIONS" = "BAILEY_IDENTIFIER"))

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Assuming 'ALL_BAILEY_ECOREGIONS' is a raster layer inside 'eco_grd.bailey.all'
all_bailey_values <- eco_grd.bailey.all[["ALL_BAILEY_ECOREGIONS"]]

# Now you can convert this to a plain numeric vector if needed
all_bailey_values <- as.vector(all_bailey_values)

# Next, you'll want to make sure that your 'eco_info' dataframe is ready for joining
bailey_info$id <- as.integer(bailey_info$id)

# If 'all_bailey_values' is a matrix or array, you need to convert it to a vector and create a data frame
# You might also need to melt it if it's not already a long format data frame
matching_df <- data.frame(ALL_BAILEY_ECOREGIONS = all_bailey_values)

# Join the data frames
joined_df <- left_join(matching_df, bailey_info, by = c("ALL_BAILEY_ECOREGIONS" = "id"))

# Check the structure of the joined_df
str(joined_df)

# If your stars object is 2-dimensional, you can use st_as_sf to convert to an sf object for ggplot2
sf_eco_grd <- st_as_sf(eco_grd.bailey.all)

# Assuming joined_df is now a long-format data frame with a key to join with sf_eco_grd
sf_joined <- left_join(sf_eco_grd, joined_df, by = "ALL_BAILEY_ECOREGIONS")

# Now plotting with ggplot2
ggplot(sf_joined, aes(fill = BAILEY_DOMAIN_LEVEL_I)) +
  geom_sf() +
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(fill = "Domain Level I")





