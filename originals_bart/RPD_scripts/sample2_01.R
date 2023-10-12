# 2) create a "samples2" table, adding entity$TYPE, existing chronologies and new chronologies
# other setup
max_sites <- 2000
max_entities <- 3000
max_samples <- 300000
miss <- -999999

# paths and files
data_path <- "/Users/bartlein/Projects/RPD/RPDv1b/"

samples_path <- paste(data_path, "samples/", sep="")
# if the samples output folder does not exist, create it
dir.create(file.path(samples_path), showWarnings=FALSE)
samples_filename <- "rpd_sample2.csv"
samples_file <- paste(samples_path, samples_filename, sep = "")

entity_list_path <- paste(data_path, "entity_lists/", sep="")
# if the entity_list output folder does not exist, create it
dir.create(file.path(entity_list_path), showWarnings=FALSE)
entity_list_filename <- "entity_list_all.csv"
entity_list_file <- paste(entity_list_path, entity_list_filename, sep = "")

entity_csv_path <- paste(data_path, "entity_csv/", sep="")
# if the entity_csv output folder does not exist, create it
dir.create(file.path(entity_csv_path), showWarnings=FALSE)

debug_path <- paste(data_path, "debug/", sep="")
# if the debug folder does not exist, create it
dir.create(file.path(debug_path), showWarnings=FALSE)
debug_filename <- "debug.txt"

# copy sample table into sample2 table
summary(sample)
nsamples <- length(sample$ID_SAMPLE)
nsamples
sample2 <- sample
head(sample2)

nentities <- length(entity$ID_ENTITY)

# add entity$TYPE
sample2$TYPE <- as.character(rep(NA, nsamples))
for (j in (1:nentities)) {
  sample2$TYPE[sample2$ID_ENTITY == entity$ID_ENTITY[j]] <- entity$TYPE[j]
}

# length of existing chronology
nchron <- length(chronology$ID_SAMPLE)
nchron

# add original chronology
sample2$ID_MODEL_original_est_age <- as.integer(rep(NA, nsamples))
sample2$original_est_age <- as.numeric(rep(NA, nsamples))

chron_idx <- as.integer(rep(NA, nsamples))
chron_idx <- match(sample$ID_SAMPLE, chronology$ID_SAMPLE)
summary(chron_idx)

sample2$ID_MODEL_original_est_age <- chronology$ID_MODEL[chron_idx]
sample2$original_est_age <- chronology$original_est_age[chron_idx]
dim(sample2)

# add new chronology from age_model table
sample2$ID_MODEL_new_age <- as.integer(rep(NA, nsamples))
sample2$mean_new_age <- as.numeric(rep(NA, nsamples))	
sample2$median_new_age <- as.numeric(rep(NA, nsamples))	
sample2$UNCERT_5_new_age  <- as.numeric(rep(NA, nsamples))	
sample2$UNCERT_25_new_age	<- as.numeric(rep(NA, nsamples))
sample2$UNCERT_75_new_age	<- as.numeric(rep(NA, nsamples))
sample2$UNCERT_95_new_age <- as.numeric(rep(NA, nsamples))

chron_idx <- as.integer(rep(NA, nsamples))
chron_idx <- match(sample$ID_SAMPLE, age_model$ID_SAMPLE)
summary(chron_idx) 

sample2$ID_MODEL_new_age <- age_model$ID_MODEL[chron_idx]
sample2$mean_new_age <- age_model$mean[chron_idx]
sample2$median_new_age <- age_model$median[chron_idx]
sample2$UNCERT_5_new_age  <- age_model$UNCERT_5[chron_idx]
sample2$UNCERT_25_new_age	<- age_model$UNCERT_25[chron_idx]
sample2$UNCERT_75_new_age	<- age_model$UNCERT_75[chron_idx]
sample2$UNCERT_95_new_age <- age_model$UNCERT_95[chron_idx]

# use new chronology, otherwise adopt original chronology
sample2$chronology <- as.character(rep(NA, nsamples))
sample2$AGE_MODEL <- as.integer(rep(NA, nsamples))
sample2$age <- as.numeric(rep(NA, nsamples))	

sample2$chronology <- ifelse(!is.na(sample2$median), "RDPv1b", "original")
sample2$AGE_MODEL <- ifelse(!is.na(sample2$median), sample2$ID_MODEL_new_age, sample2$ID_MODEL_original_est_age)
sample2$age <- ifelse(!is.na(sample2$median), sample2$median_new_age, sample2$original_est_age)
sample2$chronology[sample2$age == -999999] <- "none"
sample2$chronology[sample2$age == -777777] <- "none"

# add a sequence number for each sample
sample2$seqnum <- as.integer(rep(NA, nsamples))
sample2$seqnum <- seq(1, nsamples, by = 1)

# summary(sample)
# summary(sample2)
# head(sample, 10)
# head(sample2, 10)

# write out the new table
write.csv(sample2, file=samples_file, row.names = FALSE)





