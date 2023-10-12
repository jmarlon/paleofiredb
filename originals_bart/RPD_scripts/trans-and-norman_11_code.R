# 6b) trans-and-norman.R

# 1-parameter Box-Cox transformation of charcoal quanities for a single entity
# (alpha (shift parameter) is specified, lambda (power transformation parameter) is estimated)

# input .csv files should contain at least the variables "est_age" and "quant",
# 	identified by labels in a header row  

# paths for input and output .csv files -- modify as appropriate
queryname <- "RPDv1b"
datapath <- "/Users/bartlein/Projects/RPD/RPDv1b/"
entitylistpath <- "/Users/bartlein/Projects/RPD/RPDv1b/entity_lists/"
entitylist <- "entity_list2"

# set base period ages (or read a baseperiod info file)
basebeg <- 10000
baseend <- 15000 
basename <- "nt-lgit"

# no changes below here

# various path and filenames
entitylistfile <- paste(entitylistpath, entitylist, ".csv", sep="")
entitylistfile

entitycsvpath <- paste(datapath,"entity_csv/",sep="")
transcsvpath <- paste(datapath,"trans_csv/",sep="")
# if output folder does not exist, create it
dir.create(file.path(transcsvpath), showWarnings=FALSE)
statscsvpath <- paste(datapath,"stats_csv/",sep="")
# if output folder does not exist, create it
dir.create(file.path(statscsvpath), showWarnings=FALSE)
statsfile <- paste(statscsvpath,basename,"_stats.csv", sep="")

# read list of entities
ptm <- proc.time()
entities <- read.csv(paste(entitylistfile), stringsAsFactors=FALSE)
nentities <- length(entities[,1])
print (nentities)

# storage for statistics
sn_save <- rep(0,nentities); lam_save <- rep(0,nentities); lik_save <- rep(0,nentities)
tmean_save <- rep(0,nentities); tstdev_save <- rep(0,nentities)

# main loop
j <- 1
for (j in seq(1,nentities)) {

  # 1. entity .csv file name (input file)
  entitynum <- entities$ID_ENTITY[j]
  entityname <- as.character(entitynum)
  entityidchar <- as.character(entitynum)
  if (entitynum >= 1) entityid <- paste("000", entityidchar, sep="")
  if (entitynum >= 10) entityid <- paste("00", entityidchar, sep="")
  if (entitynum >= 100) entityid <- paste("0", entityidchar, sep="")
  if (entitynum >= 1000) entityid <- paste(    entityidchar, sep="")
  inputfile <- paste(entitycsvpath, entityid, "_data.csv", sep="")
  print(j); print(entitynum); print(entityname); print(inputfile)

  # 2. read the input data
  entitydata <- read.csv(inputfile)
  
  # 3. discard samples with missing 
  entitydata <- entitydata[!is.na(entitydata$age),]
  # entitydata <- entitydata[!is.na(entitydata$sed_rate),]
  entitydata <- entitydata[!is.na(entitydata$influx),]
  
  # 4. discard samples with ages > -60
  entitydata <- entitydata[entitydata$age > -70,]

  # 5. initial minimax rescaling of data
  minimax <- (entitydata$influx-min(entitydata$influx))/(max(entitydata$influx)-min(entitydata$influx))
  
  # 6. set `alpha` the Box-Cox transformation shift parameter
  alpha <- 0.01  # Box-Cox shift parameter
  # alternative alpha: 0.5 times the smallest nonzero value of influx
  # alpha <- 0.5*min(entitydata$influx[entitydata$influx != 0])  

  # 7. maximum likelihood estimation of lambda
  # derived from the boxcox.R function in the Venables and Ripley MASS library included in R 2.6.1

  npts <- 201 # number of estimates of lambda
  y <- minimax+alpha
  n <- length(y)
  logy <- log(y)
  ydot <- exp(mean(logy))
  lasave <- matrix(1:npts)
  liksave <- matrix(1:npts)
  for (i in 1:npts) {
    la <- -2.0+(i-1)*(4/(npts-1))
    if (la != 0.0) yt <- (y^la-1)/la else yt <- logy*(1+(la*logy)/2*(1+(la*logy)/3*(1+(la*logy)/4)))
    zt <- yt/ydot^(la-1)
    loglik <- -n/2*log(sum((zt - mean(zt))^2 ))
    lasave[i] <- la
    liksave[i] <- loglik
    }

  # save the maximum likelihood value and the associated lambda
  maxlh <- liksave[which.max(liksave)]
  lafit <- lasave[which.max(liksave)]
  print (c(entitynum, maxlh, lafit))

  # 8. Box-Cox transformation of data
  if (lafit == 0.0) tall <- log(y) else tall <- (y^lafit - 1)/lafit

  # 9. minimax rescaling
  tall <- (tall - min(tall))/(max(tall)-min(tall))
  
  # 10. calculate mean and standard deviation of data over base period
  tmean <- mean(tall[entitydata$age >= basebeg & entitydata$age <= baseend])
  tstdev <- sd(tall[entitydata$age >= basebeg & entitydata$age <= baseend])
  
  # 11. calculate "normans" normalized anomalies
  norman <- (tall-tmean)/tmean
  
  # 12. write out transformed data for this entity
  entityout <- data.frame(cbind(entitydata$ID_ENTITY, entitydata$	ID_SAMPLE, entitydata$age,
    entitydata$depth, entitydata$influx, minimax, tall, ztrans))
  colnames(entityout) <- c("ID_ENTITY", "ID_Sample", "age", "depth", "influx", "influxmnx", "tall", "norman")

  outputfile <- paste(transcsvpath, entityid, "_trans_influx_", basename, ".csv", sep="")
  write.table(entityout, outputfile, col.names=TRUE, row.names=FALSE, sep=",")
  
  sn_save[j] <- entitynum
  lam_save[j] <- lafit
  lik_save[j] <- maxlh
  tmean_save[j] <- tmean
  tstdev_save[j] <- tstdev
  
}

# write out a file of statistics
stats <- data.frame(cbind(sn_save, lam_save, lik_save, tmean_save, tstdev_save))
colnames(stats) <- c("entity", "lambda", "likelihood", "mean", "stdev")
write.table(stats, statsfile, col.names=TRUE, row.names=FALSE, sep=",")
proc.time() - ptm
