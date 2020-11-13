# dygraph examples

library(dygraphs)

value <- sample(100:800, 100, replace = T)
time <- seq(from = Sys.time(),
            to = Sys.time() + 60 * 60 * 24 * 99,
            by = "day")
df <- data.frame(time = time, value = value)
df

# Data should be converted to extensible time-series type.
# The data frame can not be used directly with dygraph function.

dygraph(df)

# Error in dygraph(df) : Unsupported type passed to argument 'data'.
# Thus, we need to convert our data frame into xts type object. 
# A zoo and xts libraries help us to convert data frame. 
# You may need to install them if they are not available in your machine.

library(zoo)
library(xts)

# Convert df_data to xts type as below.
dy_data <- df %>% read.zoo() %>% as.xts()

# Now, we can plot dy_data with dygraph function.

dygraph(dy_data)

# Add some options to the dygraph
dygraph(dy_data) %>%
  dyOptions(
    colors = "red",
    pointSize = 2,
    drawGrid = T,
    stepPlot = T
  ) %>%
  dyRangeSelector()


## Using quantmod and dygraph for plotting different financial time-series

library(quantmod)

# getSymbols(): to get data
getSymbols("AAPL")
head(AAPL, n = 3)

price <- OHLC(AAPL) # Open Hi Lo Close for ticker
head(price, n = 3)

getSymbols("SPY")

dygraph(OHLC(AAPL))

graph <- dygraph(Cl(SPY), main = "SPY")

dyShading(graph,
          from = "2007-08-09",
          to = "2011-05-11",
          color = "#FFE6E6")

graph <- dygraph(OHLC(AAPL), main = "AAPL")
graph <- dyEvent(graph, "2007-6-29",
                 "iphone", labelLoc = "bottom")
graph <- dyEvent(graph, "2010-5-6",
                 "Flash Crash", labelLoc = "bottom")
graph <- dyEvent(graph, "2014-6-6",
                 "Split", labelLoc = "bottom")
dyEvent(graph, "2011-10-5",
        "Jobs", labelLoc = "bottom")
