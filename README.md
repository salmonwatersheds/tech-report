# tech-report

July 12, 2023

## Overview

This private repo is for internally collaborating on the tech report that documents the methods for assessing status and trends shown in the [Pacific Salmon Explorer](www.salmonexplorer.ca).

## Files

The tech report is produced as a digital publication using R Markdown and [bookdown] (https://github.com/rstudio/bookdown). Individual .Rmd files are the different chapters in the report, and `Index.Rmd` knits these together into the book.


## Approach to collaborating
We are trying out the approach outlined here to collaborating using both GitHub and Dropbox. Note that the Dropbox version of the tech report is primarily for viewing by team members who are not contributing changes, and folks who are actively working on the tech report should following the steps below to create a local clone:

* Each SWP team member contributing to the tech report but create a clone of this repo on their local machine, *not in Dropbox*. For example, in `Documents/tech-report`. Create this clone from within R Studio (File > New Project > Checkout from GitHub repo).
* **Every time you go to work in your local directory, first pull any changes from GitHub**. This reduces merge conflicts that are a headache to work with. 
* After (soon after) making changes and **before closing your laptop for the day** commit any changes and push these to the GitHub repo.

Steph is in charge of pulling changes to the Dropbox version. She will endeavor to do this on a regular basis so that the version on Dropbox is current. However, as stated above, team members should avoid making changes in the Dropbox version to minimize conflicts if this Dropbox sync is behind the GitHub repo.

The figures in the report are not synced to GitHub as they can be quite large (i.e. the `figures/` folder is in the `.gitignore` file). These are on Dropbox and can be manually copied from there to your local directory. (But figures shouldn't change often so hopefully this isn't a PITA.)

Any questions? Send a Slack message in `tech-report` or `swp_github` channels.

## More information

Contact: Steph Peacock (speacock at psf dot ca)

