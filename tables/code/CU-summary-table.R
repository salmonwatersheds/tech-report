###############################################################################
# Summary of CU-level information
###############################################################################

# This code combines CU-level summaries in Appendix 4 (biostatus) and Appendix
# 13 (cumulative habitat pressures) with information on exploitation rates and 
# hatchery influence to yield a monster table of CU-level summaries.

library(dplyr)
library(RPostgreSQL)

###############################################################################
# Create connection to postreSQL salmonwatersheds database
###############################################################################

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
# Import conservation unit list view from appdata
###############################################################################
var_to_keep <- c("region", 
								 "species_name", 
								 "cuid", 
								 "cu_name_pse", 
								 "curr_spw", 
								 "curr_spw_start_year", 
								 "curr_spw_end_year",
								 "psf_status",
								 "cosewic_status",
								 "cosewic_status_yr",
								 "wsp_status",
								 "wsp_status_yr",
								 "extinct",
								 "total_exploitation_rate",
								 "total_exploitation_rate_yr",
								 "rollup_hi_pct",
								 "rollup_mod_pct",
								 "rollup_lo_pct"
)

# Get biostatus
app4 <- dbGetQuery(
	conn = connec, 
	statement = "SELECT * FROM appdata.vwdl_setr_appendix4"
)

# Get Dataset102: exploitation, current aabundance, benchmarks
dat102 <- dbGetQuery(
	conn = connec, 
	statement = "SELECT * FROM appdata.vwdl_dataset102_output"
)
dat102[which(dat102 == -989898, arr.ind = TRUE)] <- NA

full_join(app4, dat102)[, c("reg")]
# Get freshwater habitat pressure
app13 <- dbGetQuery(
	conn = connec, 
	statement = "SELECT * FROM appdata.vwdl_setr_appendix13"
)

regions <- data.frame(
	regionid = c(1:10),
	region_name = c("Skeena", "Nass", "Central Coast", "Fraser", "Vancouver Island & Mainland Inlets", "Haida Gwaii", "Columbia", "Yukon", NA, "Transboundary")
)
app13$region <- regions$region_name[app13$regionid]

# Read catch and run size
exploitation <- dbGetQuery(
	conn = connec, 
	statement = "SELECT * FROM appdata.vwdl_dataset4_output"
)
exploitation[which(exploitation == -989898, arr.ind = TRUE)] <- NA

dat102vs4 <- data.frame(cuid = dat102$cuid, dat102 = NA, dat4 = NA)
for(i in 1:nrow(dat102vs4)){
	dat102vs4$dat102[which(dat102vs4$cuid == dat102vs4$cuid[i])] <-  dat102$exp[which(dat102$cuid == dat102vs4$cuid[i])]
	dum1 <- exploitation[which(exploitation$cuid == dat102vs4$cuid[i]), c('total_exploitation_rate', 'year')]
	dum1 <- dum1[!is.na(dum1$total_exploitation_rate),]
	if(nrow(dum1) > 0){
		
	dat102vs4$dat4[which(dat102vs4$cuid == dat102vs4$cuid[i])] <- dum1$total_exploitation_rate[which(dum1$year == max(dum1$year))]
	}
	rm(dum1)

}

############################################
# Make monster table
###############################################################################

# relationship = "one-to-one" means an error willbe thrown if cuid is duplicated
# in either table

CUsummary <- full_join(app4, app13)
	

###############################################################################
# Write to csv
###############################################################################

write.csv(app1_display, 
					file = paste0("tables/full-CU-summary_", strftime(Sys.Date(), format = "%d%b%Y"), ".csv"), row.names = FALSE)
