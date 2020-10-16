url <- "http://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard?&dates=2018&seasontype=2&week=1"

resp <- httr::GET(url)


httr::content(resp, type = "text")
write(httr::content(resp, type = "text"), file = "05/data/nfl-2018-week1.json", ncolumns = 1)
str(httr::content(resp), max.level = 3, list.len = 4)


library(tidyverse)

nfl <- readLines("05/data/nfl-2018-week1.json")

nfl_list <- jsonlite::fromJSON(nfl)
str(nfl_list, max.level = 1)
