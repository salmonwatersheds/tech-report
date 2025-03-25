# Line of code to publish book to https://bookdown.org/salmonwatersheds/tech-report-staging/
library(rsconnect)
bookdown::publish_book(name = "tech-report-staging", render = "local",account = "salmonwatersheds", server = "bookdown.org")
