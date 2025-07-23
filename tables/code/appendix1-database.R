###############################################################################
# Appendix 1: Conservation Unit list
###############################################################################

library(dplyr)

# Source functions to pull from database
source("https://raw.githubusercontent.com/salmonwatersheds/population-indicators/refs/heads/master/code/functions_general.R")

###############################################################################
# Import conservation unit list view from appdata
###############################################################################


app1 <- retrieve_data_from_PSF_databse_fun(name_dataset = "appdata.vwdl_conservationunits")

# Full decoder with Cu breakdowns where PSF CUs differ from DFO CUs
app1_full <- retrieve_data_from_PSF_databse_fun(name_dataset = "appdata.vwdl_conservationunits_decoder")


# Filter out Yukon
app1 <- app1 %>% filter(region != "Yukon")

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
	Species.Qualified = app1$species_qualified,
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

