# 08_entity_data_and_sedrate 
# calculate sed rate in different ways

# open the debug/log file
# close(debug_file)
debug_file <- file(paste(debug_path, "entity_and_sedrate_debug.txt", sep=""), "w")

# j <- 2
for (j in 1:nentities) {
# for (j in 1:15) {

  jchar <- as.character(j)
  entity_char <- as.character(entity2$ID_ENTITY[j])
  namechar <- entity2$entity_name[j]
  if (entity2$skip[j] == 1) {
    writeLines(paste(jchar, "Skipping entity:", entity_char, namechar, sep=" "), con = debug_file, sep = "\n")
    writeLines(" ", con = debug_file, sep = "\n")
    next # cycle loop
  }
  
  # get entity_id string
  if (entity2$ID_ENTITY[j] >= 1) entity_id <- paste("000", entity_char, sep="")
  if (entity2$ID_ENTITY[j] >= 10) entity_id <- paste("00", entity_char, sep="")
  if (entity2$ID_ENTITY[j] >= 100) entity_id <- paste("0", entity_char, sep="")
  if (entity2$ID_ENTITY[j] >= 1000) entity_id <- paste(    entity_char, sep="")
  
  nsamples <- 0
  entity_data <- sample2[sample2$ID_ENTITY == entity$ID_ENTITY[j], ]
  nsamples <- length(entity_data$ID_ENTITY)
  nsampchar <- as.character(nsamples)
  print (paste(jchar, "Entity", entity_char, nsampchar, "samples", namechar, sep=" "))
  writeLines(paste(jchar, "Entity", entity_char, nsampchar, "samples", namechar, sep=" "), con = debug_file, sep = "\n")
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
    
    # replace missing values with NAs
    depth <- replace(depth, depth == -999999, NA); depth <- replace(depth, depth == -777777, NA)
    age <- replace(age, age == -999999, NA); age <- replace(age, age == -777777, NA)
    quant <- replace(quant, quant == -999999, NA);   quant <- replace(quant, quant == -777777, NA)
    thickness <- replace(thickness, thickness == -999999, NA);   thickness <- replace(thickness, thickness == -777777, NA)
    
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
    if (sum(!is.na(age)) != nsamples) writeLines("Dropped observation with age = NA", con = debug_file, sep = "\n")
    samplenum <- samplenum[!is.na(age)]
    id_entity <- id_entity[!is.na(age)]
    id_sample <- id_sample[!is.na(age)]
    data_type <- data_type[!is.na(age)]
    depth <- depth[!is.na(age)]
    quant <- quant[!is.na(age)]
    thickness <- thickness[!is.na(age)]
    samplenum <- samplenum[!is.na(age)]
    age <- age[!is.na(age)]
    
    nsamp <- length(age)
    
    # create sed rate-related variables
    # explicit sample_thickness variables in sample2
    thickness_01 <- rep(NA, nsamp); dep_time_01 <- rep(NA, nsamp);
    sed_rate_01 <- rep(NA, nsamp);  unit_dep_time_01 <- rep(NA, nsamp)
    # sed rate based on calculated thickness
    thickness_02 <- rep(NA, nsamp); dep_time_02 <- rep(NA, nsamp);
    sed_rate_02 <- rep(NA, nsamp);  unit_dep_time_02 <- rep(NA, nsamp)
    # sed rate based on smoothing spline differentiation
    thickness_03 <- rep(NA, nsamp); dep_time_03 <- rep(NA, nsamp);
    sed_rate_03 <- rep(NA, nsamp);  unit_dep_time_03 <- rep(NA, nsamp)
     
    # check for sample_thickness variable
    nthick <- sum(!is.na(entity_data$sample_thickness))
    print (nthick)
    has_thickness = FALSE
    if (nthick == nsamples) {
      writeLines(paste("Has explicit sample_thickness values"), con = debug_file, sep = "\n")
      has_thickness <- TRUE
      thickness_01 <- thickness * 100.0 } # note conversion metres to centimetres
  }
  print (has_thickness)
  
  nmiss_depth <- as.character(sum(is.na(depth)))
  nmiss_age <- as.character(sum(is.na(age)))
  nmiss_quant <- as.character(sum(is.na(quant)))
  writeLines(paste("Missing: depth:", nmiss_depth, "age:", nmiss_age, "quant:", nmiss_quant, sep=" "), con = debug_file, sep = "\n")
 
  # sed rate and deposition time
  # first (top) sample
  if (!is.na(depth[1]) && !is.na(depth[2])) {
    # sed rate method 1
      if (has_thickness) {
      dep_time_01[1] <- age[2] - age[1]
      if (dep_time_01[1] > 0.0 && !is.na(dep_time_01[1])) sed_rate_01[1] <- thickness_01[1]/dep_time_01[1]
      if (!is.na(sed_rate_01[1])) unit_dep_time_01[1] <- 1.0/sed_rate_01[1]
      }
    
    # sed rate method 2
    thickness_02[1] <- (depth[2] - depth[1]) # depth in cm, influx and conc in cm)
    dep_time_02[1] <- age[2] - age[1]
    if (dep_time_02[1] > 0.0 && !is.na(dep_time_02[1])) sed_rate_02[1] <- thickness_02[1]/dep_time_02[1]
    if (!is.na(sed_rate_02[1])) unit_dep_time_02[1] <- 1.0/sed_rate_02[1]
  }
  
  # samples 2 to nsamples-1
  for (i in 2:(nsamples-1)) {
    if (!is.na(depth[i]) && !is.na(depth[i + 1])) {
      # sed rate method 1
      if (has_thickness) {
        dep_time_01[i] <- ((age[i+1] + age[i])/2.0) - ((age[i] + age[i-1])/2.0)
        if (dep_time_01[i] > 0.0 && !is.na(dep_time_01[i])) sed_rate_01[i] <- thickness_01[i]/dep_time_01[i]
        if (!is.na(!sed_rate_01[i])) unit_dep_time_01[i] <- 1.0/sed_rate_01[i]
      }
      
      # sed rate method 2
      thickness_02[i] <- depth[i+1] - depth[i]
      dep_time_02[i] <- ((age[i+1] + age[i])/2.0) - ((age[i] + age[i-1])/2.0)
      if (dep_time_02[i] > 0.0 && !is.na(dep_time_02[i])) sed_rate_02[i] <- thickness_02[i]/dep_time_02[i]
      if (!is.na(!sed_rate_02[i])) unit_dep_time_02[i] <- 1.0/sed_rate_02[i]
    }
  }
  # last (bottom) sample
  if (!is.na(depth[nsamples-1]) && !is.na(depth[nsamples])) {
    # sed rate method 1
    if (has_thickness) {
      dep_time_01[nsamples] <- age[nsamples] - age[nsamples-1]
      sed_rate_01[nsamples] <- sed_rate_01[nsamples-1] # replicate sed_rate
      unit_dep_time_01[nsamples] <- unit_dep_time_01[nsamples-1]
    }
    
    # sed rate method 2
    thickness_02[nsamples] <- thickness_02[nsamples-1] # replicate thickness
    dep_time_02[nsamples] <- age[nsamples] - age[nsamples-1]
    sed_rate_02[nsamples] <- sed_rate_02[nsamples-1] # replicate sed_rate
    unit_dep_time_02[nsamples] <- unit_dep_time_02[nsamples-1]
  }
  
  # sed rate method 3
  spar = 0.2
  result <- try(smooth.spline(age, depth, spar = spar), silent=TRUE)
  if (class(result) != "try-error") {
    # fit the spline
    age_depth_spl <- smooth.spline(age, depth, spar = spar)
    age_depth_spl_pred <- predict(age_depth_spl, age, deriv = 1)
    sed_rate_03 <- age_depth_spl_pred$y
    thickness_03 <- thickness_02
    dep_time_03 <- thickness_03 / sed_rate_03
    unit_dep_time_03 <- 1.0 / sed_rate_03
  } else {
    writeLines("smoothing spline could not be fit", con = debug_file, sep = "\n")
  }

  # age_depth_spl <- smooth.spline(age, depth, df = nsamples)

  # compare sed rates
  sed_rate_01_max <- max(sed_rate_01); sed_rate_01_min <- min(sed_rate_01)
  sed_rate_02_max <- max(sed_rate_02); sed_rate_02_min <- min(sed_rate_02)
  sed_rate_03_max <- max(sed_rate_03); sed_rate_03_min <- min(sed_rate_03)
  sed_rate_max <- max(c(sed_rate_01_max, sed_rate_02_max, sed_rate_03_max), na.rm = TRUE)
  sed_rate_min <- max(c(sed_rate_03_min, sed_rate_02_min, sed_rate_03_min), na.rm = TRUE)
  
  # sample size
  sample_size <- as.numeric(entity_data$analytical_sample_size)
  
  # alternative quantities
  conc_01 <- rep(NA, nsamp); influx_01 <- rep(NA, nsamp)
  conc_02 <- rep(NA, nsamp); influx_02 <- rep(NA, nsamp)
  conc_03 <- rep(NA, nsamp); influx_03 <- rep(NA, nsamp)
  influx_source <- rep("none", nsamp) ; conc_source <- rep("none", nsamp)

  # select case based on entity$TYPE[j]

  if (entity$TYPE[j] == "concentration") {
      # adopt concentration values as they are, calculate influx
      writeLines("concentration block", con = debug_file, sep = "\n")
      # conc <- quant
      conc_01 <- quant; conc_02 <- quant; conc_03 <- quant
      conc_source <- "data"
      for (i in (1:nsamples)) {
        if (!is.na(conc_01[i]) && !is.na(sed_rate_01[i]) && sed_rate_01[i] != 0.0) {
          influx_01[i] <- quant[i] * sed_rate_01[i]
        }
        if (!is.na(conc_02[i]) && !is.na(sed_rate_02[i]) && sed_rate_02[i] != 0.0) {
          influx_02[i] <- quant[i] * sed_rate_02[i]
        }
        if (!is.na(conc_03[i]) && !is.na(sed_rate_03[i]) && sed_rate_03[i] != 0.0) {
          influx_03[i] <- quant[i] * sed_rate_03[i]
        }
      }
      influx_source <- "calculated from concentration"
      # if (all(is.na(influx))) influx <- conc
      writeLines(paste("influx from", entity$TYPE[j], sep=" "), con = debug_file, sep = "\n")
    }
  
   else if (entity$TYPE[j] == "influx") {
     # adopt influx values as they are, calculate concentration
     writeLines("influx block", con = debug_file, sep = "\n")
     # influx <- quant
     influx_01 <- quant; influx_02 <- quant; influx_03 <- quant
     influx_source <- "data"
     for (i in (1:nsamples)) {
       if (!is.na(influx_01[i]) && !is.na(unit_dep_time_01[i]) && sed_rate_01[i] != 0.0) {
         conc_01[i] <- quant[i] * unit_dep_time_02[i]
       }
       if (!is.na(influx_02[i]) && !is.na(unit_dep_time_02[i]) && sed_rate_02[i] != 0.0) {
         conc_02[i] <- quant[i] * unit_dep_time_02[i]
       }
       if (!is.na(influx_03[i]) && !is.na(unit_dep_time_03[i]) && sed_rate_03[i] != 0.0) {
         conc_03[i] <- quant[i] * unit_dep_time_03[i]
       }
     }
     conc_source <- "calculated from influx "
     writeLines(paste("concentration from", entity$TYPE[j], sep=" "), con = debug_file, sep = "\n")
   }
  
   else {
     # adopt pollen concentration values as they are, calculate influx
     writeLines("other entity", con = debug_file, sep = "\n")
     # conc <- quant
     conc_01 <- quant; conc_02 <- quant; conc_03 <- quant
     conc_source <- "data"
     for (i in (1:nsamples)) {
       if (!is.na(conc_01[i]) && !is.na(sed_rate_01[i]) && sed_rate_01[i] != 0.0) {
         influx_01[i] <- quant[i] * sed_rate_01[i]
       }
       if (!is.na(conc_02[i]) && !is.na(sed_rate_02[i]) && sed_rate_02[i] != 0.0) {
         influx_02[i] <- quant[i] * sed_rate_02[i]
       }
       if (!is.na(conc_03[i]) && !is.na(sed_rate_03[i]) && sed_rate_03[i] != 0.0) {
         influx_03[i] <- quant[i] * sed_rate_03[i]
       }
     }
     influx_source <- paste("calculated from ", entity$TYPE[j], sep = "")
     # if (all(is.na(influx))) influx <- conc
     influx_source <- "copied from conc"
     writeLines(paste("influx from", entity$TYPE[j], sep=" "), con = debug_file, sep = "\n")
   }
  max_influx <- max(rbind(influx_01, influx_02, influx_03), na.rm = TRUE)
  max_conc <- max(rbind(conc_01, conc_02, conc_03), na.rm = TRUE)
  
  # create and write an entity .csv file

  entity_hdr <- paste("entity", entity_id, sep="")
  
  # assemble output data and write it out
  outdata <- data.frame(samplenum, id_entity, id_sample, depth, age, 
                        thickness_01, dep_time_01, sed_rate_01, unit_dep_time_01, 
                        thickness_02, dep_time_02, sed_rate_02, unit_dep_time_02, 
                        thickness_03, dep_time_03, sed_rate_03, unit_dep_time_03, 
                        quant, conc_01, influx_01, conc_02, influx_02, conc_03, influx_03, data_type, conc_source, influx_source)
  names(outdata) <- c(entity_hdr, "ID_ENTITY", "ID_SAMPLE", "depth", "age", 
                      "thickness_01", "dep_time_01", "sed_rate_01", "unit_dep_time_01", 
                      "thickness_02", "dep_time_02", "sed_rate_02", "unit_dep_time_02", 
                      "thickness_03", "dep_time_03", "sed_rate_03", "unit_dep_time_03", 
                      "quant", "conc_01", "influx_01", "conc_02", "influx_02", "conc_03", "influx_03","TYPE", "conc_source", "influx_source" )
  csvfile <- paste(entity_data_csv_path, entity_id, "_entity_data_and_sedrate.csv", sep="")
  write.csv(outdata, csvfile, row.names=FALSE)
  
  writeLines(" ", con = debug_file, sep = "\n")
  
  
  # sedrate plots
  pdfname <- paste(sedrate_plots_path, entity_id, "_sedrate_plot.pdf", sep="")
  # plot the original data, histograms, and transformed data -- use one of the following and see dev.off() below
  pdf(file=pdfname,width=8.5, height=11.0)  # create a .pdf file of plots
  # windows(width=8.5, height=11.0)  # plot to the windows device (within R)
  
  # plot input data
  par(fig=c(0,1,.70,.95), mar=c(3.1, 4.1, 2.1, 4.1))
  plot(quant ~ age, xlim=c(max(age),-100), axes=F, mgp=c(2,0,0),
       main=paste(entity_id, namechar, sep=" "),font.main=1, lab=c(10,5,5),
       ylab=entity$TYPE[j], xlab="Age", cex.lab=0.8, pch=16, cex=0.5, type="o")
  if (has_thickness) text(max(age), max(quant), "has thckness values", pos = 4, adj = 0, cex = 0.8)
  axis(1, cex.axis=0.8); axis(2, cex.axis=0.8); axis(4, cex.axis=0.8)
  
  # plot the observed and fitted depth values
  par(new = T, fig=c(0,1,.50,.75), mar=c(3.1, 4.1, 2.1, 4.1))
  plot(depth ~ age, xlim=c(max(age),-100), axes=F, mgp=c(2,0,0),
       font.main=1, lab=c(10,5,5),
       ylab="Depth", xlab="Age", cex.lab=0.8, pch=16, cex=0.5)
  points(age_depth_spl$x, age_depth_spl$y, pch = 16, cex = 0.3, col="blue")
  axis(1, cex.axis=0.8); axis(2, cex.axis=0.8); axis(4, cex.axis=0.8)
  legend("bottomleft", c("Original", "Spline Fit"), pch=16, col=c("black","blue"), cex = 0.7)
  
  # plot the different sed rate values
  if (sed_rate_max != -Inf) {
    par(new = T, fig=c(0,1,.30,.55), mar=c(3.1, 4.1, 2.1, 4.1))
    plot(NULL, NULL, xlim=c(max(age),-100), ylim = c(sed_rate_min, sed_rate_max), axes=F, mgp=c(2,0,0),
         font.main=1, lab=c(10,5,5),
         ylab="Sed Rate", xlab="Age", cex.lab=0.8, pch=16, cex=0.5, col="black")
    if (has_thickness) points(sed_rate_01 ~ age, pch = 16, cex = 0.5, col="black")
    points(sed_rate_02 ~ age, pch = 16, cex = 0.5, col="red")
    points(sed_rate_03 ~ age, pch = 16, cex = 0.5, col="blue")
    axis(1, cex.axis=0.8); axis(2, cex.axis=0.8); axis(4, cex.axis=0.8)
    if (has_thickness) {
      legend("topleft", c("sedrate_01", "sedrate_02", "sedrate_03"), pch=16, col=c("black","red", "blue"), cex = 0.7)
    } else {
      legend("topleft", c("sedrate_02", "sedrate_03"), pch=16, col=c("red", "blue"), cex = 0.7)
    }
  }
  
  # plot converted concentration or influx    
  if (max_conc != -Inf) {
    par(new = T, fig=c(0,1,.10,.35), mar=c(3.1, 4.1, 2.1, 4.1))
    if (entity$TYPE[j] == "concentration") {
      plot(NULL, NULL, xlim=c(max(age),-100), ylim = c(0, max_influx), axes=F, mgp=c(2,0,0),
           font.main=1, lab=c(10,5,5), ylab="influx", xlab="Age", cex.lab=0.8)
      lines(influx_01 ~ age, pch = 16, cex = 0.5, col="black", type = "o")
      lines(influx_02 ~ age, pch = 16, cex = 0.5, col="red", type = "o")
      lines(influx_03 ~ age, pch = 16, cex = 0.5, col="blue", type = "o")
      axis(1, cex.axis=0.8); axis(2, cex.axis=0.8); axis(4, cex.axis=0.8)
      if (has_thickness) {
        legend("topleft", c("influx_01", "influx_02", "influx_03"), pch=16, col=c("black","red", "blue"), cex = 0.7)
      } else {
        legend("topleft", c("influx_02", "influx_03"), pch=16, col=c("red", "blue"), cex = 0.7)
      }
    } else {
      plot(NULL, NULL, xlim=c(max(age),-100), ylim = c(0, max_conc), axes=F, mgp=c(2,0,0),
           font.main=1, lab=c(10,5,5), ylab="concentration", xlab="Age", cex.lab=0.8)
      lines(conc_01 ~ age, pch = 16, cex = 0.5, col="black", type = "o")
      lines(conc_02 ~ age, pch = 16, cex = 0.5, col="red", type = "o")
      lines(conc_03 ~ age, pch = 16, cex = 0.5, col="blue", type = "o")
      axis(1, cex.axis=0.8); axis(2, cex.axis=0.8); axis(4, cex.axis=0.8)
      if (has_thickness) {
        legend("topleft", c("conc_01", "conc_02", "conc_03"), pch=16, col=c("black","red", "blue"), cex = 0.7)
      } else {
        legend("topleft", c("conc_02", "conc_03"), pch=16, col=c("red", "blue"), cex = 0.7)
      }
    }
  }
  dev.off() # turn off the .pdf device (comment this line out if plotting to the windows device
 }

close(debug_file)


