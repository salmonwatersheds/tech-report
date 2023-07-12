###############################################################################
# Appendix 4: Biological Status Details
# Compile outcome from dataset102 from various regions
###############################################################################

library(dplyr)
library(RPostgreSQL)

# Function to add commas if >= 10,000
prettierNum <- function(x){
	x1 <- character(length(x))
	for(i in 1:length(x)){
		if(is.na(x[i])){
			x1[i] <- " "
		} else {
			if(x[i] >= 10000){
				x1[i] <- prettyNum(x[i], big.mark=",", preserve.width="none")
			} else {
				x1[i] <- as.character(x[i])
			}
		}}
	return(x1)
}

stripNA <- function(x){
	ifelse(is.na(x), " ", x)
}

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
app4 <- dbGetQuery(
	conn = connec, 
	statement = "SELECT * FROM appdata.vwdl_setr_appendix4"
)

###############################################################################
# Make pretty for table display
###############################################################################

app4_display <- data.frame(
	Region = app4$region,
	Species = app4$species_name,
	Conservation.Unit = app4$cu_name_pse,
	Current.Spawner.Abundance = prettierNum(app4$curr_spw),
	Years = ifelse(is.na(app4$curr_spw), "", paste0(app4$curr_spw_start_year, "-", app4$curr_spw_end_year)),
	Years.of.Data = stripNA(app4$years_of_data),
	Percentile = stripNA(app4$percentile_status),
	SR = stripNA(app4$sr_status),
	Probability.of.Red.Status = ifelse(is.na(app4$sr_red_prob), " ", paste0(app4$sr_red_prob*100, "%")),
	Probability.of.Amber.Status = ifelse(is.na(app4$sr_yellow_prob), " ", paste0(app4$sr_yellow_prob*100, "%")),
	Probability.of.Green.Status = ifelse(is.na(app4$sr_green_prob), " ", paste0(app4$sr_green_prob*100, "%")),
	WSP = stripNA(app4$wsp_status),
	WSP.Year = stripNA(app4$wsp_status_yr),
	COSEWIC = stripNA(app4$cosewic_status),
	COSEWIC.Year = stripNA(app4$cosewic_status_yr),
	Province = stripNA(app4$province_status),
	Province.Year = stripNA(app4$province_status_yr),
	S25 = ifelse(is.na(app4$`25%_spw`), " ", paste0(prettierNum(round(app4$`25%_spw`)), " (",  prettierNum(round(app4$`25%_spw_lower`)), " - ", prettierNum(round(app4$`25%_spw_upper`)), ")")),
	S50 = ifelse(is.na(app4$`75%_spw`), " ", paste0(prettierNum(round(app4$`75%_spw`)), " (",  prettierNum(round(app4$`75%_spw_lower`)), " - ", prettierNum(round(app4$`75%_spw_upper`)), ")")),
	Sgen = ifelse(is.na(app4$sgen), " ", paste0(prettierNum(round(app4$sgen)), " (",  prettierNum(round(app4$sgen_lower)), " - ", prettierNum(round(app4$sgen_upper)), ")")),
	Smsy = ifelse(is.na(app4$smsy80), "", paste0(prettierNum(round(app4$smsy80)), " (",  prettierNum(round(app4$smsy80_lower)), " - ", prettierNum(round(app4$smsy80_upper)), ")"))
)

###############################################################################
# Write to csv
###############################################################################

write.csv(app4_display, file = "tables/appendix4/appendix4.csv", row.names = FALSE)
