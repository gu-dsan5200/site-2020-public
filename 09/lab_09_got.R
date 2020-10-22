library(pacman)
p_load(char=c('tidyverse','tidygraph','ggraph'))

got_characters <- read_csv('09/data/union_characters_got.csv')
got_relations <- read_csv('09/data/union_edges_got.csv')

got_graph <- as_tbl_graph(got_relations)

got_graph <- got_graph %>% 
  activate('nodes') %>% 
  left_join(got_characters %>% select(name, shape, house, popularity))

got_graph %>% 
  ggraph(layout = 'fr')+
    geom_node_point(aes(shape = shape), show.legend=F)+
    geom_edge_diagonal(aes(color = color), show.legend=F)

got_graph %>% 
  ggraph(layout = 'fr')+
  geom_node_point(aes(shape = shape, size=popularity*10), show.legend=F)+
  geom_edge_diagonal(aes(color = color), show.legend=F)+
  geom_node_text(aes(label=name), size=2)
