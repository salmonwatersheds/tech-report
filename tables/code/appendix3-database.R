###############################################################################
# Appendix 3: Biological Status Details
# Compile outcome from dataset102 from various regions
###############################################################################

library(dplyr)

# Source functions to pull from database
source("https://raw.githubusercontent.com/salmonwatersheds/population-indicators/refs/heads/master/code/functions_general.R")

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
# Import relevant views from appdata
###############################################################################


bs <- retrieve_data_from_PSF_databse_fun(name_dataset = "appdata.vwdl_biologicalstatus_output")

# Filter out Yukon for now
bs <- bs %>% filter(region != "Yukon")

###############################################################################
# Make pretty for table display
###############################################################################

app3_display <- data.frame(
	Region = bs$region,
	Species = bs$species_name,
	Conservation.Unit = bs$cu_name_pse,
	Current.Spawner.Abundance = prettierNum(bs$curr_spw),
	Years = ifelse(is.na(bs$curr_spw), "", paste0(bs$curr_spw_start_year, "-", bs$curr_spw_end_year)),
	Years.of.Data = stripNA(bs$years_of_data),
	percentile_status = stripNA(bs$percentile_status),
	percentile_red_prob = stripNA(bs$percentile_red_prob),
	percentile_yellow_prob = stripNA(bs$percentile_yellow_prob),
	percentile_green_prob = stripNA(bs$percentile_green_prob),
	sr_status = stripNA(bs$sr_status),
	sr_red_prob = ifelse(is.na(bs$sr_red_prob), " ", paste0(round(bs$sr_red_prob, 1), "%")),
	sr_yellow_prob = ifelse(is.na(bs$sr_yellow_prob), " ", paste0(round(bs$sr_yellow_prob, 1), "%")),
	sr_green_prob = ifelse(is.na(bs$sr_green_prob), " ", paste0(round(bs$sr_green_prob, 1), "%")),
	WSP = stripNA(bs$wsp_status),
	WSP.Year = stripNA(bs$wsp_status_yr),
	COSEWIC = stripNA(bs$cosewic_status),
	COSEWIC.Year = stripNA(bs$cosewic_status_yr),
	Province = stripNA(bs$province_status),
	Province.Year = stripNA(bs$province_status_yr),
	S25 = ifelse(is.na(bs$`25%_spw_lower`), " ", paste0(prettierNum(round(bs$`25%_spw`)), " (",  prettierNum(round(bs$`25%_spw_lower`)), " - ", prettierNum(round(bs$`25%_spw_upper`)), ")")),
	S50 = ifelse(is.na(bs$`75%_spw`), " ", paste0(prettierNum(round(bs$`75%_spw`)), " (",  prettierNum(round(bs$`75%_spw_lower`)), " - ", prettierNum(round(bs$`75%_spw_upper`)), ")")),
	Sgen = ifelse(is.na(bs$sgen), " ", paste0(prettierNum(round(bs$sgen)), " (",  prettierNum(round(bs$sgen_lower)), " - ", prettierNum(round(bs$sgen_upper)), ")")),
	Smsy = ifelse(is.na(bs$smsy80), "", paste0(prettierNum(round(bs$smsy80)), " (",  prettierNum(round(bs$smsy80_lower)), " - ", prettierNum(round(bs$smsy80_upper)), ")"))
)

###############################################################################
# Write to csv
###############################################################################

write.csv(app3_display, file = "tables/appendix3.csv", row.names = FALSE)
