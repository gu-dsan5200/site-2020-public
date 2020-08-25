library(tibble, quietly = T, warn.conflicts = F)
library(dplyr, quietly = T, warn.conflicts = F)
library(stringr, quietly = T, warn.conflicts = F)

nolecture <- as.Date(c("2020-11-26"))

lec_sched_vec <- c(
  seq.Date(
    from = as.Date("2020-08-27"),
    to = as.Date("2020-12-03"),
    by = "week"
  )
) %>%
  .[!(. %in% nolecture)] %>%
  sort(.)

course_tbl <- tribble(
  ~topics, ~activity, ~readings, ~due,
  "History and purpose of dataviz, designing for an Audience", "Setup environment", "", "",
  "Picking the right visualization", "Build an R Markdown website", "*", "A1 due Fri 9/4",
  "Making readable graphics, putting it all together", "Activity 3", "*", "A2 due Fri 9/11",
  "Tools overview", "Activity 4", "*", "A3 due Fri 9/18",
  "Data prep for visualization", "Wrangle/structure a complex dataset for dataviz", "*", "",
  "EDA Visualization, naniar, outliers", "Understand your data", "*", "A4 due Fri 10/2",
  "Static graphics with R - ggplot and ecosystem", "Make graphs with R", "*", "A5 due Fri 10/9",
  "Static graphics with Python - matplotlib", "Make graphs with Python", "*", "A6 due Fri 10/16",
  "Maps and geospatial data", "Cloropleth: mapping the FL 2000 election", "*", "A7 due Fri 10/23",
  "Networks", "Build and draw a network", "*", "A8 due Fri 10/31",
  "Dynamic graphs 1", "Activity 11", "*", "A9 due Fri 11/6",
  "Dynamic graphs 2", "Activity 12", "*", "",
  "Visualizing model dianostics and results", "ML diagnostics", "*", "A10 due Fri 11/20",
  "Wrapup", "", "", "Final Project and Online Portfolio due Fri 12/11",
)


sched <-
  course_tbl %>%
  mutate(date = lec_sched_vec,
         session = as.integer(1:nrow(.)))

sched <-
  sched %>%
  mutate(date = format(date, "%b %d")) %>%
  select(session, date, topics, activity, readings, due)

# sched %>%
#   knitr:::kable(., "markdown",
#                 col.names = c("Class", "Date", "Topics", "Activity",
#                               "Readings", "Notes")
#   )


