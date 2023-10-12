# age-bin averages of influx data
# bootstrap-by-entity confidence intervals

# names
basename <- "zt-lgit" #"nt-lgit" #   "zt-22k"

# paths for input and output .csv files -- modify as appropriate
datapath <- "/Users/bartlein/Projects/RPD/RPDv1b/"
entitylistpath <- "/Users/bartlein/Projects/RPD/RPDv1b/entity_lists/"

entitylist <- "na"

outpath <- "/Users/bartlein/Projects/RPD/RPDv1b/curves_csv/"

# prebinning bin width
pbw <- 10

pbw_char <- as.character(pbw)
if (pbw < 10) pbw_char <- paste("0", pbw_char, sep="")

# prebinning file name
binname <- paste("bw", pbw_char, sep="")

# presampled/binned files
csvpath <- "/Users/bartlein/Projects/RPD/RPDv1b/prebin_csv/"
csvname <- paste("_prebin_influx_",basename,"_",binname,".csv", sep="")

# number of bootstrap samples/replications
nreps <- 200

# target ages (bin centers) for fitted values
abw <- 100
abinbeg <- -100 #-200 # -100 # 
abinend <- 17600 # 22505
bw_char <- as.character(abw)

# array sizes
maxrecs <- 2000
maxreps <- 1000

# plotting set up
# xmin <- 22500; xmax <- -500
xmin <- 15000; xmax <- 10000
ymin1 <- -1.5; ymax1 <- 1.5; ymin2 <- -1.5; ymax2 <- 1.5
xlim <- c(xmin,xmax); ylim1 <- c(ymin1,ymax1); ylim2 <- c(ymin2,ymax2)
xlab= "Age (cal yr BP 1950)" #  "Year CE"
xminortick <- -100 # -500
# ylab <- "Z-Scores of Transformed Influx"
ylab <- "Normalized Anomalies of Transformed Influx"

# plot output 
plotout <- "screen" # "pdf" # 

# no changes below here

# prebinning file name
binname <- paste("bw", pbw_char, sep="")

# presampled/binned files
csvpath <- "/Users/bartlein/Projects/RPD/RPDv1b/prebin_csv/"
csvname <- paste("_prebin_influx_",basename,"_",binname,".csv", sep="")

# entity list file
entitylistfile <- paste(entitylistpath, entitylist, ".csv", sep="")
entitylistfile

# curve (output) path and file
curvecsvpath <- paste(datapath,"curves_csv/",sep="")

# if output folder does not exist, create it
dir.create(file.path(datapath, paste("curves_csv/",sep="")), showWarnings=FALSE)
# curvename <- paste(entitylist,"_binboot_",basename,"_",binname,"_hw",hw_char,"_",
#                    as.character(nreps), sep="")
curvename <- paste(entitylist,"_binboot_",basename,"_",binname,"_bw",bw_char,"_",
                   as.character(nreps), sep="")
curvefile <- paste(curvename, ".csv", sep="")
print(curvecsvpath)
print(curvename)
print(curvefile)

# .pdf plot of bootstrap iterations
if (plotout == "pdf") {
  pdffile <- paste(curvename, ".pdf", sep="")
  print(pdffile)
}
# # .png plot of bootstrap iterations
# if (plotout == "png") {
#   pngfile <- paste(curvename, ".png", sep="")
#   print(pngfile)
# }


# read the list of entities
entities <- read.csv(entitylistfile)
head(entities)
ns <- length(entities[,1]) #length(entities$ID_entity)
ns

# arrays for data and fitted values
age <- matrix(NA, ncol=ns, nrow=maxrecs)
influx <- matrix(NA, ncol=ns, nrow=maxrecs)
nsamples <- rep(0, maxrecs)

# age bin centers
abinage <- seq(abinbeg, abinend + abw, by=abw)
abinage
length(abinage)
plotyr <- seq(abinbeg + (abw/2), abinend + (abw/2), by=abw) 
plotyr
length(plotyr)

# array for bootstrap results
min_age <- abinbeg-(abw/2); max_age <- abinend + (abw/2)
nbins <- length(abinage)
yfit <- matrix(NA, nrow=nbins, ncol=maxreps)

# arrays for sample number tracking
ndec <- matrix(0, ncol=nbins, nrow=ns)
ndec_tot <- rep(0, nbins)
#xspan <- rep(0, ntarg)
ninwin <- matrix(0, ncol=nbins, nrow=ns)
ninwin_tot <- rep(0, nbins)



# read and store the presample (binned) files as matrices of ages and influx values
ii <- 0
i <- 1
for (i in 1:ns) {
  entitynum <- entities$ID_ENTITY[i]
  print(entitynum)
  entityidchar <- as.character(entitynum)
  if (entitynum >= 1) entityid <- paste("000", entityidchar, sep="")
  if (entitynum >= 10) entityid <- paste("00", entityidchar, sep="")
  if (entitynum >= 100) entityid <- paste("0", entityidchar, sep="")
  if (entitynum >= 1000) entityid <- paste(    entityidchar, sep="")
  
  inputfile <- paste(csvpath, entityid, csvname, sep="")
  print(inputfile)
  
  if (file.exists(inputfile)) {
    indata <- read.csv(inputfile)
    nsamp <-  length(indata$age) # 
    if (nsamp > 0) {
        ii <- ii+1
        age[1:nsamp,ii] <- indata$age # 
        influx[1:nsamp,ii] <- indata$zt # indata$norman # 
        nsamples[ii] <- nsamp
    }
  }
}
nentities <- i

# number of entities with data
nentities

# trim samples to age range
influx[age >= abinend+abw/2] <- NA
age[age >= abinend+abw/2] <- NA

# censor abs(influx) values > 10
influx[abs(influx) >= 10] <- NA
age[abs(influx) >= 10] <- NA

# count number of entities that contributed to each fitted value
ptm <- proc.time()

for (j in 1:nentities) {
  for (k in 1:nsamples[j]) {
    if (nsamples[j] != 0.0) {
    for (i in 1:nbins) {
      if (!is.na(age[k,j])) {
        ii <- as.integer(ceiling((age[k,j]-abinbeg)/abw)) # +1
        # print (c(i,j,k,ii, age[k,j]))
        if (ii > 0 && ii <= nbins) {ndec[j,ii] = 1}
        if (age[k,j] > (abinage[i] - (abw/2)) && age[k,j] <= (abinage[i] + (abw/2))) ninwin[j,i] = 1
        # print (c(ninwin[j,ii], age[k,j], abinage[i], abinage[i] - (abw/2), abinage[i] + (abw/2), ndec[j,i]))
        # if (age[k,j] >= (abinage[i] - (abw/2)) && age[k,j] <= (abinage[i] + (abw/2)))
        #   print(c(i,j,k, age[k,j], (abinage[i] - (abw/2)), (abinage[i] + (abw/2))   ))
      }
    }
    }
  }
}
for (i in 1:nbins) {
  ndec_tot[i] <- sum(ndec[,i])
  ninwin_tot[i] <- sum(ninwin[,i])
  # xspan[i] <- agemax - agemin
}

proc.time() - ptm
# head(cbind(abinage,plotyr,ndec_tot,ninwin_tot))
# tail(cbind(abinage,plotyr,ndec_tot,ninwin_tot))

ptm <- proc.time()
# 1. reshape matrices into vectors 
x <- as.vector(age)
y <- as.vector(influx)
lfdata <- data.frame(x,y)
lfdata <- na.omit(lfdata)
lfdata <- lfdata[lfdata$x >= min_age & lfdata$x < max_age, ]
x <- lfdata$x; y <- lfdata$y

# average influx for each age bin

binnum <- as.integer(ceiling((x-abinbeg-(abw/2.0))/abw))
binave <- tapply(y, binnum, mean)
bin_fit_all <- binave
binsubs_all <- as.integer(unlist(dimnames(binave)))

binnum; length(binnum)
binave; length(binave)
bin_fit_all; length(bin_fit_all)
abinage; length(abinage) 
plotyr; length(plotyr) 
# 
head(cbind(binaveage, abinage[binsubs_all], bin_fit_all))
tail(cbind(binaveage, abinage[binsubs_all], bin_fit_all))

# Bootstrap samples

# Step 1 -- Set up to plot individual replications
if (plotout == "pdf") {pdf(file=paste(curvecsvpath,pdffile,sep=""))}
if (plotout == "png") {png(file=paste(curvecsvpath,pngfile,sep=""), res=150)}
plot(NULL, ylim=ylim2, xlim=xlim, ylab=ylab, xlab=xlab, cex.sub=0.8, sub=curvename, type="n", panel.first = grid(NULL, NULL))
axis(side = 1, at = seq(xmin-xminortick, xmax+xminortick, by = xminortick), labels = FALSE, tcl = -.25)


# for debugging step plots
# plot the bin averages -- note pltYearCE offset to center the plot steps
# points(1950 - x, y, pch=16, cex=0.5, col=rgb(0.5,0.5,0.5,0.70))
# lines(bin_fit_all ~ pltYearCE, type="s", col="red", lwd=2)
# points(1950 - abinage, bin_fit_all, col="blue", pch=16, cex=0.5)

set.seed(10) # do this to get the same sequence of random samples for each run

# Step 2 -- Do the bootstrap iterations, and plot each age-bin curve
ptm <- proc.time() # time the loop
for (i in 1:nreps) {
  print(i)
  randentitynum <- sample(seq(1:nentities), nentities, replace=TRUE)
  # print(head(randentitynum))
  x <- as.vector(age[,randentitynum])
  y <- as.vector(influx[,randentitynum])
  lfdata <- data.frame(x,y)
  lfdata <- na.omit(lfdata)
  lfdata <- lfdata[lfdata$x >= min_age & lfdata$x < max_age, ]
  x <- lfdata$x; y <- lfdata$y
  
  binnum <- as.integer(ceiling((x-abinbeg-(abw/2.0))/abw))+1
  binave <- tapply(y, binnum, mean)
  binsubs <- as.integer(unlist(dimnames(binave)))
  #bin_fit <- binave[binsubs]
  yfit[binsubs,i] <- binave
  segments(abinage-1.9*(abw/2), yfit[,i], abinage-0.1*(abw/2), yfit[,i], lwd=0.6, col=rgb(0.3,0.3,0.3,0.25))
  # segments(plotyr-1.9*(abw/2), yfit[,i], plotyr-0.1*(abw/2), yfit[,i], lwd=0.6, col=rgb(0.3,0.3,0.3,0.25))
}
proc.time() - ptm # how long?

# Step 3 -- Plot the unresampled (initial) area averages
lines(abinage[binsubs_all+1]-abw, bin_fit_all, type="s", lwd=2, col="red")

# Step 4 -- Find and add bootstrap CIs
yfit975 <- apply(yfit, 1, function(x) quantile(x,prob=0.975, na.rm=T))
yfit025 <- apply(yfit, 1, function(x) quantile(x,prob=0.025, na.rm=T))
yfit50 <- apply(yfit, 1, function(x) quantile(x,prob=0.500, na.rm=T))

lines(abinage-abw, yfit025, type="s", lwd=0.5, col="red")
lines(abinage-abw, yfit975, type="s", lwd=0.5, col="red")

if (plotout == "pdf") {dev.off()}
if (plotout == "png") {dev.off()}


class(bin_fit_all)

bin_fit_all <- as.numeric(bin_fit_all)
bin_fit_all <- c(bin_fit_all, NA)
curveout <- data.frame(cbind(abinage, bin_fit_all, yfit975, yfit025, ndec_tot, ninwin_tot))
colnames(curveout) <- c("age", "bin_ave", "cu95", "cl95", "nentities", "ninwin")
outputfile <- paste(curvecsvpath, curvefile, sep="")
write.table(curveout, outputfile, col.names=TRUE, row.names=FALSE, sep=",")




