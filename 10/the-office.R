## Obtained from the-office.Rmd by using
## `purl("the-office.Rmd")`
## 
## ----setup, include = FALSE-------------------------
knitr::opts_chunk$set(echo = TRUE,
                      message = FALSE,
                      warning = FALSE)


## ----libraries--------------------------------------
library(tidyverse)
library(tidytext)
library(scales)
# library(googlesheets)
library(igraph)
library(ggraph)
library(widyr)
library(psych)
library(plotly)
library(ggcorrplot)
library(reticulate)
library(cleanNLP)
library(packcircles)
library(patchwork)


## ----get-raw-data, cache = TRUE---------------------
# get key for data sheet
# sheet_key <- gs_ls("the-office-lines") %>% 
#   pull(sheet_key)
# 
# # register sheet to access it
# reg <- sheet_key %>%
#   gs_key()
# 
# # read sheet data into R
# raw_data <- reg %>%
#   gs_read(ws = "scripts")

raw_data <- readxl::read_excel('data/the-office-lines.xlsx')

## ----show-raw-data, echo = FALSE--------------------
 kable(head(raw_data), "html") %>% 
  kable_styling(bootstrap_options = c("striped", "hover"))


## ----clean-data, cache = TRUE-----------------------
mod_data <- raw_data %>% 
  filter(deleted == "FALSE") %>% # remove deleted scenes
  mutate(actions = str_extract_all(line_text, "\\[.*?\\]"), # grab [__]
         line_text_mod = str_trim(str_replace_all(line_text, "\\[.*?\\]", ""))) %>% # remove them from main data
  # mutate_at(vars(line_text_mod), funs(str_replace_all(., "���","'"))) %>% 
  mutate(line_text_mod = str_replace_all(line_text_mod, "���","'")) %>% 
  mutate(speaker = tolower(speaker),
         speaker = str_trim(str_replace_all(speaker, "\\[.*?\\]", "")),
         speaker = str_replace_all(speaker, "micheal|michel|michae$", "michael"))
  

## ----total-episodes---------------------------------
total_episodes <- mod_data %>% 
  unite(season_ep, season, episode, remove = FALSE) %>% # default sep="_"
  summarise(num_episodes = n_distinct(season_ep)) %>% 
  as.integer()

total_episodes


## ----colors, include = FALSE------------------------
office_colors <- c("#19c0f4", "#daad62", "#3c3a47", "#9c311f", "#162737", "#70aa8e", "#947192", "#b7787b", "#038e93", "#36385a", "#7f9ca0", "#8c2d45", "#870e1b", "#807d69", "#005b59", "#9d9ba0", "#7c3814", "#5da8bd") %>% 
  setNames(c("michael", "dwight", "jim",  "pam", "andy", "kevin", "angela", "erin", "oscar", "ryan", "darryl", "phyllis", "kelly", "jan", "toby", "stanley", "meredith", "holly"))


## ----breakdown-of-episodes-scenes-------------------
# proportion of episodes each character was in
episode_proportion <- mod_data %>% 
  unite(season_ep, season, episode, remove = FALSE) %>% 
  group_by(speaker) %>% 
  summarise(num_episodes = n_distinct(season_ep)) %>% 
  mutate(proportion = round((num_episodes / total_episodes) * 100, 1)) %>% 
  arrange(desc(num_episodes))

total_scenes <- mod_data %>% 
  unite(season_ep_scene, season, episode, scene, remove = FALSE) %>% 
  summarise(num_scenes = n_distinct(season_ep_scene)) %>% 
  as.integer()

# proportion of scenes each character was in 
scene_proportion <- mod_data %>% 
  unite(season_ep_scene, season, episode, scene, remove = FALSE) %>% 
  group_by(speaker) %>% 
  summarise(num_scenes = n_distinct(season_ep_scene)) %>% 
  mutate(proportion = round((num_scenes / total_scenes) * 100, 1)) %>% 
  arrange(desc(num_scenes))


## ----show-episode-proportion, echo = FALSE, fig.height = 6, fig.width = 7----
episode_proportion %>%
  filter(!(speaker %in% c("all", "everyone")), proportion > 9) %>% # keep those at least at 9%
  arrange(desc(proportion)) %>%
  ggplot(aes(x = fct_reorder(str_to_title(speaker), proportion),
             y = proportion)) +
  geom_point(size = 7, color = "#19c0f4") +
  geom_text(aes(label=proportion),
            color = "white", size = 2.5) +
  coord_flip() + # make horizontal
  theme_minimal() +
  labs(x = NULL,
       y = "% of episodes",
       title = "% of Episodes Each Character Appeared In") +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "none")


## ----show-scene-proportion, echo = FALSE, fig.height = 6, fig.width = 7----
# scene_proportion %>% 
#   filter(!(speaker %in% c("all", "everyone")), proportion > 1) %>% # Keep more than 1%
#   arrange(desc(proportion)) %>% 
#   ggplot(aes(
#     x = fct_reorder(str_to_title(speaker), proportion), 
#     y = proportion)) +
#   geom_point(size = 7, color = "#947192") +
#   geom_text(aes(label = proportion),
#             color = "white", size = 2.5) +
#   coord_flip() +
#   theme_minimal() +
#   labs(x = NULL, 
#        y = "% of scenes",
#        title = "% of Scenes Each Character Appeared In") +
#   theme(plot.title = element_text(hjust = 0.5),
#         legend.position = "none")


## ----lines------------------------------------------
line_proportion <- mod_data %>% 
  count(speaker) %>% 
  mutate(proportion = round((n / sum(n)) * 100, 1)) %>% 
  arrange(desc(n))

# define main characters based on line proportion
main_characters <- factor(line_proportion %>% 
                            filter(proportion >= 1) %>% 
                            pull(speaker) %>% 
                            fct_inorder() # Keep levels in same order as input
                          )


## ----lines-by-season, fig.height = 8.5, fig.width = 8.5----
# line_proportion_by_season <- mod_data %>% 
#   group_by(season) %>% 
#   count(speaker) %>% 
#   mutate(proportion = round((n / sum(n)) * 100, 1)) %>% 
#   arrange(season, desc(proportion))
# 
# line_proportion_over_time <- line_proportion_by_season %>% 
#   filter(speaker %in% main_characters) %>% 
#   ggplot(aes(x = season, y = proportion, 
#              color = speaker)) +
#   geom_point(size = 2) +
#   geom_line() +
#   scale_x_continuous(breaks = seq(1, 9, 1)) + # where do the ticks go
#   theme_minimal() +
#   theme(legend.position = "none") + # no legend
#   labs(y = "% of lines", 
#        title = "% of Lines by Season") +
#   theme(plot.title = element_text(hjust = 0.5)) + # Centers title
#   facet_wrap(~ factor(str_to_title(speaker), levels = str_to_title(main_characters)), ncol = 3) +
#   geom_text(aes(label=proportion), vjust = -1.2, size = 2) + # put above point
#   ylim(0, 50) + # set y-axis limits
#   scale_color_manual(values = office_colors)
#   
# 
# line_proportion_over_time


## Starting text processing
## 
## ----tokenize, cache = TRUE-------------------------
tidy_tokens <- mod_data %>%
  select(line = id, line_text_mod, everything(), -line_text, -actions, -deleted) %>% 
  unnest_tokens(word, line_text_mod, strip_numeric = TRUE) %>%
  mutate(word = str_replace_all(word, "'s$", "")) # Get rid of 's, e.g. jim's


tidy_tokens_no_stop <- tidy_tokens %>% 
  anti_join(stop_words, by = "word") # Keep lines that DO NOT match the stop words


## ----most-frequent, echo = FALSE--------------------
top_30_word_freq <- tidy_tokens_no_stop %>%
  count(word, sort = TRUE) %>% 
  mutate(proportion = round(n / sum(n), 3)) %>%
  top_n(30, proportion) %>% # Keep top 30 proportion values 
  mutate(word = reorder(word, proportion)) %>% # Fixing levels
  ggplot(aes(word, percent(proportion))) + # labels the proportions
  geom_col(fill = "#19c0f4") +
  labs(x = NULL,
       y = "Word Frequency",
       title = "Most Frequent Words") +
  coord_flip() +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5))

top_30_word_freq

## We have several words here that are stop words, like yeah, uh, etc. Let's remove
## them from the data
## ----custom-stop------------------------------------
custom_stop_words <- bind_rows(data_frame(word = c("yeah", "hey", "uh", "um", "huh", "hmm", "ah", "umm", "uhh", "gonna", "na", "ha", "gotta"), 
                                          lexicon = c("custom")), 
                               stop_words) # This is built in (tidytext)

tidy_tokens_no_stop <- tidy_tokens %>% 
  anti_join(custom_stop_words, by = "word")


## ----word-freq-by-character, echo = FALSE,  fig.height = 14, fig.width = 10----
# drob's awesome functions for ordering faceted bar charts
reorder_within <- function(x, by, within, fun = mean, sep = "___", ...) {
  new_x <- paste(x, within, sep = sep)
  stats::reorder(new_x, by, FUN = fun)
}

scale_x_reordered <- function(..., sep = "___") {
  reg <- paste0(sep, ".+$")
  ggplot2::scale_x_discrete(labels = function(x) gsub(reg, "", x), ...)
}

# plot top 10 highest word frequencies by character
top_10_word_freq_character <- tidy_tokens_no_stop %>%
  filter(speaker %in% main_characters) %>%
  count(speaker, word, sort = TRUE) %>% 
  group_by(speaker) %>% 
  mutate(proportion = round(n / sum(n), 3)) %>%
  top_n(10, proportion) %>% 
  ggplot(aes(reorder_within(word, proportion, speaker), percent(proportion), fill = speaker)) +
  geom_col() +
  scale_x_reordered() +
  labs(x = NULL,
       y = "Word Frequency",
       title = "Frequent Words") +
  coord_flip() +
  theme_minimal() +
  facet_wrap(~ factor(str_to_title(speaker), levels = str_to_title(main_characters)), scales = "free", ncol = 3) + 
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5),
        axis.text.x=element_text(size=6),
        axis.text.y = element_text(size=4),
        strip.text = element_text(size=6)) +
  scale_fill_manual(values = office_colors)

top_10_word_freq_character


## ----tf-idf-----------------------------------------
tidy_tokens_tf_idf <- tidy_tokens %>%
  count(speaker, word, sort = TRUE) %>%
  ungroup() %>% 
  filter(speaker %in% main_characters) %>% 
  bind_tf_idf(word, speaker, n) # compute tf-idf metric. speaker defines the "document"

## The td-idf score tries to show which terms are more specific to this document 
## within a corpus of documents (here, speakers)


## ----tf-idf-plot, echo = FALSE, fig.height = 14, fig.width = 10----
top_10_tf_idf_character <- tidy_tokens_tf_idf %>%
  arrange(desc(tf_idf)) %>%
  group_by(speaker) %>% 
  top_n(10, tf_idf) %>% 
  ungroup %>%
  ggplot(aes(reorder_within(word, tf_idf, speaker), tf_idf, fill = speaker)) +
  geom_col(show.legend = FALSE) +
  scale_x_reordered() +
  labs(x = NULL, 
       y = "tf-idf",
       title = "Words by tf-Idf") +
  facet_wrap(~ factor(str_to_title(speaker), levels = str_to_title(main_characters)), scales = "free", ncol = 3) +
  coord_flip() +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_fill_manual(values = office_colors)+
  theme(axis.text = element_text(size=6),
        strip.text = element_text(size=6))

top_10_tf_idf_character


## ----word-freq-correlation, fig.height = 7, fig.width = 8----
frequency_by_character <- tidy_tokens_no_stop %>%
  filter(speaker %in% main_characters) %>% 
  count(speaker, word, sort = TRUE) %>% 
  group_by(speaker) %>% 
  mutate(proportion = n / sum(n)) %>% 
  select(-n) %>% 
  pivot_wider(names_from='speaker', values_from='proportion')


cor_all <- corr.test(frequency_by_character[, -1], adjust = "none")
cor_plot <- ggcorrplot(cor_all[["r"]], # Just the correlation matrix
                       hc.order = TRUE, # Ordered using clustering
                       type = "lower",
                       method = "circle",
                       colors = c("#E46726", "white", "#6D9EC1"), # low, mid high
                       lab = TRUE,
                       lab_size = 2.5)

cor_plot


## ----dwight-pam-comparison--------------------------
## 
## Pam & Dwight have the highest correlation
pam_dwight_words <- frequency_by_character %>% 
  select(word, pam, dwight) %>% 
  ggplot(aes(x = pam, y = dwight, color = abs(pam - dwight), label = word)) +
  geom_abline(color = "gray40", lty = 2) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.3, height = 0.3) +
  scale_x_log10(labels = percent_format(accuracy=0.01)) +
  scale_y_log10(labels = percent_format(accuracy=0.01)) +
  labs(x = "Pam",
       y = "Dwight",
       title = "Word Frequncy Comparison: Dwight and Pam") +
  theme(legend.position = "none")

pam_dwight_words

ggplotly(pam_dwight_words, tooltip = c("word"))


## ----log-ratio--------------------------------------
## log-odds ratios between Dwight and Pam words
word_ratios_dwight_pam <- tidy_tokens_no_stop %>%
  filter(speaker %in% c("dwight", "pam")) %>% 
  count(word, speaker) %>%
  filter(n >= 10) %>%
  spread(speaker, n, fill = 0) %>%
  mutate(across(where(is.numeric), ~(.+1)/sum(.+1))) %>% # Avoiding 0/0 issues
  # mutate_if(is.numeric, funs((. + 1) / sum(. + 1))) %>% 
  mutate(log_ratio = log2(dwight / pam)) %>% # log base 2 scale
  arrange(desc(log_ratio))


## ----log-ratio-table, echo = FALSE------------------
knitr::kable(word_ratios_dwight_pam %>% 
        arrange(abs(log_ratio)) %>% 
        head(10), "html") %>% 
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover"))


## ----log-ratio-differences--------------------------
word_ratios_dwight_pam %>%
  group_by(direction = ifelse(log_ratio < 0, 'Pam', "Dwight")) %>%
  top_n(15, abs(log_ratio)) %>%
  ungroup() %>%
  mutate(word = reorder(word, log_ratio)) %>% # Re-ordering factor for plotting
  ggplot(aes(word, log_ratio, color = direction)) +
  geom_segment(aes(x = word, xend = word,
                     y = 0, yend = log_ratio),
                 size = 1.1, alpha = 0.6) +
  geom_point(size = 2.5) +
  coord_flip() +
  theme_minimal() +
  labs(x = NULL, 
       y = "Relative Occurrence",
       title = "Words Paired with Dwight and Pam") +
  theme(plot.title = element_text(hjust = 0.5),
        legend.title = element_blank()) +
  scale_y_continuous(breaks = seq(-6, 6), 
                     labels = c("64x", "32x", "16x","8x", "4x", "2x", # This is due to log base 2
                                  "Same", "2x", "4x", "8x", "16x", "32x", "64x")) +
  scale_color_manual(values = c("#daad62", "#9c311f"))


## ----bigrams----------------------------------------
tidy_bigrams <- mod_data %>%
  select(line = id, line_text_mod, everything(), -line_text, -actions, -deleted) %>% 
  unnest_tokens(bigram, line_text_mod, token = "ngrams", n = 2)


## ----bigrams-table, echo = FALSE--------------------
# kable(tidy_bigrams %>% 
#         head(10), "html") %>% 
#   kable_styling(bootstrap_options = c("striped", "hover"))
# 

## ----bigram-tf-idf, cache = TRUE--------------------
# remove stop words from bigrams and calculate tf-idf
bigram_tf_idf_no_stop <- tidy_bigrams %>% 
  filter(speaker %in% main_characters, !is.na(bigram)) %>% 
  separate(bigram, c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% custom_stop_words$word,
         !word2 %in% custom_stop_words$word) %>% 
  unite(bigram, word1, word2, sep = " ") %>% 
  count(speaker, bigram) %>%
  bind_tf_idf(bigram, speaker, n) %>%
  arrange(desc(tf_idf))


## ----bigram-tf-idf-plot, echo = FALSE, cache = TRUE, fig.height = 14, fig.width = 10----
## 
## td-idf of the bigrams
bigram_tf_idf_no_stop %>%
  group_by(speaker) %>% 
  top_n(8, tf_idf) %>% 
  ungroup %>%
  ggplot(aes(reorder_within(bigram, tf_idf, speaker), tf_idf, fill = speaker)) +
  geom_col(show.legend = FALSE) +
  scale_x_reordered() +
  labs(x = NULL, 
       y = "tf-idf",
       title = "Bigrams TF-Idf") +
  facet_wrap(~ factor(str_to_title(speaker), levels = str_to_title(main_characters)), scales = "free", ncol = 3) +
  coord_flip() +
  scale_fill_manual(values = office_colors) +
  theme(plot.title = element_text(hjust = 0.5))


## ----pairwise-cor, cache = TRUE---------------------
word_cors_scene <- tidy_tokens_no_stop %>%
  unite(se_ep_sc, season, episode, scene) %>%
  group_by(word) %>%
  filter(n() >= 20) %>%
  pairwise_cor(word, se_ep_sc, sort = TRUE)


## ----pairwise-cor-plot, echo = FALSE----------------
## 
## words most correlated with the specified words
word_cors_scene %>%
  filter(item1 %in% c("corporate", "scranton", "office", "love")) %>%
  group_by(item1) %>%
  top_n(10, correlation) %>%
  ungroup() %>%
  ggplot(aes(reorder_within(item2, correlation, item1), correlation, fill = item1)) +
  geom_bar(stat = "identity") +
  scale_x_reordered() +
  facet_wrap(~ item1, scales = "free") +
  labs(x = NULL) +
  theme(legend.position = "none") +
  coord_flip() +
  scale_fill_manual(values = c("#19c0f4", "#daad62", "#3c3a47", "#9c311f"))


## ----network-graph, cache = TRUE,  fig.height = 8, fig.width = 8----
## 
## Graph of bigrams
set.seed(1234)

word_cors_scene %>%
  filter(correlation > .30) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = correlation), show.legend = FALSE) +
  geom_node_point(color = "lightblue", size = 5) +
  geom_node_text(aes(label = name), repel = TRUE) +
  theme_void()


## ----annotate, eval = FALSE-------------------------
# tif_data <- mod_data %>%
#   select(id, line_text_mod, season, episode, scene, speaker)
# 
# cnlp_init_spacy()
# obj <- cnlp_annotate(tif_data, as_strings = TRUE)
# 
# 
# ## ----get-obj, include = FALSE, cache = TRUE---------
# obj <- readRDS("~/Documents/DataProjects/the_office/spacy_NLP.rds")
# 
# 
# ## ----obj--------------------------------------------
# names(obj)
# 
# 
# ## ----entities, cache = TRUE-------------------------
# entities <- cnlp_get_entity(obj)
# 
# 
# ## ----entities-table, echo = FALSE-------------------
#  kable(head(entities, 10), "html") %>% 
#   kable_styling(bootstrap_options = c("striped", "hover"))
# 
# 
# ## ----entities-tf-idf, cache = TRUE------------------
# meta <- mod_data %>% 
#   select(1:4, 6)
# 
# tf_idf_entities <- entities %>% 
#   mutate_at(vars(id), as.integer) %>% 
#   left_join(meta, by = "id") %>% 
#   filter(speaker %in% main_characters) %>% 
#   count(entity, speaker, sort = TRUE) %>% 
#   bind_tf_idf(entity, speaker, n)
# 
# 
# ## ----entities-tf-idf-plot, echo = FALSE, cache = TRUE, fig.height = 14, fig.width = 10----
# tf_idf_entities %>%
#   arrange(desc(tf_idf)) %>%
#   group_by(speaker) %>% 
#   top_n(10, tf_idf) %>% 
#   ungroup %>%
#   ggplot(aes(reorder_within(entity, tf_idf, speaker), tf_idf, fill = speaker)) +
#   geom_col(show.legend = FALSE) +
#   scale_x_reordered() +
#   labs(x = NULL, 
#        y = "tf-idf",
#        title = "Entity Recognition") +
#   facet_wrap(~ factor(str_to_title(speaker), levels = str_to_title(main_characters)), scales = "free", ncol = 3) +
#   coord_flip() +
#   scale_fill_manual(values = office_colors) +
#   theme(plot.title = element_text(hjust = 0.5))
# 
# 
# ## ----dependencies, cache = TRUE---------------------
# dependencies <- cnlp_get_dependency(obj, get_token = TRUE)
# 
# 
# ## ----dependencies-table, echo = FALSE---------------
# kable(head(dependencies, 10), "html") %>% 
#   kable_styling(bootstrap_options = c("striped", "hover"))
# 
# 
# ## ----dobj-------------------------------------------
# dobj <- dependencies %>%
#   filter(relation == "dobj") %>%
#   select(id = id, verb = lemma, noun = word_target) %>%
#   select(id, verb, noun) %>%
#   count(verb = tolower(verb), noun = tolower(noun), sort = TRUE)
# 
# 
# ## ----bubbles, cache = TRUE--------------------------
# dobj_packed_bubble <- function(data, word) {
#    
#   filtered <- data %>% 
#     filter(noun == word)
#   
#   packing <- circleProgressiveLayout(filtered$n, sizetype = "area")
#   
#   verts <- circleLayoutVertices(packing, npoints = 50)
#   
#   combined <- filtered %>% 
#     bind_cols(packing)
#   
#   plot <- ggplot(data = verts) + 
#   geom_polygon(aes(x, y, group = id, fill = factor(id)), color = "black", show.legend = FALSE, alpha = 0.8) + 
#   coord_equal() + 
#   geom_text(data = combined, aes(x, y, label = ifelse(radius > .9, verb, "")), check_overlap = TRUE) +
#   theme_minimal() +
#   labs(title = str_to_title(word)) +
#   theme(plot.title = element_text(hjust = 0.5),
#         axis.title = element_blank(), 
#         axis.ticks = element_blank(), 
#         axis.text = element_blank()) 
# }
# 
# direct_objects <- c("god", "time", "love", "office")
# plots <- setNames(map(direct_objects, ~ dobj_packed_bubble(dobj, .)), direct_objects)
# 
# plots[["god"]] + plots[["time"]] + plots[["love"]] + plots[["office"]] + plot_layout(ncol = 2)
# 
# 
# ## ----twss, echo = FALSE, cache = TRUE---------------
# twss <- read_csv("~/Documents/DataProjects/the_office/twss.csv")
# 
# kable(twss, "html") %>% 
#   kable_styling(bootstrap_options = c("striped", "hover"))
# 
