###############################################################################
# Appendix 13: Cumulative Pressure by spawning watershed
###############################################################################

library(dplyr)
library(RPostgreSQL)

###############################################################################
# Create connection to postreSQL salmonwatersheds database
###############################################################################
library(RPostgreSQL)

dsn_database <- "salmondb_prod"   # Specify the name of your Database
dsn_hostname <- "data.salmonwatersheds.ca"  # Specify host name e.g.:"aws-us-east-1-portal.4.dblayer.com"
dsn_port <- "5432"                # Specify your port number. e.g. 98939
dsn_uid <- "salmonwatersheds"         # Specify your username. e.g. "admin"
dsn_pwd <- readline(prompt="Enter database password: " )    # Specify your password. e.g. "xxx"

tryCatch({
	drv <- dbDriver("PostgreSQL")
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
# Import appendix4 view from appdata
###############################################################################

# Get app4 view
app13 <- dbGetQuery(
	conn = connec, 
	statement = "SELECT * FROM appdata.vwdl_setr_appendix13"
)

regions <- data.frame(
	regionid = c(1:10),
	region_name = c("Skeena", "Nass", "Central Coast", "Fraser", "Vancouver Island & Mainland Inlets", "Haida Gwaii", "Columbia", "Yukon", NA, "Transboundary")
)
app13$region <- regions$region_name[app13$regionid]

# # Check rollup %
# sum_rollup <- round(apply(app13[, c("rollup_lo_pct", "rollup_mod_pct", "rollup_hi_pct")], 1, sum, na.rm = TRUE), 3)
# write.csv(cbind(app13[which(sum_rollup < 1), c(43, 2:3,6:8)], sum_rollup[which(sum_rollup < 1)]), file = "rollup_less_than_100_2023-06-26.csv")
# # Ones < 100 are due to Yukon watershed issues; remove in Rmd table part

###############################################################################
# Make pretty for table display
###############################################################################

app13_display <- data.frame(
	Region = app13$region,
	Species = app13$species_name,
	Conservation.Unit = app13$cu_name_pse,
	High.Risk = ifelse(is.na(app13$rollup_hi_pct), "0%", paste0(round(app13$rollup_hi_pct*100), "%")),
	Moderate.Risk = ifelse(is.na(app13$rollup_mod_pct), "0%", paste0(round(app13$rollup_mod_pct*100), "%")),
	Low.Risk = ifelse(is.na(app13$rollup_lo_pct), "0%", paste0(round(app13$rollup_lo_pct*100), "%"))
)

###############################################################################
# Write to csv
###############################################################################

write.csv(app13_display, file = "tables/appendix13.csv", row.names = FALSE)
