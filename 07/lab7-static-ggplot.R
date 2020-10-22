library(tidyverse)
library(skimr)
library(arrow)


<<<<<<< HEAD
acc_url_f <- "https://bigdatateaching.blob.core.windows.net/public/us-traffic-accidents/accidents.feather"
system.time(acc_in <- read_feather(data_url))

acc_url_r <- "https://bigdatateaching.blob.core.windows.net/public/us-traffic-accidents/acc.rds"
system.time(acc_in <- readRDS(data_url))

acc_sum_url <- "https://bigdatateaching.blob.core.windows.net/public/us-traffic-accidents/skim_summary.rds"
skim_summary <- readRDS(url(acc_sum_url))

skim_summary <- read_feather('data/skim_summary.feather')

system.time(
acc <- readRDS("06/data/acc.rds")
)
# 30 sec
library(arrow)

acc_in <- read_feather('data/accidents.feather')
# system.time(write_feather(x = acc, sink = "07/data/accidents.feather"))

if(!file.exists('07/data/accidents.feather')){
  download.file(acc_url_f, '07/data/accidents.feather')
}
system.time(acc_in <- read_feather("07/data/accidents.feather"))
=======
acc_url <- "https://bigdatateaching.blob.core.windows.net/public/us-traffic-accidents/accidents.feather"
system.time(acc_in <- read_feather("07/data/accidents.feather"))

# Download this file: https://bigdatateaching.blob.core.windows.net/public/us-traffic-accidents/acc.rds
system.time(acc_in <- readRDS(acc_url))

acc_sum_url <- "06/data/skim_summary.rds"
skim_summary <- readRDS(acc_sum_url)

>>>>>>> 576bc7887edfe630365579babe3357859a67ca9e

library(lubridate)
acc <- acc_in %>% 
  mutate(duration = end_time - start_time,
         year = year(start_time),
         date = date(start_time), 
         hour = hour(start_time),
         day = wday(start_time, label = T, abbr = T),
         weekend = day %in% c("Sat", "Sun"))
         

<<<<<<< HEAD
skim_summary <- readRDS("06/data/skim_summary.rds")
=======
>>>>>>> 576bc7887edfe630365579babe3357859a67ca9e

# lets make a bar plot to show the values of n_missing for all variables
skim_summary %>% 
  ggplot() +
  geom_bar(aes(x = skim_variable,
               y = n_missing))


# ugh, error... why?

<<<<<<< HEAD
my_theme = theme_bw() + theme(axis.text.x = element_text(angle=45, hjust=1))

theme_set(my_theme)

=======
>>>>>>> 576bc7887edfe630365579babe3357859a67ca9e
skim_summary %>% 
  ggplot() +
  geom_bar(aes(x = skim_variable,
               y = n_missing), 
           stat = "identity")


skim_summary %>% 
  ggplot() +
  geom_col(aes(x = skim_variable,
               y = n_missing, 
               fill = skim_type))


skim_summary %>%
  filter(skim_type == "numeric") %>% 
  ggplot() +
  geom_col(aes(x = reorder(skim_variable, -n_missing), 
               y = n_missing))

<<<<<<< HEAD
## AD
acc_num_missing <- acc %>% select(where(is.numeric)) %>% 
  naniar::miss_var_summary()
ggplot(acc_num_missing, aes(x = fct_reorder(variable, -pct_miss), 
                            y = pct_miss/100))+
  geom_col(width=0.95)+
  theme_bw()+
  labs(title = "Percent of missing values for numerical variables") +
  scale_y_continuous(labels = scales::percent) +
  xlab("Variable Name") +
  ylab("Percent") +
  theme(plot.title = element_text (hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust=1))

## MV
=======

>>>>>>> 576bc7887edfe630365579babe3357859a67ca9e
skim_summary %>%
  mutate(missing_pct = n_missing / skim_summary %>% attr(which = "data_rows")) %>% 
  filter(skim_type == "numeric") %>% 
  ggplot() +
  geom_col(aes(x = reorder(skim_variable, -missing_pct), 
               y = missing_pct),
           width = 0.95) + #default width is 0.95
  theme_bw() +
  labs(title = "Percent of missing values for numerical variables") +
  scale_y_continuous(labels = scales::percent, limits = c(0,1)) +
  xlab("Variable Name") +
  ylab("Percent") +
  theme(plot.title = element_text (hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust=1))

# Remove end_lat, end_lng, number, 
ignore_fields <- c("end_lat", "end_lng", "number") 

skim_summary %>%
  filter(!skim_variable %in% ignore_fields) %>%  
  mutate(missing_pct = n_missing / skim_summary %>% attr(which = "data_rows")) %>% 
  filter(skim_type == "numeric") %>% 
  ggplot() +
  geom_col(aes(x = reorder(skim_variable, -missing_pct), 
               y = missing_pct,
               fill = skim_type),
           width = 0.95) + #default width is 0.95
  theme_bw() +
  labs(title = "Percent of missing values for numerical variables") +
  scale_y_continuous(labels = scales::percent, limits = c(0,1)) +
  xlab("Variable Name") +
  ylab("Percent") +
  theme(plot.title = element_text (hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust=1))

skim_summary %>%
  filter(!skim_variable %in% ignore_fields) %>%  
  mutate(missing_pct = n_missing / skim_summary %>% attr(which = "data_rows")) %>% 
#  filter(skim_type == "numeric") %>% 
  ggplot() +
  geom_col(aes(x = reorder(skim_variable, -missing_pct), 
               y = missing_pct,
               fill = skim_type),
           width = 0.95) + #default width is 0.95
  theme_bw() +
  labs(title = "Percent of missing values for numerical variables") +
  scale_y_continuous(labels = scales::percent, limits = c(0,1)) +
  xlab("Variable Name") +
  ylab("Percent") +
  theme(plot.title = element_text (hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust=1)) +
  facet_grid(skim_type ~ .)


<<<<<<< HEAD
=======

>>>>>>> 576bc7887edfe630365579babe3357859a67ca9e
skim_summary %>%
  filter(!skim_variable %in% ignore_fields) %>%  
  mutate(missing_pct = n_missing / skim_summary %>% attr(which = "data_rows")) %>% 
  filter(skim_type == "numeric") %>% 
  ggplot() +
  geom_col(aes(x = reorder(skim_variable, -missing_pct), 
               y = missing_pct,
               fill = skim_type),
           width = 0.95) + #default width is 0.95
  theme_bw() +
  labs(title = "Percent of missing values for numerical variables") +
  scale_y_continuous(labels = scales::percent, limits = c(0,1)) +
  xlab("Variable Name") +
  ylab("Percent") +
  theme(plot.title = element_text (hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust=1))


<<<<<<< HEAD
skim_summary <- skim_summary %>% 
  mutate(type_factor = factor(skim_type, levels = c("numeric", "character", 
               "logical", "POSIXct")))
           
=======
skim_summary <- 
  mutate(type_factor = as.factor(skim_type, levels = c("numeric", "character", 
               "logical", "POSIXct")))
           

>>>>>>> 576bc7887edfe630365579babe3357859a67ca9e
p <- ggplot(data = skim_summary %>%  
              mutate(missing_pct = n_missing / skim_summary %>% attr(which = "data_rows"),
                     type_factor = factor(skim_type, levels = c("numeric", "character", 
               "logical", "POSIXct"))),
            aes(x = reorder(skim_variable, -missing_pct), 
               y = missing_pct,
               fill = type_factor)) +
  theme_bw() +
  theme(plot.title = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.position = "none",
        axis.text.x = element_text(angle = 30, hjust=1)) 
  
var_numeric <- p + 
  geom_col(data = function(x) x %>% filter(skim_type == "numeric")) +
  scale_y_continuous(labels = scales::percent, limits = c(0,1)) 

  

var_char <- p + 
    geom_col(data = function(x) x %>% filter(skim_type == "character")) +
    scale_y_continuous(labels = scales::percent) 


var_date <- p + 
    geom_col(data = function(x) x %>% filter(skim_type == "POSIXct")) +
      scale_y_continuous(labels = scales::percent) 


var_logical <- p + 
    geom_col(data = function(x) x %>% filter(skim_type == "logical")) +
      scale_y_continuous(labels = scales::percent) 


<<<<<<< HEAD




=======
>>>>>>> 576bc7887edfe630365579babe3357859a67ca9e
library(cowplot)
plot_grid(var_numeric, var_char, var_logical, var_date,
  nrow = 4
)



library(ggalluvial)
acc %>% 
  count(weather_condition,
            precipitation_value = !is.na(precipitation_in)) %>% 
  ggplot(aes(y = n, axis1 = weather_condition, axis2 = precipitation_value)) +
  geom_alluvium(aes(fill = precipitation_value)) +
  geom_stratum(width = 1/12, fill = "black", color = "grey") +
<<<<<<< HEAD
  geom_label(stat = "stratum", size=2,aes(label = after_stat(stratum))) +
=======
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) +
>>>>>>> 576bc7887edfe630365579babe3357859a67ca9e
  scale_x_discrete(limits = c("Condition", "Precipitation Value"), expand = c(.05, .05)) +
  scale_fill_brewer(type = "qual", palette = "Set1")


skim_summary %>% 
  ggplot() +
  geom_bar(aes(x = reorder(skim_variable, -n_missing), 
               y = n_missing,
               fill = skim_type),
           color = "black",
           stat = "identity") +
  scale_fill_brewer(palette = "Set1") 
#b (binned), c (continuous), d (discrete)

skim_summary %>% 
  ggplot() +
  geom_bar(aes(x = reorder(skim_variable, -n_missing), 
               y = n_missing,
               fill = skim_type),
           stat = "identity") +
  scale_fill_brewer(palette = "Set1") +
  facet_grid(. ~ skim_type, drop = F)



skim_summary %>% 
  ggplot() +
  geom_bar(aes(x = reorder(skim_variable, -n_missing), 
               y = n_missing,
               fill = skim_type),
           stat = "identity") +
  scale_fill_viridis_d(option = "plasma")
#b (binned), c (continuous), d (discrete)





# Let's focus on the quantitative variables

# Point values
skim_summary %>% 
  filter(skim_type == "numeric") %>% 
<<<<<<< HEAD
  ggplot(aes(x = "1", 
=======
  ggplot(aes(x = "whatever",
             # x = skim_variable,
>>>>>>> 576bc7887edfe630365579babe3357859a67ca9e
             lower = numeric.p25,
             upper = numeric.p75,
             middle = numeric.mean,
             ymin = numeric.p0,
             ymax = numeric.p100)) +
  geom_boxplot(stat = "identity") +
  facet_grid(skim_variable ~ ., scales = "free_y")
             
              
# Accidents per hour


# For a bar plot use geom_bar (which summarizes) or geom_col which doesn't
# Let ggplot summarize
acc %>% 
  ggplot(aes(x = hour, fill = factor(year))) +
  geom_bar()

acc %>% 
  ggplot(aes(x = hour, fill = factor(year))) +
  geom_bar(position = "dodge")
             

# For a line plot, you have to calculate the statistics

acc %>% 
  count(year, hour) %>% 
  ggplot(aes(x = hour, color = factor(year))) +
  geom_line(aes(y = n, group = year)) +
  scale_colour_viridis_d()



acc %>% 
  ggplot(aes(x = hour, fill = factor(year))) +
  geom_line(aes(y = n))


# Time of day and day of the week
acc %>% 
  select(year, hour, day, weekend) %>% 
  ggplot(aes(x = hour, fill = factor(year))) +
  geom_bar() +
  scale_fill_viridis_d() +
<<<<<<< HEAD
  facet_grid(year ~ .)
=======
  facet_grid(year ~ ., scales = "free_y")
>>>>>>> 576bc7887edfe630365579babe3357859a67ca9e


acc %>% 
  select(year, hour, day, weekend) %>% 
  ggplot(aes(x = hour, fill = factor(year))) +
  geom_bar() +
  scale_fill_viridis_d() +
  facet_grid(year ~ ., scales = "free_y")

acc %>% 
  select(year, hour, day, weekend) %>% 
  filter(year != 2015) %>% 
  ggplot(aes(x = hour, fill = factor(year))) +
  geom_bar() +
  scale_fill_viridis_d() +
  facet_grid(year ~ day, scales = "free_y") +
  theme_bw() +
  scale_y_continuous(labels = scales::comma)



# Type, duration, and backup

acc %>% 
<<<<<<< HEAD
  select(severity, duration, distance_mi) %>% 
  ggplot() +
  geom_hex(aes(x = as.numeric(duration/3600),
=======
  select(severity, duration, distance_mi) %>%
  mutate(duration = as.numeric(duration/3600)) %>% 
  filter(duration <= 24, duration > 0, distance_mi <= 100) %>% 
  ggplot() +
  geom_bin2d(aes(x = duration,
>>>>>>> 576bc7887edfe630365579babe3357859a67ca9e
                 y = distance_mi)) +
  facet_grid(severity ~ .)

acc %>% transmute(duration_hr = as.numeric(duration/3600)) %>% 
  filter(duration_hr <= 24) %>% 
  ggplot(aes(x = duration_hr)) +
  geom_histogram()

         
# Time Series

acc %>% 
  filter(year !=2015) %>% 
<<<<<<< HEAD
  count(date, severity) %>% 
  ggplot() +
  geom_line(aes(x = date, y = n, color = severity))
=======
  count(date, severity, timezone) %>% 
  ggplot() +
  geom_line(aes(x = date, y = n, color = severity)) +
  scale_color_viridis_d() +
  facet_grid(timezone ~ .)

>>>>>>> 576bc7887edfe630365579babe3357859a67ca9e


