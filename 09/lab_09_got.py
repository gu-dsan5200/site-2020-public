import pandas as pd
import matplotlib.pyplot as plt
import networkx as nx

got_characters = pd.read_csv('09/data/union_characters_got.csv')
got_relations = pd.read_csv('09/data/union_edges_got.csv')

nodelist = []
for i, row in got_characters.iterrows():
  nodelist.append((row['name'], {'shape': row['shape'], 'popularity': row['popularity'],
    'house': row['house']}))


G = nx.from_pandas_edgelist(got_relations, 
  source='source', target='target', edge_attr=['color','lty'])
# G.add_nodes_from(got_characters.name)
G.add_nodes_from(nodelist)

nx.draw(G, node_size=20)
plt.show()

edge_solid = [(u,v) for (u, v, d) in G.edges(data=True) if d['lty']=='solid']
edge_dotted = [(u,v) for (u,v,d) in G.edges(data=True) if d['lty']=='dotted']

nodes_square = [ u for (u,v) in G.nodes(data=True) if v['shape']=='square']
nodes_square_sizes = [v['popularity']*100 for (u,v) in G.nodes(data=True) if v['shape']=='square']
nodes_circle = [u for (u,v) in G.nodes(data=True) if v['shape']=='circle']
nodes_circle_sizes = [v['popularity']*100 for (u,v) in G.nodes(data=True) if v['shape']=='circle']


pos = nx.spring_layout(G)
nx.draw_networkx_nodes(G, pos, 
  nodelist=nodes_square, node_shape='s', node_size=30)
nx.draw_networkx_nodes(G, pos, 
  nodelist=nodes_circle, node_shape='o', node_size=30)

# nx.draw_networkx_nodes(G, pos)
nx.draw_networkx_edges(G, pos, edgelist=edge_solid, style='solid',
  edge_color = [d['color'] for (u,v,d) in G.edges(data=True)])
nx.draw_networkx_edges(G, pos, edgelist=edge_dotted, style='dotted',
  edge_color = [d['color'] for (u,v,d) in G.edges(data=True)])
nx.draw_networkx_labels(G, pos, font_size=6)

