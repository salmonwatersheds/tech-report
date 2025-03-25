###############################################################################
# Appendix 3: Biological Status Details
# Compile outcome from dataset102 from various regions
###############################################################################

library(dplyr)
library(RPostgres)

# Function to add commas if >= 10,000
prettierNum <- function(x){
	x1 <- character(length(x))
	for(i in 1:length(x)){
		if(is.na(x[i])){
			x1[i] <- " "
		} else {
			if(x[i] >= 1000){
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
dsn_hostname <- "3.99.23.175"  # Specify host name e.g.:"aws-us-east-1-portal.4.dblayer.com"
dsn_port <- "5432"                # Specify your port number. e.g. 98939
dsn_uid <- "salmonwatersheds"         # Specify your username. e.g. "admin"
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
# Import appendix4 view from appdata
###############################################################################

# Get app3 view
app3 <- dbGetQuery(
	conn = connec, 
	statement = "SELECT * FROM appdata.vwdl_setr_appendix4"
)

app3$years_of_data <- as.numeric(app3$years_of_data)
###############################################################################
# Make pretty for table display
###############################################################################

app3_display <- data.frame(
	Region = app3$region,
	Species = app3$species_name,
	Conservation.Unit = app3$cu_name_pse,
	Current.Spawner.Abundance = prettierNum(app3$curr_spw),
	Years = ifelse(is.na(app3$curr_spw), "", paste0(app3$curr_spw_start_year, "-", app3$curr_spw_end_year)),
	Years.of.Data = stripNA(app3$years_of_data),
	percentile_status = stripNA(app3$percentile_status),
	percentile_red_prob = stripNA(app3$percentile_red_prob),
	percentile_yellow_prob = stripNA(app3$percentile_yellow_prob),
	percentile_green_prob = stripNA(app3$percentile_green_prob),
	sr_status = stripNA(app3$sr_status),
	sr_red_prob = ifelse(is.na(app3$sr_red_prob), " ", paste0(round(app3$sr_red_prob, 1), "%")),
	sr_yellow_prob = ifelse(is.na(app3$sr_yellow_prob), " ", paste0(round(app3$sr_yellow_prob, 1), "%")),
	sr_green_prob = ifelse(is.na(app3$sr_green_prob), " ", paste0(round(app3$sr_green_prob, 1), "%")),
	WSP = stripNA(app3$wsp_status),
	WSP.Year = stripNA(app3$wsp_status_yr),
	COSEWIC = stripNA(app3$cosewic_status),
	COSEWIC.Year = stripNA(app3$cosewic_status_yr),
	Province = stripNA(app3$province_status),
	Province.Year = stripNA(app3$province_status_yr),
	S25 = ifelse(is.na(app3$`25%_spw`), " ", paste0(prettierNum(round(app3$`25%_spw`)), " (",  prettierNum(round(app3$`25%_spw_lower`)), " - ", prettierNum(round(app3$`25%_spw_upper`)), ")")),
	S50 = ifelse(is.na(app3$`75%_spw`), " ", paste0(prettierNum(round(app3$`75%_spw`)), " (",  prettierNum(round(app3$`75%_spw_lower`)), " - ", prettierNum(round(app3$`75%_spw_upper`)), ")")),
	Sgen = ifelse(is.na(app3$sgen), " ", paste0(prettierNum(round(app3$sgen)), " (",  prettierNum(round(app3$sgen_lower)), " - ", prettierNum(round(app3$sgen_upper)), ")")),
	Smsy = ifelse(is.na(app3$smsy80), "", paste0(prettierNum(round(app3$smsy80)), " (",  prettierNum(round(app3$smsy80_lower)), " - ", prettierNum(round(app3$smsy80_upper)), ")"))
)

###############################################################################
# Write to csv
###############################################################################

write.csv(app3_display, file = "tables/appendix3.csv", row.names = FALSE)
