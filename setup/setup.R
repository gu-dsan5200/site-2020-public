## Initial infrastructure setup

if(!('pacman' %in% installed.packages()[,'Package'])){
  install.packages('pacman')
}
library(pacman)

## CRAN packages
cran_packages <- c('tidyverse','broom','janitor', 'knitr', 'kableExtra', 'here',
                   'usethis', 'fs','reticulate')
p_load(char=cran_packages)

## Dev packages

gh_packages = c('EvaMaeRey/flipbookr', 'gadenbuie/xaringanExtra')

map(gh_packages, function(x){
  pkgname = str_extract(x, '[:alnum:]+$')
  if(!p_isinstalled(pkgname)){
    p_install_gh(x)
  }
  p_load(pkgname, character.only = T)
})

## Populating with templates

dirs <- str_pad(1:14, width=2, side='left', pad='0')
map(dirs, ~if(!dir_exists(.)){dir_create(.)})

output_ymls <- path(dirs, '_output.yml')
map(output_ymls, ~if(!file_exists(.)) file_copy(here('templates/_output.yml'), .))

# map(str_pad(1:14, width=2, side='left', pad='0'), 
#   ~try(file_copy(here('templates/slide_template.Rmd'), 
#             path(., paste0('slide_',.,'.Rmd')))))
