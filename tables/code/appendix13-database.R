###############################################################################
# Appendix 13: Cumulative Pressure by spawning watershed
###############################################################################

library(dplyr)

# Source functions to pull from database
source("https://raw.githubusercontent.com/salmonwatersheds/population-indicators/refs/heads/master/code/functions_general.R")

###############################################################################
# Import view from appdata
###############################################################################

app13 <- retrieve_data_from_PSF_databse_fun(name_dataset = "appdata.vwdl_setr_appendix13")

regions <- data.frame(
	regionid = c(1:14),
	region_name = c("Skeena", "Nass", "Central Coast", "Fraser", "Vancouver Island & Mainland Inlets", "Haida Gwaii", "Columbia", "Yukon", NA, "Northern Transboundary", NA, NA, "East Vancouver Island & Mainland Inlets", "West Vancouver Island")
)
app13$region <- regions$region_name[app13$regionid]

# Filter out Yukon 
app13 <- app13 %>% filter(region != "Yukon")

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
	Species.Qualified = app13$species_qualified,
	Conservation.Unit = app13$cu_name_pse,
	High.Risk = ifelse(is.na(app13$rollup_hi_pct), "0%", paste0(round(app13$rollup_hi_pct*100), "%")),
	Moderate.Risk = ifelse(is.na(app13$rollup_mod_pct), "0%", paste0(round(app13$rollup_mod_pct*100), "%")),
	Low.Risk = ifelse(is.na(app13$rollup_lo_pct), "0%", paste0(round(app13$rollup_lo_pct*100), "%"))
)

###############################################################################
# Write to csv
###############################################################################

write.csv(app13_display, file = "tables/appendix13.csv", row.names = FALSE)

