# 02_read_db:  read the RPD, and do some additional setup (libraries, size limits)   

# MacOS
# install MySQL Community Server https://dev.mysql.com/downloads/mysql/
# install MySQL Workbench https://dev.mysql.com/downloads/workbench/ to import RPDv1b 

# remember to start MySQL Sever in System Preferences

# Read various database tables

library(RMariaDB)
library(DBI)

con <- dbConnect(RMariaDB::MariaDB(), dbname = "RPDv1b", user = "root", password = "@OvR4f#aw%10")
con

summary(con)
dbGetInfo(con)
dbListTables(con)

dbListFields(con, "site")
site <- dbReadTable(con, "site")
str(site)
head(site)
length(unique(site$ID_SITE))

entity <- dbReadTable(con, "entity")
str(entity)
head(entity)
summary(entity)
length(unique(entity$ID_ENTITY))
length(unique(entity$ID_SITE))
length(unique(entity$ID_UNIT))

africa_entities <- dbReadTable(con, "africa_entities")
str(africa_entities)
head(africa_entities)
summary(africa_entities)
length(unique(africa_entities$ID_ENTITY))
length(unique(africa_entities$ID_SITE))
length(unique(africa_entities$ID_UNIT))

unit <- dbReadTable(con, "unit")
str(unit)
head(unit)
length(unique(unit$ID_UNIT))

date_info <- dbReadTable(con, "date_info")
str(date_info)
head(date_info)
length(unique(date_info$ID_DATE_INFO))
length(unique(date_info$ID_ENTITY))

sample <- dbReadTable(con, "sample")
dim(sample)
str(sample)
head(sample)
length(unique(sample$ID_SAMPLE))
length(unique(sample$ID_ENTITY))

model_name <- dbReadTable(con, "model_name")
dim(model_name)
head(model_name)
length(unique(model_name$ID_MODEL))

chronology <- dbReadTable(con, "chronology")
str(chronology)
head(chronology)
length(unique(chronology$ID_MODEL))
length(unique(chronology$ID_SAMPLE))

age_model <- dbReadTable(con, "age_model")
str(age_model)
head(age_model)
length(unique(age_model$ID_MODEL))
length(unique(age_model$ID_SAMPLE))

dbDisconnect(con)




