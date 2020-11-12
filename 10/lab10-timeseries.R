library(tidyverse)
library(janitor)
library(lubridate)

raw <- read_csv("10/data/crash_dataset.csv") %>% clean_names()

crash_time <- make_datetime(
  year = 2010L,
  month = 5L,
  day = 6L,
  hour = 14,
  min = 32,
  sec = 00,
  tz = "EST5EDT"
)

# add date to time
dtbl <- raw %>%
  select(time,
         ticker = issue_sym_id,
         avg_price = avg_entrd_unit_pr,
         short_sell_qty,
         sell_qty,
         buy_qty) %>%
  mutate(
    time = make_datetime(
      year = 2010L,
      month = 5L,
      day = 6L,
      hour = lubridate::hour(time),
      min = lubridate::minute(time),
      sec = lubridate::second(time),
      tz = "EST5EDT"
    )
  )

price <-
  dtbl %>%
  filter(ticker == "AAPL") %>%
  ggplot(aes(x = time, y = avg_price)) +
  geom_line() +
  geom_vline(xintercept = crash_time,
             color = "red",
             linetype = "dashed") +
  scale_y_continuous("Price", labels = scales::dollar_format()) +
  scale_x_datetime(
    date_labels = "%H:%M",
    date_breaks = "10 min",
    date_minor_breaks = "1 min"
  ) +
  theme_minimal() +
  theme(
    axis.title.x = element_blank()
  )

vol_long <- 
  dtbl %>%
  filter(ticker == "AAPL") %>%
  ggplot(aes(x = time)) +
  geom_linerange(aes(ymin = 0,
                     ymax = short_sell_qty,
                 color = "short")) +
  geom_linerange(aes(ymin = short_sell_qty,
                     ymax = sell_qty,
                 colour = "long")) +
  geom_vline(xintercept = crash_time,
             color = "red",
             linetype = "dashed") +
  scale_y_continuous("Volume", labels = scales::label_comma()) +
  scale_x_datetime(
    date_labels = "%H:%M",
    date_breaks = "10 min",
    date_minor_breaks = "1 min"
  ) +
  scale_color_viridis_d("Sale Type", labels = c("Long", "Short")) +
  theme_minimal() +
  theme(
    axis.title.x = element_blank()
  )

library(cowplot)
plot_grid(price,
          vol_long,
          ncol = 1,
          align = "v",
          axis = "lr")

# now add the title
# https://wilkelab.org/cowplot/articles/plot_grid.html
title <- ggdraw() +
  draw_label(
    "Apple Computer (AAPL) Price and Volume: May 6, 2010 Flash Crash",
    fontface = 'bold') 

plot_grid(
  title,
  price,
  vol_long,
  ncol = 1,
  align = "v",
  axis = "lr",
  rel_heights = c(0.1, 1, 1))
