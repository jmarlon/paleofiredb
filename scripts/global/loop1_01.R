# 5) Parse the samples table into individual data sets

# open the debug/log file
debug_file <- file(paste(debug_path, "debug.txt", sep=""), "w")

# j <- 2
for (j in 1:nentities) {
# for (j in 1:50) {

  jchar <- as.character(j)
  entity_char <- as.character(entity2$ID_ENTITY[j])
  namechar <- entity2$entity_name[j]
  if (entity2$skip[j] == 1) {
    writeLines(paste(jchar, "Skipping entity:", entity_char, sep=" "), con = debug_file, sep = "\n")
    writeLines(" ", con = debug_file, sep = "\n")
    next # cycle loop
  }
  
  nsamples <- 0
  entity_data <- sample2[sample2$ID_ENTITY == entity$ID_ENTITY[j], ]
  nsamples <- length(entity_data$ID_ENTITY)
  nsampchar <- as.character(nsamples)
  print (paste(jchar, "Entity", entity_char, nsampchar, "samples", namechar, sep=" "))
  writeLines(paste(jchar, "Entity", entity_char, nsampchar, "samples", namechar, sep=" "), con = debug_file, sep = "\n")
  
  if (nsamples > 0) {
  
   # work on this entity

   # local variables (for this entity)
   depth <- entity_data$avg_depth; age <- entity_data$age; quant <- entity_data$charcoal_measurement
   
   # replace missing values with NAs
   depth <- replace(depth, depth == -999999, NA); depth <- replace(depth, depth == -777777, NA)
   age <- replace(age, age == -999999, NA); age <- replace(age, age == -777777, NA)
   quant <- replace(quant, quant == -999999, NA);   quant <- replace(quant, quant == -777777, NA)
   
   # if all depths are NA, generate 1 cm increment depths
   if (all(is.na(depth))) depth <- seq(1, nsamples, by = 1)
   
   nmiss_depth <- as.character(sum(is.na(depth)))
   nmiss_age <- as.character(sum(is.na(age)))
   nmiss_quant <- as.character(sum(is.na(quant)))
   writeLines(paste("Missing: depth:", nmiss_depth, "age:", nmiss_age, "quant:", nmiss_quant, sep=" "), con = debug_file, sep = "\n")
  
   thickness <- rep(NA, nsamples); dep_time <- rep(NA, nsamples);
   sed_rate <- rep(NA, nsamples);  unit_dep_time <- rep(NA, nsamples)
  
   # sed rate and deposition time
   # first (top) sample
   if (!is.na(depth[1]) && !is.na(depth[2])) {
     thickness[1] <- (depth[2] - depth[1])*100.0 # meters to cm (depth in m, influx and conc in cm)
     dep_time[1] <- age[2] - age[1]
     if (dep_time[1] > 0.0 && !is.na(dep_time[1])) sed_rate[1] <- thickness[1]/dep_time[1]
     if (!is.na(sed_rate[1])) unit_dep_time[1] <- 1.0/sed_rate[1]
   }
   # samples 2 to nsamples-1
   for (i in 2:(nsamples-1)) {
     if (!is.na(depth[i]) && !is.na(depth[i + 1])) {
       thickness[i] <- (depth[i+1] - depth[i])*100.0
       dep_time[i] <- ((age[i+1] + age[i])/2.0) - ((age[i] + age[i-1])/2.0)
       if (dep_time[i] > 0.0 && !is.na(dep_time[i])) sed_rate[i] <- thickness[i]/dep_time[i]
       if (!is.na(!sed_rate[i])) unit_dep_time[i] <- 1.0/sed_rate[i]
     }
   }
   # last (bottom) sample
   if (!is.na(depth[nsamples-1]) && !is.na(depth[nsamples])) {
     thickness[nsamples] <- thickness[nsamples-1] # replicate thickness
     dep_time[nsamples] <- age[nsamples] - age[nsamples-1]
     sed_rate[nsamples] <- sed_rate[nsamples-1] # replicate sed_rate
     unit_dep_time[nsamples] <- unit_dep_time[nsamples-1]
   }
   # sample size
   sample_size <- as.numeric(entity_data$analytical_sample_size)
   
   # alternative quantities
   writeLines(paste("entity type", entity$TYPE[j], sep=" "), con = debug_file, sep = "\n")
   conc <- rep(NA, nsamples); influx <- rep(NA, nsamples)
   influx_source <- rep("none", nsamples) ; conc_source <- rep("none", nsamples)
  
   # select case based on entity$TYPE[j]
   
   if (entity$TYPE[j] == "concentration") {
     # adopt concentration values as they are, calculate influx
     writeLines("concentration block", con = debug_file, sep = "\n")
     conc <- quant
     conc_source <- "data"
     for (i in (1:nsamples)) {
       if (!is.na(conc[i]) && !is.na(sed_rate[i]) && sed_rate[i] != 0.0) {
         # influx[i] <- (quant[i] / sample_size[i]) * sed_rate[i]
         influx[i] <- quant[i] * sed_rate[i]
       }
     }
     influx_source <- "calculated from concentration"
     if (all(is.na(influx))) influx <- conc
     writeLines(paste("influx from", entity$TYPE[j], sep=" "), con = debug_file, sep = "\n")
   }

  else if (entity$TYPE[j] == "influx") {
    # adopt influx values as they are, calculate concentration
    writeLines("influx block", con = debug_file, sep = "\n")
    influx <- quant
    influx_source <- "data"
    for (i in (1:nsamples)) {
      if (!is.na(influx[i]) && !is.na(unit_dep_time[i]) && sed_rate[i] != 0.0) {
          conc[i] <- influx[i] * unit_dep_time[i]
      }
    }
    conc_source <- "calculated from influx "
    writeLines(paste("concentration from", entity$TYPE[j], sep=" "), con = debug_file, sep = "\n")
  }

  else {
    # adopt pollen concentration values as they are, calculate influx
    writeLines("other entity", con = debug_file, sep = "\n")
    conc <- quant
    conc_source <- "data"
    for (i in (1:nsamples)) {
     if (!is.na(conc[i]) && !is.na(sed_rate[i]) && sed_rate[i] != 0.0) {
       # influx[i] <- (quant[i] / sample_size[i]) * sed_rate[i]
       influx[i] <- quant[i] * sed_rate[i]
     }
    }
    influx_source <- paste("calculated from ", entity$TYPE[j], sep = "")
    if (all(is.na(influx))) influx <- conc
    influx_source <- "copied from conc"
    writeLines(paste("influx from", entity$TYPE[j], sep=" "), con = debug_file, sep = "\n")
  }

    # create and write an entity .csv file

   # get entity_id string
   if (entity2$ID_ENTITY[j] >= 1) entity_id <- paste("000", entity_char, sep="")
   if (entity2$ID_ENTITY[j] >= 10) entity_id <- paste("00", entity_char, sep="")
   if (entity2$ID_ENTITY[j] >= 100) entity_id <- paste("0", entity_char, sep="")
   if (entity2$ID_ENTITY[j] >= 1000) entity_id <- paste(    entity_char, sep="")
   entity_hdr <- paste("entity", entity_id, sep="")
   
   # assemble output data and write it out
   samplenum <- as.integer(seq(1:nsamples))
   outdata <- data.frame(samplenum, entity_data$ID_ENTITY, entity_data$ID_SAMPLE, depth, age, 
                         thickness, dep_time, sed_rate, unit_dep_time, 
                         quant, conc, influx, entity_data$TYPE, conc_source, influx_source)
   names(outdata) <- c(entity_hdr, "ID_ENTITY", "ID_SAMPLE", "depth", "age", 
                       "thickness", "dep_time", "sed_rate", "unit_dep_time", 
                       "quant", "conc", "influx", "TYPE", "conc_source", "influx_source" )
   csvfile <- paste(entity_data_csv_path, entity_id, "_data.csv", sep="")
   write.csv(outdata, csvfile, row.names=FALSE)
   
   writeLines(" ", con = debug_file, sep = "\n")
  }
}

close(debug_file)

# write current entity2
entity_list2 <- entity2[entity2$skip == 0, ]

entity_list_filename <- "rpd_entity2.csv"
entity_list_file <- paste(entity_list_path, entity_list_filename, sep = "")
write.csv(entity_list2, file=entity_list_file, row.names = FALSE)

