# adapted from https://rviews.rstudio.com/2019/03/06/intro-to-graph-analysis/
library(tidyverse)
library(here)

delays_by_month <- read_csv("09/data/small_trains.csv")

distinct_routes <- delays_by_month %>% 
  distinct(service, departure_station, arrival_station)

stations_df <- 
distinct_routes %>% 
  pivot_longer(-service) %>% 
  distinct(service, station = value) %>% 
  mutate(
    service = ifelse(is.na(service), "Other", service),
    value = TRUE
    ) %>% 
  pivot_wider(
              names_from = service,
              values_from = value,
              values_fill = FALSE) %>% 
  mutate(station = stringr::str_to_title(station))






routes_agg <- delays_by_month %>%
  group_by(departure_station, arrival_station) %>%
  summarise(journey_time = mean(journey_time_avg)) %>%
  ungroup() %>%
  mutate(from = departure_station, 
         to = arrival_station) %>%
  select(from, to, journey_time)

library(tidygraph)
graph_routes <- as_tbl_graph(routes_agg)
graph_routes

library(stringr)

graph_routes <- 
  graph_routes %>%
  activate(nodes) %>%
  mutate(
    title = str_to_title(name),
    label = str_replace_all(title, " ", "\n")
    )

stations <- graph_routes %>%
  activate(nodes) %>%
  pull(title)


library(ggplot2)
thm <- theme_minimal() +
  theme(
    legend.position = "none",
     axis.title = element_blank(),
     axis.text = element_blank(),
     panel.grid = element_blank(),
     panel.grid.major = element_blank(),
  ) 
theme_set(thm)

library(ggraph) 

graph_routes %>%
  ggraph(layout = "kk") +
    geom_node_point() +
    geom_edge_diagonal() 

graph_routes %>%
  ggraph(layout = "kk") +
    geom_node_text(aes(label = label, color = name), size = 3) +
    geom_edge_diagonal(color = "gray", alpha = 0.4) 


from <- which(stations == "Arras")
to <-  which(stations == "Nancy")

shortest <- graph_routes %>%
  morph(to_shortest_path, from, to, weights = journey_time)

shortest %>%
  mutate(selected_node = TRUE) %>%
  unmorph()

shortest <- shortest %>%
  mutate(selected_node = TRUE) %>%
  activate(edges) %>%
  mutate(selected_edge = TRUE) %>%
  unmorph() 

shortest <- shortest %>%
  activate(nodes) %>%
  mutate(selected_node = ifelse(is.na(selected_node), 1, 2)) %>%
  activate(edges) %>%
  mutate(selected_edge = ifelse(is.na(selected_edge), 1, 2)) %>%
  arrange(selected_edge)

shortest %>%
  ggraph(layout = "kk") +
    geom_edge_diagonal(aes(alpha = selected_edge), color = "gray") +
    geom_node_text(aes(label = label, color =name, alpha = selected_node ), size = 3) 

