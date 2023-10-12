import plotly.graph_objects as go
import pandas as pd

menu_num = None
filter_name = None
filter_min_age = None
filter_max_age = None
filter_country = None
print("Welcome to the interactive map, version 4!")
# Probably the meatiest part of the interactive map, the filter configuration section.
# Which you can skip, if you like.
# I tried to idiot-proof this as much as possible.
while menu_num != 0:
    while type(menu_num) != type(0):
        menu_num = input("Input one of the following numbers:\n0: Display Map   1: Search Site Name   2: Filter By Minimum Age   3: Filter By Maximum Age\n4: Filter By Country Code\n> ")
        try:
            menu_num = int(menu_num) 
        except:
            print('This is not a number!')
    if menu_num == 1:
        filter_name = input("Input the name of the site you want to look at:\n> ")
        menu_num = None
    if menu_num == 2:
        while type(filter_age) != type(0):
            filter_min_age = input("Input a lower bound for age:\n> ")
            try:
                filter_min_age = int(filter_min_age)
            except:
                print('This is not a number!')
        menu_num = None
    if menu_num == 3:
        while type(filter_max_age) != type(0):
            filter_max_age = input("Input a lower bound for age:\n> ")
            try:
                filter_max_age = int(filter_max_age)
            except:
                print('This is not a number!')
        menu_num = None
    if menu_num == 4:
        filter_country = input("Input the three-letter country code of the country you want to look at:\n> ")
        menu_num = None
        
# This just tells you what your filter configurations are before displaying the map.
# print('\n---\n\nSpecified Name: ' + filter_name + '\nMinimum Age: ' + str(filter_age))

# You'll need to change the filepath to be right for you. Use the "get data for map version [x].sql" query to grab the file.
# This version of the interactive map uses version 2 to generate the output, so look for that.
df = pd.read_csv("/Users/ellison/sql-for-the-internshuip/data_for_map_with_countries.csv")

# These trim down the dataframe in accordance to the filters, should they exist.
if filter_name != None:
    df = df[df["entity_name"]==filter_name]
if filter_min_age != None:
    df = df[df["min_age"]>=filter_min_age]
if filter_max_age != None:
    df = df[df["max_age"]>=filter_max_age]
if filter_country != None:
    df = df[df["ISO3"]==filter_country]
    
# after entity id, add the admin1.
# after depositional context, add in the following order: TYPE, source, doi url
    
df['site_title'] = 'Site Name: ' + df['entity_name'] + \
                   '<br>Site ID: ' + df['ID_SITE'].astype(str) + \
                   '<br>Entity ID: ' + df['ID_ENTITY'].astype(str) + \
                   '<br>Country: ' + df['ISO3'] + \
                   '<br>Age Range: ' + df['min_age'].astype(str) + ' - ' + df['max_age'].astype(str) + \
                   '<br>Depth Range: ' + df['min_depth'].astype(str) + ' - ' + df['max_depth'].astype(str) + \
                   '<br>Depositional Context: ' + df['depositional_context'] + \
                   '<br># of Samples: ' + df['#_of_samples'].astype(str)

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