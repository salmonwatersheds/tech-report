###############################################################################
# Summary of CU-level information
###############################################################################

# This code combines CU-level summaries in Appendix 4 (biostatus) and Appendix
# 13 (cumulative habitat pressures) with information on exploitation rates and 
# hatchery influence to yield a monster table of CU-level summaries.

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
var_to_keep <- c("region", 
								 "species_name", 
								 "cuid", 
								 "cu_name_pse", 
								 "exp",
								 "curr_spw", 
								 "curr_spw_start_year", 
								 "curr_spw_end_year",
								 "cu_enh_rank",
								 "psf_status",
								 "cosewic_status",
								 "cosewic_status_yr",
								 "wsp_status",
								 "wsp_status_yr",
								 "rollup_hi_pct",
								 "rollup_mod_pct",
								 "rollup_lo_pct"
)

# Get biostatus
app4 <- dbGetQuery(
	conn = connec, 
	statement = "SELECT * FROM appdata.vwdl_setr_appendix4"
)

# Gett biostatus from other view table
dat101 <- dbGetQuery(
	conn = connec, 
	statement = "SELECT * FROM appdata.vwdl_dataset101_output"
)

# Get Dataset102: exploitation, current aabundance, benchmarks
dat102 <- dbGetQuery(
	conn = connec, 
	statement = "SELECT * FROM appdata.vwdl_dataset102_output"
)
dat102[which(dat102 == -989898, arr.ind = TRUE)] <- NA

cu_summaries_prelim1 <- full_join(app4, dat102)
cu_summaries_prelim2 <- cu_summaries_prelim1[, names(cu_summaries_prelim1) %in% var_to_keep]


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
# Remove species name because formatted differently from other tables and so it duplicates on full join
app13 <- app13[, which(names(app13) != "species_name")]

cu_summaries_prelim3 <- full_join(app13, cu_summaries_prelim2)
cu_summaries_prelim4 <- cu_summaries_prelim3[, names(cu_summaries_prelim3) %in% var_to_keep]


# # Read catch and run size
# exploitation <- dbGetQuery(
# 	conn = connec, 
# 	statement = "SELECT * FROM appdata.vwdl_dataset4_output"
# )
# exploitation[which(exploitation == -989898, arr.ind = TRUE)] <- NA
# 
# dat102vs4 <- data.frame(cuid = dat102$cuid, dat102 = NA, dat4 = NA)
# for(i in 1:nrow(dat102vs4)){
# 	dat102vs4$dat102[which(dat102vs4$cuid == dat102vs4$cuid[i])] <-  dat102$exp[which(dat102$cuid == dat102vs4$cuid[i])]
# 	dum1 <- exploitation[which(exploitation$cuid == dat102vs4$cuid[i]), c('total_exploitation_rate', 'year')]
# 	dum1 <- dum1[!is.na(dum1$total_exploitation_rate),]
# 	if(nrow(dum1) > 0){
# 		
# 	dat102vs4$dat4[which(dat102vs4$cuid == dat102vs4$cuid[i])] <- dum1$total_exploitation_rate[which(dum1$year == max(dum1$year))]
# 	}
# 	rm(dum1)
# 
# }

# Join hatchery release scores
hatch <- read.csv("tables/code/ignore/CU_enhancement_levelFeb142023.csv")
head(hatch)
head(cu_summaries_prelim4)

cu_summaries_prelim5 <- full_join(hatch, cu_summaries_prelim4)
cu_summaries_prelim6 <- cu_summaries_prelim5[, names(cu_summaries_prelim5) %in% var_to_keep]

###############################################################################
# Write to csv
###############################################################################
cu_summaries <- cu_summaries_prelim6[, var_to_keep]

write.csv(cu_summaries, 
					file = paste0("tables/full-CU-summary_", strftime(Sys.Date(), format = "%d%b%Y"), ".csv"), row.names = FALSE)
