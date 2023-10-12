# 4) fixups
# apply fixups to sample2 and entity2 tables

entity2$fixup <- as.integer(rep(0, nentities))
entity2$skip <- as.integer(rep(0, nentities))

entity_list_path <- paste(data_path, "entity_lists/", sep="")
entity_fixup_filename <- "entity_fixups.csv"
entity_fixup_file <- paste(entity_list_path, entity_fixup_filename, sep = "")

fixup_file <- file(paste(debug_path, "fixups.txt", sep=""), "w")

# edit missing min age, entity 2034, sample 363261
sample2$age[195959] <- 0.0
entity2$min_age[1253] <- 0.0
writeLines("Edited missing min age: entity 2034, sample 363261", con = fixup_file, sep = "\n")

# edit ambiguous analytical_sample_size values, set to 1.0
entity2$analytical_sample_size[entity2$ID_ENTITY == 813] <- 0.055; entity2$fixup[entity2$ID_ENTITY == 813] <- 1
sample2$analytical_sample_size[sample2$ID_ENTITY == 813] <- 0.055
entity2$analytical_sample_size[entity2$ID_ENTITY == 1004] <- 0.2; entity2$fixup[entity2$ID_ENTITY == 1004] <- 1
sample2$analytical_sample_size[sample2$ID_ENTITY == 1004] <- 0.2
entity2$analytical_sample_size[entity2$ID_ENTITY == 1733] <- 17.0; entity2$fixup[entity2$ID_ENTITY == 1733] <- 1
sample2$analytical_sample_size[sample2$ID_ENTITY == 1733] <- 17.0
entity2$analytical_sample_size[entity2$ID_ENTITY == 1978] <- 27.5; entity2$fixup[entity2$ID_ENTITY == 1978] <- 1
sample2$analytical_sample_size[sample2$ID_ENTITY == 1978] <- 27.5
entity2$analytical_sample_size[entity2$ID_ENTITY == 2014] <- 150.0; entity2$fixup[entity2$ID_ENTITY == 2014] <- 1
sample2$analytical_sample_size[sample2$ID_ENTITY == 2014] <- 150.0
entity2$analytical_sample_size[entity2$ID_ENTITY == 2361] <- 0.200; entity2$fixup[entity2$ID_ENTITY == 2361] <- 1
sample2$analytical_sample_size[sample2$ID_ENTITY == 2361] <- 0.200
entity2$analytical_sample_size[entity2$ID_ENTITY == 2482] <- 2.0; entity2$fixup[entity2$ID_ENTITY == 2482] <- 1
sample2$analytical_sample_size[sample2$ID_ENTITY == 2482] <- 2.0
writeLines("Edited ambiguous analytical_sample_size_values:", con = fixup_file, sep = "\n")
writeLines("  ID_ENTITY = 813, 1004, 1733, 1978, 2014, 2361, 2482", con = fixup_file, sep = "\n")

# edit analytical_sample_size values that appear as dates
entity_id <- c(1006, 1560, 1588, 1604, 1984, 2015, 2016, 2034, 2153, 2154, 2230, 2253)
entity2$analytical_sample_size[entity2$ID_ENTITY %in% entity_id] <- 1.0
entity2$fixup[entity2$ID_ENTITY %in% entity_id] <- 1
sample2$analytical_sample_size[sample2$ID_ENTITY %in% entity_id] <- 1.0
writeLines("Edited analytical_sample_size_values that were dates:", con = fixup_file, sep = "\n")
writeLines("  ID_ENTITY = 1006, 1560, 1588, 1604, 1984, 2015, 2016, 2034, 2153, 2154, 2230, 2253", con = fixup_file, sep = "\n")

# replace missing analytical_sample_size values with 1's
length(entity2$analytical_sample_size[entity2$analytical_sample_size == -999999])
entity2$analytical_sample_size[entity2$analytical_sample_size == -999999] <- 1.0
length(entity2$analytical_sample_size[entity2$analytical_sample_size == -777777])
entity2$analytical_sample_size[entity2$analytical_sample_size == -777777] <- 1.0
writeLines("Replaced analytical_sample_size missing values (-999999, -777777) with 1's", con = fixup_file, sep = "\n")

# edit analytical_sample_size_unit
unique(entity2$analytical_sample_size_unit)
unit_vals <- c("cm3", "ml", "g")
entity2$analytical_sample_size_unit[!(entity2$analytical_sample_size_unit %in% unit_vals)] <- "cm3"
writeLines("Forced analytical_sample_size_unit values to cm3, ml, or g", con = fixup_file, sep = "\n")

# set skip flag for entities without age information
skip_id <- c(1459, 1461, 1605, 1606, 1623, 1627, 1628, 1730, 1750, 1768, 1775, 1923, 1934, 1937, 1938,
             1939, 1940, 1964, 1987, 1990, 1993, 1994, 1998, 2049, 2377, 2378, 2425, 2428, 2431, 2432)
entity2$skip[entity2$ID_ENTITY %in% skip_id] <- 1
writeLines("Set skip flag to 1 for samples without age info", con = fixup_file, sep = "\n")

# set skip flag for entities with only one or two samples
skip_id <- c(85, 941, 1757, 1758, 1759, 1762, 1763, 1764, 1765, 1767, 1768, 1769, 1770, 1771, 1772, 1773)
entity2$skip[entity2$ID_ENTITY %in% skip_id] <- 1
writeLines("Set skip flag to 1 for samples with only one or two samples", con = fixup_file, sep = "\n")

# set skip flag for entities with zero charcoal throughout
skip_id <- c(1001, 1741, 1755, 1757, 1760, 1766)
entity2$skip[entity2$ID_ENTITY %in% skip_id] <- 1
writeLines("Set skip flag to 1 for samples with zero charcoal throughout", con = fixup_file, sep = "\n")

write.csv(entity2, file=entity_fixup_file, row.names = FALSE)

close(fixup_file)

