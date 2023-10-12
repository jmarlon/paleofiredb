import plotly.graph_objects as go
import pandas as pd

# You'll need to change the filepath to be right for you. Use the "get data for map.sql" query to grab the file.
df = pd.read_csv("/Users/ellison/sql-for-the-internshuip/data_for_map.csv")

df['site_id_as_str'] = df['ID_SITE'].astype(str)
df['entity_id_as_str'] = df['ID_ENTITY'].astype(str)
df['samples_as_str'] = df['#_of_samples'].astype(str)
df['max_depth_as_str'] = df['max_depth'].astype(str)
df['min_depth_as_str'] = df['min_depth'].astype(str)
df['site_title'] = 'Site Name: ' + df['entity_name'] + '<br>Site ID: ' + df['site_id_as_str'] + '<br>Entity ID: ' + df['entity_id_as_str'] + '<br>Minimum Depth: ' + df['min_depth_as_str'] + '<br>Maximum Depth: ' + df['max_depth_as_str'] + '<br># of Samples: ' + df['samples_as_str']

fig = go.Figure(data=go.Scattergeo(
        lon = df['longitude'],
        lat = df['latitude'],
        text = df['site_title'],
        mode = 'markers',
        marker_color = 0,
        ))
fig.update_layout(
        title = 'Interactive Map of all the cores!<br>Not all the data is present yet, but it should serve as a base for it all.',
        geo_scope='world',
    )
fig.show()
