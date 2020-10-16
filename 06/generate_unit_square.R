generate_unit_square <- function(n,
                                 xdist = "runif",
                                 ydist = "runif",
                                 min = -1,
                                 max = 1,
                                 seed = as.numeric(Sys.Date()),
                                 mean = NULL,
                                 sd = NULL) {
  x <- if (xdist == "runif")
    runif(n, min, max)
  else
    rnorm(n, mean, sd)
  
  y <- if (ydist == "runif")
    runif(n, min, max)
  else
    rnorm(n, mean, sd)
  
  df <- tibble(x = x, y = y) %>%
    mutate(dist = sqrt((x ^ 2) + (y ^ 2))) %>%
    mutate(
      quadrant = ifelse(x >= 0,
                        ifelse(y >= 0, "I", "IV"),
                        ifelse(y >= 0, "II", "III")),
      angle = atan(y / x) / (pi / 180),
      angle = case_when(
        quadrant == "I" ~ angle,
        quadrant == "II" ~ 180 + angle,
        quadrant == "III" ~ 180 + angle,
        quadrant == "IV" ~ 360 + angle
      )
    )
  
  df
  
}


generate_unit_square(10000, seed = 20201001) %>% 
  write_csv("06/data/unit_square_10k.csv")

generate_unit_square(50000, 
                       xdist = "rnorm",
                       ydist = "runif",
                       mean = 0, 
                       sd = 1, 
                       seed = 20201001) %>% 
    write_csv("06/data/unit_square_50k.csv")

  



