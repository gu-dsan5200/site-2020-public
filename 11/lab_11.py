import pandas as pd
import numpy as np
import plotly.express as px

dir(px.data)

gap = px.data.gapminder()
fig = px.scatter(gap, x = 'gdpPercap', y = 'lifeExp', color = 'country')
fig.show()

fig = px.scatter(gap, x = 'year', y = 'lifeExp', color = 'continent')
fig.show()

fig = px.scatter(gap, x = 'gdpPercap', y = 'lifeExp', color = 'continent',
        marginal_y = 'violin', marginal_x = 'box', trendline = 'ols', template='simple_white')
fig.show()


tips = px.data.tips()
tips.head()

fig = px.bar(tips, x = 'sex', y = 'total_bill', color='smoker', barmode='group')
fig.show()

fig = px.bar(tips, x="sex", y="total_bill", color="smoker", barmode="group", facet_row="time", facet_col="day",
               category_orders={"day": ["Thur", "Fri", "Sat", "Sun"], "time": ["Lunch", "Dinner"]})
fig.show()

iris = px.data.iris()
fig = px.scatter_matrix(iris, dimensions = ['sepal_width','sepal_length','petal_width','petal_length'], color='species')
fig.show()


fig = px.parallel_coordinates(iris, color='species_id', labels={"species_id": "Species", 
    "sepal_width": "Sepal Width", "sepal_length":"Sepal Length", "petal_width": "Petal Width",
    "petal_length": "Petal Length",}, color_continuous_scale = px.colors.diverging.Tealrose, color_continuous_midpoint=2)
fig.show()

fig = px.scatter(gap.query('year==2007'), x='gdpPercap', y = 'lifeExp', size = 'pop', color='continent', hover_name='country', 
        log_x=True, size_max=60)
fig.show()
