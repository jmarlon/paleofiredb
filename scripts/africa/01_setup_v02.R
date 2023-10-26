# 01_setup 

# data path
system_path <- "/Users/alialdous/Desktop/15/fire" # MacOS
# system_path <- "e:/Projects" # Windows
data_path <- "/africa/"

# set path to output .csv file
sample2_path <- paste(system_path, data_path, "sample2_and_entity2/", sep="")
# if the samples output folder does not exist, create it
dir.create(file.path(sample2_path), showWarnings=FALSE)
sample2_filename <- "rpd_sample2.csv"
sample2_file <- paste(sample2_path, sample2_filename, sep = "")

entity_list_path <- paste(system_path, data_path, "entity_lists/", sep="")
# if the entity_list output folder does not exist, create it
dir.create(file.path(entity_list_path), showWarnings=FALSE)
entity_list_filename <- "entity_list_all.csv"
entity_list_file <- paste(entity_list_path, entity_list_filename, sep = "")

entity_data_csv_path <- paste(system_path, data_path, "entity_data_csv/", sep="")
# if the entity_csv output folder does not exist, create it
dir.create(file.path(entity_data_csv_path), showWarnings=FALSE)

sedrate_csv_path <- paste(system_path, data_path, "sedrate_data_csv/", sep="")
# if the entity_csv output folder does not exist, create it
dir.create(file.path(sedrate_csv_path), showWarnings=FALSE)

chron_files_path <- paste(system_path, data_path, "chron_csv/", sep="")
# if the chron plots output folder does not exist, create it
dir.create(file.path(chron_files_path), showWarnings=FALSE)

chron_plots_path <- paste(system_path, data_path, "chron_plots/", sep="")
# if the chron plots output folder does not exist, create it
dir.create(file.path(chron_plots_path), showWarnings=FALSE)

sedrate_plots_path <- paste(system_path, data_path, "sedrate_plots/", sep="")
# if the sedrate plots output folder does not exist, create it
dir.create(file.path(sedrate_plots_path), showWarnings=FALSE)

trans_path <- paste(system_path, data_path, "trans_csv/", sep="")
# if the chron plots output folder does not exist, create it
dir.create(file.path(trans_path), showWarnings=FALSE)

prebin_path <- paste(system_path, data_path, "prebin_csv/", sep="")
# if the chron plots output folder does not exist, create it
dir.create(file.path(prebin_path), showWarnings=FALSE)

stats_path <- paste(system_path, data_path, "stats_csv/", sep="")
# if the chron plots output folder does not exist, create it
dir.create(file.path(stats_path), showWarnings=FALSE)

curves_path <- paste(system_path, data_path, "curves_csv/", sep="")
# if the chron plots output folder does not exist, create it
dir.create(file.path(curves_path), showWarnings=FALSE)

debug_path <- paste(system_path, data_path, "debug/", sep="")
# if the debug folder does not exist, create it
dir.create(file.path(debug_path), showWarnings=FALSE)
debug_filename <- "debug.txt"

# other setup
max_sites <- 2000
max_entities <- 3000
max_samples <- 300000
miss <- -999999

# general libraries

library(stringr)
library(maps)
