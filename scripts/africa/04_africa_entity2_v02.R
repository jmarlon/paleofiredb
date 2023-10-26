# 04 entity2: create an "entity2" table, adding info from samples2  

africa_entities <- read.csv("/Users/alialdous/Desktop/15/fire/africa/africa_entities_unique.csv")

# entity2 filename
entity2_filename <- "rpd_africa_entity2.csv"
entity2_file <- paste(sample2_path, entity2_filename, sep = "")
debug_filename <- "entity2_debug.txt"

# number of entities
summary(africa_entities)
nentities <- length(africa_entities$ID_ENTITY)
nentities

# copy entity table into entity2 table
entity2 <- africa_entities

# define entity2 types, units, etc.
entity2$TYPE2 <- as.character(rep(NA, nentities))
entity2$analytical_sample_size <- as.integer(rep(NA, nentities))
entity2$analytical_sample_size_unit <- as.character(rep(NA, nentities))
entity2$nsamp <- as.integer(rep(NA, nentities))
entity2$min_depth <- as.numeric(NA, nentities)
entity2$max_depth <- as.numeric(NA, nentities)



entity2$min_age <- as.numeric(NA, nentities)
entity2$max_age <- as.numeric(NA, nentities)
entity2$ave_interval <- as.numeric(NA, nentities)

# loop over the individual entities
# debug_file <- file(paste(debug_path, debug_filename, sep=""), "w")
for (j in (1:nentities)) {
  check <- as.character(rep(NA, max_samples))
  check <- sample2$TYPE[sample2$ID_ENTITY == africa_entities$ID_ENTITY[j]] 
  entity2$TYPE2[j] <- check[1]
  # jchar <- as.character(entity$ID_ENTITY[j])
  # writeLines(paste("Entity", jchar, unique(check), sep=" "), con = debug_file, sep = "\n")
  check <- sample2$analytical_sample_size[sample2$ID_ENTITY == africa_entities$ID_ENTITY[j]] 
  entity2$analytical_sample_size[j] <- check[1]
  check <- sample2$analytical_sample_size_unit[sample2$ID_ENTITY == africa_entities$ID_ENTITY[j]] 
  entity2$analytical_sample_size_unit[j] <- check[1]
  
  entity2$nsamp[j] <- length(check)
  check <- sample2$avg_depth[sample2$ID_ENTITY == africa_entities$ID_ENTITY[j]] 
  entity2$min_depth[j] <- min(check, na.rm = TRUE)
  entity2$max_depth[j] <- max(check, na.rm = TRUE)
  check <- sample2$age[sample2$ID_ENTITY == africa_entities$ID_ENTITY[j]] 
  entity2$min_age[j] <- min(check, na.rm = TRUE)
  entity2$max_age[j] <- max(check, na.rm = TRUE)
  entity2$ave_interval[j] <- (entity2$max_age[j] - entity2$min_age[j])/entity2$nsamp[j]
}
# close(debug_file)

# add a sequence number for each entity
entity2$seqnum <- as.integer(rep(NA, nentities))
entity2$seqnum <- seq(1, nentities, by = 1)

# types of records
unique(africa_entities$TYPE)
table(africa_entities$TYPE)

# head(entity)
# j <- 1849
# entity[entity$ID_ENTITY == j, ]
# length(sample2$avg_depth[sample2$ID_ENTITY == j ])

# number of entities without chronologies
sample2$ID_ENTITY[sample2$chronology == "none"]
length(sample2$ID_ENTITY[sample2$chronology == "none"])
length(unique(sample2$ID_ENTITY[sample2$chronology == "none"]))
unique(sample2$ID_ENTITY[sample2$chronology == "none"]) # entities without chronologies

# all entities
entities_in_sample2 <- unique(sample2$ID_ENTITY)
length(entities_in_sample2)

write.csv(entity2, file=entity2_file, row.names = FALSE)
