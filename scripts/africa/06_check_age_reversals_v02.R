# 06_check_age_reversals:  check of age (or sequence number) reversals  
# Loop over entities 

# open the debug/log file
# close(debug_file)
debug_file <- file(paste(debug_path, "age_reversal_debug.txt", sep=""), "w")

# j <- 664,
for (j in 1:nentities) {
# for (j in 1479:1479) {

  jchar <- str_pad(as.character(j), 4, "left", pad = 0)
  entity_char <- as.character(entity2$ID_ENTITY[j])
  namechar <- entity2$entity_name[j]
  
  # # get entity_id string
  entity_id <- str_pad(entity_char, 4, "left", pad = 0)
  
  nsamples <- 0
  entity_data <- sample2[sample2$ID_ENTITY == entity$ID_ENTITY[j], ]
  nsamples <- length(entity_data$ID_ENTITY)
  nsampchar <- as.character(nsamples)
  print (paste(jchar, "Entity", entity_id, nsampchar, "samples", namechar, sep=" "))
  
  # number of chronologies
  nchron <- 0
  if (!is.na(entity_data$ID_MODEL_original_est_age[1])) nchron <- nchron + 1
  if (!is.na(entity_data$ID_MODEL_new_age[1])) nchron <- nchron + 1
  nchronchar <- as.character(nchron)
  writeLines(paste("Entity ", entity_id, " (j=", jchar, ") ", nsampchar, " samples ", nchronchar, " chron(s) ", entity$TYPE[j], " ", 
    namechar, sep=""), con = debug_file, sep = "\n")
  
  # replace -999999's etc.
  entity_data$age <- replace(entity_data$age, entity_data$age == -999999, NA)
  entity_data$age <- replace(entity_data$age, entity_data$age == -777777, NA)
  
  if (nsamples == 0) {
    writeLines(paste("    Has no samples...", sep=""), con = debug_file, sep = "\n")
    writeLines(" ", con = debug_file, sep = "\n")
  }
  
  if (nsamples > 0) {
    
    no_age = FALSE
    if (all(is.na(entity_data$age))) no_age <- TRUE
    if (no_age) writeLines(paste("    Has no ages...", sep=""), con = debug_file, sep = "\n")
    
    # work on this entity
    # check original_est_age
    monotonic_age <- FALSE
    monotonic_age <- all(entity_data$original_est_age == cummax(entity_data$original_est_age), na.rm = TRUE)
    if (!monotonic_age) {
      writeLines(paste("    Age reversal, (original_est_age)", sep=""), con = debug_file, sep = "\n")
      writeLines("    i  sample(i-1)   depth(i-1) age(i-1)  sample(i)     depth(i)   age(i)", con = debug_file, sep = "\n")
      for (i in 2:nsamples) {
        if (!is.na(entity_data$original_est_age[i])) {
          if (entity_data$original_est_age[i] <= entity_data$original_est_age[i-1]) {
            text <- paste(
              sprintf("%5.0f", i), 
              sprintf("%8.0f", entity_data$ID_SAMPLE[i-1]), sprintf("%12.4f", entity_data$avg_depth[i-1]), sprintf("%8.0f", entity_data$original_est_age[i-1]), 
              sprintf("%12.0f", entity_data$ID_SAMPLE[i]), sprintf("%12.4f", entity_data$avg_depth[i]), sprintf("%8.0f", entity_data$original_est_age[i]) )
            writeLines(text, con = debug_file, sep = "\n")
          }
        }
      }
    }
    # end check original_est_age
  
    # check mean_new_age 
    if (!is.na(entity_data$ID_MODEL_new_age[1])) {
      monotonic_age <- FALSE
      monotonic_age <- all(entity_data$mean_new_age == cummax(entity_data$mean_new_age), na.rm = TRUE)
      if (!monotonic_age) {
        writeLines(paste("    Age reversal, (mean_new_age)", sep = ""), con = debug_file, sep = "\n")
        writeLines("    i  sample(i-1)   depth(i-1) age(i-1)  sample(i)     depth(i)   age(i)", con = debug_file, sep = "\n")
        for (i in 2:nsamples) {
          if (!is.na(entity_data$mean_new_age[i]) & !is.na(entity_data$mean_new_age[i-1])) {
            if (entity_data$mean_new_age[i] <= entity_data$mean_new_age[i-1]) {
              text <- paste(
                sprintf("%5.0f", i),
                sprintf("%8.0f", entity_data$ID_SAMPLE[i-1]), sprintf("%12.4f", entity_data$avg_depth[i-1]), sprintf("%8.0f", entity_data$mean_new_age[i-1]),
                sprintf("%12.0f", entity_data$ID_SAMPLE[i]), sprintf("%12.4f", entity_data$avg_depth[i]), sprintf("%8.0f", entity_data$mean_new_age[i]) )
              writeLines(text, con = debug_file, sep = "\n")
            }
          }
        }
      }
    }
    # end check mean_new_age
    
    # check median_new_age
    if (!is.na(entity_data$ID_MODEL_new_age[1])) {
      monotonic_age <- FALSE
      monotonic_age <- all(entity_data$median_new_age == cummax(entity_data$median_new_age), na.rm = TRUE)
      if (!monotonic_age) {
        writeLines(paste("    Age reversal, (median_new_age)", sep = ""), con = debug_file, sep = "\n")
        writeLines("    i  sample(i-1)   depth(i-1) age(i-1)  sample(i)     depth(i)   age(i)", con = debug_file, sep = "\n")
        for (i in 2:nsamples) {
          if (!is.na(entity_data$median_new_age[i]) & !is.na(entity_data$median_new_age[i-1])) {
            if (entity_data$median_new_age[i] <= entity_data$median_new_age[i-1]) {
              text <- paste(
                sprintf("%5.0f", i),
                sprintf("%8.0f", entity_data$ID_SAMPLE[i-1]), sprintf("%12.4f", entity_data$avg_depth[i-1]), sprintf("%8.0f", entity_data$median_new_age[i-1]),
                sprintf("%12.0f", entity_data$ID_SAMPLE[i]), sprintf("%12.4f", entity_data$avg_depth[i]), sprintf("%8.0f", entity_data$median_new_age[i]) )
              writeLines(text, con = debug_file, sep = "\n")
            }
          }
        }
      }
    }
    # end check median_new_age
    
    # check non-sequential sequence numbers (suggests duplicate entities)
    sequential <- FALSE
    sequential <- all(diff(entity_data$seqnum) <= 1)
    if (!sequential) {
      writeLines(paste("    Non-sequential sequence numbers", sep=""), con = debug_file, sep = "\n")
      # writeLines("    i  seqnum(i-1) sample(i-1)   depth(i-1) age(i-1)  seqnum(i)    sample(i)     depth(i)   age(i)", con = debug_file, sep = "\n")
      # for (i in 2:nsamples) {
      #     if (entity_data$seqnum[i] != entity_data$seqnum[i-1] + 1) {
      #       text <- paste(
      #         sprintf("%5.0f", i),
      #         sprintf("%8.0f", entity_data$seqnum[i-1]), sprintf("%11.0f", entity_data$ID_SAMPLE[i-1]), sprintf("%12.4f", entity_data$avg_depth[i-1]),
      #           sprintf("%8.0f", entity_data$original_est_age[i-1]),
      #         sprintf("%12.0f", entity_data$seqnum[i]), sprintf("%12.0f", entity_data$ID_SAMPLE[i]), sprintf("%12.4f", entity_data$avg_depth[i]),
      #           sprintf("%8.0f", entity_data$original_est_age[i]) )
      #       writeLines(text, con = debug_file, sep = "\n")
      #     }
      # }
    }
    # end check original_est_age
    
  writeLines(" ", con = debug_file, sep = "\n")
  }
}

close(debug_file)


