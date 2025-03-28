###############################################################################
# Appendix 1: Conservation Unit list
###############################################################################

library(dplyr)
library(RPostgres)

###############################################################################
# Create connection to postreSQL salmonwatersheds database
###############################################################################

dsn_database = "salmondb_prod"
dsn_hostname = "3.99.23.175" # "data.salmonwatersheds.ca", # , # change: https://salmonwatersheds.slack.com/archives/CKNVB4MCG/p1739293987758589
dsn_port = "5432"
dsn_uid = "salmonwatersheds"
dsn_pwd <- readline(prompt="Enter database password: " )    # Specify your password. e.g. "xxx"

tryCatch({
	drv <- RPostgres::Postgres()
	print("Connecting to Database…")
	connec <- dbConnect(drv, 
											dbname = dsn_database,
											host = dsn_hostname, 
											port = dsn_port,
											user = dsn_uid, 
											password = dsn_pwd)
	print("Database Connected!")
},
error=function(cond) {
	print("Unable to connect to Database.")
})

###############################################################################
# Import conservation unit list view from appdata
###############################################################################

# # Simple list, with just primary cuid and FULL_CU_IN
app1 <- dbGetQuery(
	conn = connec,
	statement = "SELECT * FROM appdata.vwdl_conservationunits"
)

# Full decoder with Cu breakdowns where PSF CUs differ from DFO CUs
app1_full <- dbGetQuery(
	conn = connec, 
	statement = "SELECT * FROM appdata.vwdl_conservationunits_decoder"
)

multi_cuid <- names(which(tapply(app1_full$pooledcuid, app1_full$pooledcuid, length) > 1))
app1_full[which(app1_full$pooledcuid %in% multi_cuid), ]

# Fix Club/Swan for now
# app1_full$cu_index[which(app1_full$cu_name_dfo == "Club Lake")] <- "SEL-21-04"
app1_full$cu_index[app1_full$cu_name_dfo == "Babine-Pinkut"] <- ""

###############################################################################
# Make pretty for table display
###############################################################################

app1_display <- data.frame(
	Region = app1$region,
	Species = app1$species_name,
	Conservation.Unit = app1$cu_name_pse,
	CUID = app1$cuid,
	Full.CU.Index = app1$cu_index 
)

for(i in 1:length(multi_cuid)){
	app1_display$Full.CU.Index[app1_display$CUID == multi_cuid[i]] <- paste(app1_full$cu_index[which(app1_full$pooledcuid ==  multi_cuid[i])], sep ='', collapse = ', ')
}

app1_display$Full.CU.Index[is.na(app1_display$Full.CU.Index)] <- ""

###############################################################################
# Write to csv
###############################################################################

write.csv(app1_display, file = "tables/appendix1.csv", row.names = FALSE)
