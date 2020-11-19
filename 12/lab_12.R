## ----setup, include=FALSE, message=FALSE, warning=FALSE----------------------------------------
library(pacman)
p_load(char = c(
  "tidyverse", "knitr", "htmlwidgets", "kableExtra",
  "here", "reticulate"
))

# reticulate::use_condaenv('ds', required=TRUE)






## Correlogram, 3 ways
##
library(ggcorrplot)
library(mlbench)
data("PimaIndiansDiabetes2")
d <- PimaIndiansDiabetes2 %>%
  select(glucose:triceps, mass:age)
cormat <- cor(d, use = "pair") # Why use="pair"

## Play with type = c('full', 'upper','lower')
ggcorrplot(cormat, method = "circle") # other methods are "square"

## Method 2
## Input can be tidy data or correlation matrix
library(corrgram)
corrgram(d,
  order = TRUE,
  lower.panel = panel.shade,
  upper.panel = panel.ellipse,
  text.panel = panel.txt
)


## Method 3
library(ellipse)
library(RColorBrewer)
my_colors <- brewer.pal(5, "Spectral") # Can play around with these
my_colors <- colorRampPalette(my_colors)(100)

### Needs more munging
ord <- order(cormat[1, ]) # What does `order` do?
d_ord <- cormat[ord, ord]
plotcorr(d_ord, mar = c(1, 1, 1, 1), col = my_colors[d_ord * 50 + 50])


# hclust and dendrograms --------------------------------------------------

iris %>%
  janitor::clean_names() %>%
  select(-species) %>%
  dist() %>%
  hclust(method = "complete") -> iris_cl # can play around with 'single', 'average', median', 'centroid'

as.dendrogram(iris_cl) -> dend
plot(dend)

clusters <- cutree(iris_cl, k = 3) # 3 clusters
iris1 <- iris %>% mutate(cluster_id = as.factor(clusters)) %>% 
  janitor::clean_names()
ggplot(iris1, aes(x = sepal_length, y = sepal_width))+
  geom_point(size=2, aes(color = cluster_id))+
  labs(x = 'Sepal length', y = 'Sepal width',
       color = 'Clusters',
       title = paste(stringr::str_to_title(iris_cl$method),'linkage'))+
  theme_classic()

## Better rendering of dendrogram
library(dendextend)
dend %>%
  set("branches_col", "grey") %>%
  set("branches_lwd", 3) %>%
  set("labels_col", "orange") %>%
  set("labels_cex", 0.8) %>%
  plot()


## This is not working properly
dend %>%
  set("labels_col", value = c("skyblue", "orange", "grey"), k=3) %>%
  set("branches_k_color", value = c("skyblue", "orange", "grey"), k=3) %>% 
  plot(axes = FALSE)
rect.dendrogram(dend, k = 3, lty = 5, lwd = 0, x = 1, col = rgb(0.1, 0.2, 0.4, 0.1))





# Heatmap -----------------------------------------------------------------

data <- as.matrix(mtcars)
library(RColorBrewer)
heatmap(data, scale = "column", cexRow = 1, col = colorRampPalette(brewer.pal(8, "Blues"))(25))

# There are several ways of doing heatmaps in R:
#   
#   https://jokergoo.github.io/ComplexHeatmap-reference/book/
#   http://sebastianraschka.com/Articles/heatmaps_in_r.html
# https://plot.ly/r/heatmaps/
#   http://moderndata.plot.ly/interactive-heat-maps-for-r/
#   http://www.siliconcreek.net/r/simple-heatmap-in-r-with-ggplot2
# https://rud.is/b/2016/02/14/making-faceted-heatmaps-with-ggplot2/
#   
# Many other packages including ComplexHeatmap, Heatplus (both from)


# PCA ---------------------------------------------------------------------

iris <- iris %>% janitor::clean_names()
iris <- iris[!duplicated(iris), ]
df <- iris %>%
  select(-species) %>%
  t()
pr <- prcomp(df) #PCA
d <- as.data.frame(pr$rotation) %>% mutate(species = iris$species)
ggplot(d, aes(PC1, PC2, color = species)) +
  geom_point(size = 5)



# tSNE --------------------------------------------------------------------

set.seed(3457) # need seed since tSNE is probabilistic

d <- as.data.frame(Rtsne::Rtsne(t(df), perplex = 3)$Y) %>%
  mutate(species = iris$species)
ggplot(d, aes(V1, V2, color = species)) +
  geom_point(size = 5)



# UMAP --------------------------------------------------------------------

bl <- umap::umap(t(df))
out <- as.data.frame(bl$layout) %>% mutate(species = iris$species)
ggplot(out, aes(x = V1, y = V2, color = species)) +
  geom_point()




# Voronoi -----------------------------------------------------------------

## This part uses base R plotting

airports <- read.csv("data/airport-locations.tsv", sep = "\t", stringsAsFactors = FALSE)
source("latlong2state.R")
airports$state <- latlong2state(airports[, c("longitude", "latitude")])
airports_contig <- na.omit(airports)
# Projection
library(mapproj)
airports_projected <- mapproject(airports_contig$longitude, airports_contig$latitude, "albers", param = c(39, 45))
par(mar = c(0, 0, 0, 0))
plot(airports_projected, asp = 1, type = "n", bty = "n", xlab = "", ylab = "", axes = FALSE)
points(airports_projected, pch = 20, cex = 0.1, col = "red")


library(deldir)
par(mar = c(0, 0, 0, 0))
plot(airports_projected, asp = 1, type = "n", bty = "n", xlab = "", ylab = "", axes = FALSE)
points(airports_projected, pch = 20, cex = 0.1, col = "red")
vtess <- deldir(airports_projected$x, airports_projected$y)
plot(vtess, wlines = "tess", wpoints = "none", number = FALSE, add = TRUE, lty = 1)




# Regression description --------------------------------------------------

diamonds <- diamonds %>%
  mutate(across(c(cut, color, clarity), ~ factor(., ordered = F)))
model <- lm(log(price) ~ log(carat) + cut + color + clarity + depth,
  data = diamonds
)

## ---- echo=FALSE-------------------------------------------------------------------------------
library(gtsummary)
theme_gtsummary_compact()
gtsummary::tbl_regression(model) %>% as_gt()


## Use broom to make relevant tibbles. Discuss
## 
mod_tidy <- broom::tidy(model)
mod_aug <- broom::augment(model)


## Theme
library(extrafont) # What does this do?
theme_set(theme_classic() +
  theme(
    axis.title = element_text(size = 18, family = "Avenir"),
    axis.text = element_text(size = 16, family = "Avenir"),
    title = element_text(size = 24, family = "Avenir"),
    plot.margin = unit(c(0.05, 0.05, 0.05, 0.05), "npc")
  ))



library(coefplot)
coefplot::coefplot.lm(model) +
  labs(x='Coefficient', y = 'Predictor')


ggplot(mod_tidy %>% filter(term != '(Intercept)'),
       aes(x = term, y = estimate,
           ymin = estimate - 2*std.error,
           ymax = estimate + 2*std.error))+
  geom_pointrange(color='blue')+
  labs(x = 'Predictor', y = 'Coefficient',
       title='Coefficient Plot')+
  geom_hline(yintercept=0, linetype=2)+
  coord_flip()

set.seed(2405)
diamonds2 <- slice_sample(diamonds, prop=0.01) #<<

model2 <- lm(log(price) ~ log(carat) + cut + color + clarity + depth,
            data=diamonds2)

model2_tidy <- broom::tidy(model2)

ggplot(model2_tidy %>% filter(term!= '(Intercept)'),
       aes(x =term, y = estimate,
           ymin = estimate - 2*std.error,
           ymax = estimate + 2*std.error))+
  geom_pointrange(color='blue')+
  labs(x = 'Predictor', y = 'Coefficient',
       title = 'Coefficient Plot')+
  geom_hline(yintercept = 0, linetype=2)+
  coord_flip()

# ggeffects ---------------------------------------------------------------

library(ggeffects)
pr <- ggpredict(model, 'carat', condition = c(color = 'F'))
ggplot(as.data.frame(pr),
       aes(x = x, y = predicted))+
  geom_line()+
  geom_ribbon(aes(ymin = conf.low,
                  ymax = conf.high))+
  scale_y_continuous('Predicted price',
                     labels = scales::label_dollar())+
  labs(x='Carat')



pr <- ggpredict(model, 'cut')
ggplot(as.data.frame(pr),
       aes(x = x, y = predicted,
           ymin=conf.low,ymax=conf.high))+
  geom_point()+
  geom_errorbar(width=.2)+
  scale_y_continuous('Predicted price',
                     labels = scales::label_dollar())+
  labs(x='Cut')


pr <- ggpredict(model, c('carat','color'))
ggplot(as.data.frame(pr),
       aes(x=x, y =predicted,
           ymin=conf.low, ymax=conf.high))+
  geom_line(aes(color = group))+
  scale_x_continuous('Carat')+
  scale_y_continuous('Predicted price',
                     labels = scales::label_dollar())+
  scale_color_viridis_d('Color')



# Regression diagnostics --------------------------------------------------

## Residual plot

ggplot(mod_aug,
       aes(x=.fitted, y = .std.resid))+
  geom_point()+
  geom_hline(yintercept=0,
             linetype=2,
             color='blue')+
  geom_smooth(color='red')+
  labs(x='Predicted values',
       y = 'Standardized residuals')


## Q-Q plot

ggplot(mod_aug, aes(sample = .std.resid)) +
  stat_qq() +
  geom_abline(linetype = 2) +
  labs(title = "Residual Q-Q plot", y = "Standardized residuals")


## Cook's distance

ggplot(mod_aug, aes(x = seq_along(.cooksd), .cooksd)) +
  geom_col(fill = "red") +
  labs(x = "Obs number", y = "Cook's distance")


## Leverage

ggplot(mod_aug, aes(.hat, .std.resid)) +
  geom_point(aes(size = .cooksd)) +
  geom_smooth(se = F) +
  labs(x = "Leverage", y = "Residuals", size = "Cook's D")

## Predicted vs actual

ggplot(mod_aug, aes(x = `log(price)`, y = .fitted)) +
  geom_point(alpha = 0.2) +
  geom_abline(color = "blue", linetype = 2) +
  geom_smooth(color = "red") +
  labs(y = "Predicted log(price)")



# Some ML -----------------------------------------------------------------


## Decision trees

library(partykit)
library(mlbench)
data("BreastCancer")
BreastCancer %>%
  select(-Id) %>%
  rpart(Class ~ ., data = .) %>%
  partykit::as.party() -> bl
plot(bl)



## Lasso regression

library(mlbench)
library(glmnet)
data("BreastCancer")
X <- BreastCancer %>%
  filter(complete.cases(.)) %>%
  select(-Id, -Class) %>%
  mutate(across(everything(), ~ as.numeric(as.character(.)))) %>%
  as.matrix()
y <- BreastCancer %>%
  filter(complete.cases(.)) %>%
  pull(Class) %>%
  as.numeric()
fit <- glmnet(X, y, family = "binomial")
plot(fit, "lambda", main = "Lasso regression", label = T)



## Elastic net

library(mlbench)
data("BreastCancer")
X <- BreastCancer %>%
  filter(complete.cases(.)) %>%
  select(-Id, -Class) %>%
  mutate(across(everything(), ~ as.numeric(as.character(.)))) %>%
  as.matrix()
y <- BreastCancer %>%
  filter(complete.cases(.)) %>%
  pull(Class) %>%
  as.numeric()
fit <- glmnet(X, y, family = "binomial", alpha = 0.5)
plot(fit, "lambda", main = "ELR (alpha=0.5)", label = T)


## Diagnositc curves in R

# install.packages('tidymodels')
library(yardstick)
library(tidymodels)


data("two_class_example")

## ROC curve

roc_curve(two_class_example, truth, Class1)
autoplot(roc_curve(two_class_example, truth, Class1))

roc_curve(two_class_example, truth, Class1) %>%
  ggplot(aes(x = 1 - specificity, y = sensitivity)) +
  geom_path() +
  geom_abline(lty = 3) +
  coord_equal() +
  theme_bw()

## Precision-recall curve

pr_curve(two_class_example, truth, Class1)
autoplot(pr_curve(two_class_example, truth, Class1))

pr_curve(two_class_example, truth, Class1) %>% 
  ggplot(aes(x = recall, y = precision)) +
  geom_path() +
  coord_equal() +
  theme_bw()



# Survival analysis -------------------------------------------------------


library(survival)
pbc$status2 <- factor(ifelse(pbc$status == 2, "Dead", "Alive"))
pbc <- pbc %>%
  mutate(id = factor(id)) %>%
  mutate(id = fct_reorder(id, time))
ggplot(pbc, aes(x = time, y = id)) +
  geom_point(aes(color = factor(status2)), size = 2) +
  geom_segment(aes(x = time, xend = 0, y = id, yend = id, color = factor(status2))) +
  scale_color_manual(values = c("white", "red")) +
  labs(x = "Time (days)", title = "PBC study", color = "Status") +
  theme(
    axis.text.y = element_blank(),
    axis.title.y = element_blank()
  )


## ---- echo=F, fig.height=5---------------------------------------------------------------------
fit <- survfit(Surv(time, status == 2) ~ trt, data = pbc)
survminer::ggsurvplot(
  fit,
  data = pbc,
  pval = T,
  risk.table = T
)
