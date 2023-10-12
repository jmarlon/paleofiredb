#prebin_11.R
# prebinles, or bins the transformed data into evenly spaced bins with no interpolation  

# paths for input and output .csv files -- modify as appropriate
datapath <- "/Users/bartlein/Projects/RPD/RPDv1b/"
entitylistpath <- "/Users/bartlein/Projects/RPD/RPDv1b/entity_lists/"
entitylist <- "entity_list2"

## set basename and bin structure
basename <- "zt-lgit"
targstep <- 10
targbeg <- -60 - targstep/2
targend <- 24000

targstep_char <- as.character(targstep)
if (targstep < 10) targstep_char <- paste("0", targstep_char, sep="")


# no changes below here

# various path and filenames
entitylistfile <- paste(entitylistpath, entitylist, ".csv", sep="")
entitylistfile
transcsvpath <- paste(datapath,"trans_csv/",sep="")
prebincsvpath <- paste(datapath,"prebin_csv/",sep="")

# if output folder does not exist, create it
dir.create(file.path(datapath, "prebin_csv/",sep=""), showWarnings=FALSE)

# bin center (target points) definition
targage <- seq(targbeg, targend, by=targstep)

# read list of entity
ptm <- proc.time()
entity <- read.csv(entitylistfile, stringsAsFactors=FALSE)
nentities <- length(entity[,1])
print(nentities)

# main loop
j <- 1
for (j in seq(1,nentities)) {

  # 1. Compose the trans-and-zscore .csv file name
  entitynum <- entities$ID_ENTITY[j]
  entityname <- as.character(entitynum)
  entityidchar <- as.character(entitynum)
  if (entitynum >= 1) entityid <- paste("000", entityidchar, sep="")
  if (entitynum >= 10) entityid <- paste("00", entityidchar, sep="")
  if (entitynum >= 100) entityid <- paste("0", entityidchar, sep="")
  if (entitynum >= 1000) entityid <- paste(    entityidchar, sep="")
  inputfile <- paste(transcsvpath, entityid, "_trans_influx_",basename,".csv", sep="")
  print(j); print(entitynum); print(entityname); print(inputfile)
  
  # 2. Read the input data
  entitydata <- read.csv(inputfile)
  nsamp <- length(entitydata$zt)
  
  # 3. Count the number of nonmissing (non-NA) and infinite influx values
  nonmiss <- na.omit(entitydata$zt)
  numnonmiss <- length(nonmiss)
  numinf <- sum(is.infinite(nonmiss))
  numnonmiss; numinf
  
  if (length(nonmiss) > 0 & numinf < numnonmiss) {
    
    # add a column of 1's for counting
    entitydata$one <- rep(1,length(entitydata[,1]))
    
    # 4. Find bin number of each sample
    # this definition of bin number seems to match that implicit in prebinle.f90
    binnum <- as.integer(ceiling((entitydata$age-targbeg)/targstep)) + 1
    as.integer(ceiling((entitydata$age-targbeg)/targstep))+1
    
    # uncommenting the following reveals how each sample is assigned to a bin
    head(cbind(entitydata$age,entitydata$zt,binnum,targage[binnum]), 20)
    
    # 5. Get average zt values (and average ages) for the data in each bin
    binave <- tapply(entitydata$zt, binnum, mean)
    binaveage <- tapply(entitydata$age, binnum, mean)
    bincount <- tapply(entitydata$one, binnum, sum)
    
    # 6. Get bin numbers of each bin that had an average (or a single) value
    binsub <- as.numeric(unlist(dimnames(binave)))  
    
    # 7. Write output
    prebinout <- data.frame(cbind(targage[binsub],binave,bincount))
    prebinout <- na.omit(prebinout)
    colnames(prebinout) <- c("age", "zt", "np")
    
    outputfile <- paste(prebincsvpath, entityid, "_prebin_influx_",basename,"_bw",
                       targstep_char,".csv", sep="")
    write.table(prebinout, outputfile, col.names=TRUE, row.names=FALSE, sep=",")
  }
  
}
proc.time() - ptm
