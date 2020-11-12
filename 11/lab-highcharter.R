#https://www.r-exercises.com/2018/04/09/how-to-visualize-data-with-highcharter-exercises/

You are here: Home / Exercises / Exercises (beginner) / How to Visualize Data With Highcharter: Exercises
How to Visualize Data With Highcharter: Exercises
9 April 2018 by Euthymios Kasvikis 1 Comment

FacebookTwitterLinkedInRedditHacker NewsWhatsAppEmailShare
INTRODUCTION

Highcharter is an R wrapper for Highcharts’ JavaScript library and its modules. Highcharts is very mature and flexible on JavaScript’s charting library. It has a great and powerful API.

Before proceeding, please follow our short tutorial.

Look at the examples given and try to understand the logic behind them. Then, try to solve the exercises below using R without looking at the answers. Then check the solutions to check your answers.

Exercise 1

Load the mpg data-set and create a basic scatter plot between variables of your choice.

Exercise 2

Group the scatter plot you just created by class.

Exercise 3

Use highchart() to create a basic column chart of your choice.

Exercise 4

Add a title to the chart of exercise 3.

Exercise 5

Name the bars of your column chart as years and replace “Series 1” with “Sales.”

Learn more about using different visualization packages in the online course R: Complete Data Visualization Solutions. In this course, you will learn how to:
Work extensively with the ggplot package and its functionality
Learn what visualizations exist for your specific use case
And much more
Exercise 6

Load the diamonds data set, create a basic column chart, and color it by cut.

Exercise 7

Create a column chart of the price with the color of your choice.

Exercise 8

Use forecast() on AirPassengers data-set in combination with hchart().

Exercise 9

Create a chloropleth map of the unemployemnt data-set with a colorAxis().

Exercise 10

Change the parameters of the legend with parameters of your choice.




https://www.r-exercises.com/2018/04/09/highcharter-exercises-solutions/
  
####################

#                  #

#    Exercise 1    #

#                  #

####################


library("highcharter")
data(mpg, package = "ggplot2")
hchart(mpg, "scatter", hcaes(x = displ, y = hwy))

data(mpg, package = "ggplot2")
hchart(mpg, "scatter", hcaes(x = displ, y = hwy, group = class))


####################

#                  #

#    Exercise 3    #

#                  #

####################


highchart() %>%
  hc_chart(type = "column") %>%
  hc_add_series(data = c(5000, 6000, 7000, 8000, 9900),
                name = "Downloads")

####################

#                  #

#    Exercise 4    #

#                  #

####################


highchart() %>%
  hc_chart(type = "column") %>%
  hc_title(text = "A highcharter chart") %>%
  hc_add_series(data = c(5000, 6000, 7000, 8000, 9900)
                )

####################

#                  #

#    Exercise 5    #

#                  #

####################


highchart() %>%
  hc_chart(type = "column") %>%
  hc_title(text = "A highcharter chart") %>%
  hc_xAxis(categories = 2012:2016) %>%
  hc_add_series(data = c(5000, 6000, 7000, 8000, 9900),
                name = "Sales")

####################

#                  #

#    Exercise 6    #

#                  #

####################


data(diamonds, package = "ggplot2")
hchart(diamonds$cut, colorByPoint = TRUE, name = "Cut")

####################

#                  #

#    Exercise 7    #

#                  #

####################


hchart(diamonds$price, color = "#B71C1C", name = "Price")

####################

#                  #

#    Exercise 8    #

#                  #

####################


install.packages("forecast")
library("forecast")
airforecast <- forecast(auto.arima(AirPassengers), level = 95)
hchart(airforecast)

####################

#                  #

#    Exercise 9    #

#                  #

####################


data(unemployment)
hcmap("countries/us/us-all-all", data = unemployment,
      name = "Unemployment", value = "value", joinBy = c("hc-key", "code"),
      borderColor = "transparent")%>%
  hc_colorAxis(dataClasses = color_classes(c(seq(0, 10, by = 2), 50)))

####################

#                  #

#    Exercise 10   #

#                  #

####################


data(unemployment)
hcmap("countries/us/us-all-all", data = unemployment,
      name = "Unemployment", value = "value", joinBy = c("hc-key", "code"),
      borderColor = "transparent") %>%
  hc_colorAxis(dataClasses = color_classes(c(seq(0, 10, by = 2), 50))) %>%
  hc_legend(layout = "vertical", align = "right",
            floating = TRUE, valueDecimals = 0, valueSuffix = "%")
  