# 06_chron_plots:  Loop over entities, plotting charcoal_measurement and age vs depth   

# open the debug/log file
# close(debug_file)
debug_file <- file(paste(debug_path, "chron_plots_debug.txt", sep=""), "w")

# j <- 2
for (j in 1:nentities) {
# for (j in 1:15) {

  jchar <- as.character(j)
  entity_char <- as.character(entity2$ID_ENTITY[j])
  namechar <- entity2$entity_name[j]
  
  # fixup: drop entities with no data at all
  if (entity2$ID_ENTITY[j] == 1934) {
    writeLines("Dropped observation with no data", con = debug_file, sep = "\n")
    next
  }
  
  # # get entity_id string
  entity_id <- str_pad(entity_char, 4, "left", pad = 0)
  
  nsamples <- 0
  entity_data <- sample2[sample2$ID_ENTITY == entity$ID_ENTITY[j], ]
  nsamples <- length(entity_data$ID_ENTITY)
  nsampchar <- as.character(nsamples)
  print (paste(jchar, "Entity", entity_id, nsampchar, "samples", namechar, sep=" "))
  writeLines(paste(jchar, "Entity", entity_id, nsampchar, "samples", namechar, sep=" "), con = debug_file, sep = "\n")
  writeLines(paste("entity type is", entity$TYPE[j], sep=" "), con = debug_file, sep = "\n")
  
  if (nsamples > 0) {
    
    # work on this entity
    
    # local variables (for this entity)
    samplenum <- seq(1, nsamples, by = 1)
    id_entity <- entity_data$ID_ENTITY
    id_sample <- entity_data$ID_SAMPLE
    data_type <- entity_data$TYPE
    depth <- entity_data$avg_depth 
    age <- entity_data$age
    quant <- entity_data$charcoal_measurement
    thickness <- entity_data$sample_thickness
    original_est_age <- entity_data$original_est_age
    mean_new_age <- entity_data$mean_new_age
    median_new_age <- entity_data$median_new_age
    
    # replace missing values with NAs
    depth <- replace(depth, depth == -999999, NA); depth <- replace(depth, depth == -777777, NA)
    age <- replace(age, age == -999999, NA); age <- replace(age, age == -777777, NA)
    quant <- replace(quant, quant == -999999, NA);   quant <- replace(quant, quant == -777777, NA)
    thickness <- replace(thickness, thickness == -999999, NA);   thickness <- replace(thickness, thickness == -777777, NA)
    original_est_age <- replace(original_est_age, original_est_age == -999999, NA);   original_est_age <- replace(original_est_age, original_est_age == -777777, NA)
    mean_new_age <- replace(mean_new_age, mean_new_age == -999999, NA);   mean_new_age <- replace(mean_new_age, mean_new_age == -777777, NA)
    median_new_age <- replace(median_new_age, median_new_age == -999999, NA);   median_new_age <- replace(median_new_age, median_new_age == -777777, NA)
    
    # convert depth and thickness to centimeters
    depth <- depth * 100.0 
    
    # fixups
    # if all depths are NA, generate pseudo 1-cm increment depths
    if (all(is.na(depth))) {
      depth <- seq(1, nsamples, by = 1) / 100.0
      writeLines("All depths = NA, replaced by 1-cm psuedo depths", con = debug_file, sep = "\n")
    }

    # if all depths are 0.0, generate pseudo 1-cm increment depths
    if (all(depth == 0.0)) {
      depth <- seq(1, nsamples, by = 1) / 100.0
      writeLines("All depths = 0, replaced by 1-cm psuedo depths", con = debug_file, sep = "\n")
    }

    if (entity$TYPE[j] == "concentration") {
      if (any(quant < 0.0, na.rm = TRUE)) {
        quant[quant < 0.0] <- 0.0
        writeLines("concentration values < 0.0 replaced by 0.0", con = debug_file, sep = "\n")
      }
    }
      
    # drop observations with age = NA, check age last
    if (sum(!is.na(age)) != nsamples) {
      writeLines("Dropped observation with age = NA", con = debug_file, sep = "\n")
      next
    }
    
    # also drop observations with no characoal
    if (sum(!is.na(quant)) != nsamples) {
      writeLines("Dropped observation with age = NA", con = debug_file, sep = "\n")
      next
    }

    
    samplenum <- samplenum[!is.na(age)]
    id_entity <- id_entity[!is.na(age)]
    id_sample <- id_sample[!is.na(age)]
    data_type <- data_type[!is.na(age)]
    depth <- depth[!is.na(age)]
    quant <- quant[!is.na(age)]
    thickness <- thickness[!is.na(age)]
    samplenum <- samplenum[!is.na(age)]
    chron01_age <- original_est_age[!is.na(age)]
    chron02_age_mean <- mean_new_age[!is.na(age)]
    chron02_age_median <- median_new_age[!is.na(age)]
    age <- age[!is.na(age)]
    
    nsamp <- length(age)
    
    # plots
    pdfname <- paste(chron_plots_path, entity_id, "_chron_plot.pdf", sep="")
    # plot the original data, histograms, and transformed data -- use one of the following and see dev.off() below
    pdf(file=pdfname,width=8.5, height=11.0)  # create a .pdf file of plots
    # windows(width=8.5, height=11.0)  # plot to the windows device (within R)
    
    # plot input data
    
    # plot map
    par(fig=c(0.0, .6, 0.25, .55))#, mar=c(3.1, 4.1, 2.1, 4.1)) # mar=c(2.1, 4.1, 2.1, 4.1))
    map("world", xlim=c(-180, 180), ylim=c(-90,90))
    xlon <- entity2$longitude[j]
    ylat <- entity2$latitude[j]
    points(entity2$longitude,entity2$latitude, pch=19, col="cornflowerblue", cex=.4)
    points(xlon,ylat, pch=19, col="red", cex=1.1)
    box()
    
    # plot data
    par(new = T, fig=c(0,1,.70,.95), mar=c(3.1, 4.1, 2.1, 4.1))
    plot(quant ~ age, xlim=c(max(age),-100), axes=F, mgp=c(2,0,0), col="gray50", 
         main=paste(entity_id, namechar, sep=" "), font.main=1, lab=c(10,5,5),
         ylab=entity$TYPE[j], xlab="Age", cex.lab=0.8, pch=16, cex=0.4, type="o")
    points(quant ~ chron01_age, pch = 16, cex = 0.3, col="black")
    lines(quant ~ chron01_age, lwd = 0.5, col="black")
    points(quant ~ chron02_age_mean, pch = 16, cex = 0.3, col="red")
    lines(quant ~ chron02_age_mean, lwd = 0.5, col="red")
    points(quant ~ chron02_age_median, pch = 16, cex = 0.3, col="blue")
    lines(quant ~ chron02_age_median, lwd = 0.5, col="blue")
    axis(1, cex.axis=0.8); axis(2, cex.axis=0.8); axis(4, cex.axis=0.8)
    
    # plot age as function of depth
    par(new = T, fig=c(0,1,.50,.75), mar=c(3.1, 4.1, 2.1, 4.1))
    plot(depth ~ age, xlim=c(max(age),-100), axes=F, mgp=c(2,0,0),
         font.main=1, lab=c(10,5,5), col="gray50",
         ylab="Depth", xlab="Age", cex.lab=0.8, pch=16, cex=0.5)
    points(chron01_age, depth, pch = 16, cex = 0.3, col="black")
    points(chron02_age_mean, depth, pch = 16, cex = 0.3, col="red")
    points(chron02_age_median, depth, pch = 16, cex = 0.3, col="blue")
    axis(1, cex.axis=0.8); axis(2, cex.axis=0.8); axis(4, cex.axis=0.8)
    legend("bottomleft", c("Chron 01 (original_est_age)", "Chron 02 (mean)", "Chron 02 (median)"), pch=16, col=c("black","red","blue"), cex = 0.7)
    
  }
  
  dev.off() # turn off the .pdf device (comment this line out if plotting to the windows device
 }

close(debug_file)


