import reverse_geocoder as rg
import pandas as pd
import re

# making a lambda function for the reverse geocoder to apply to all coordinate pairs in table
reverse_geocode = lambda s: rg.search(s)
get_country_code = lambda d: d[0]['cc']
get_name = lambda d: d[0]['name']
get_admin1 = lambda d: d[0]['admin1']
df = pd.read_csv("/Users/ellison/sql-for-the-internshuip/data_for_map.csv")  # this filepath will need to be changed if you try to run this.

# yep i have to make this new column. don't worry i don't export it.
df['lat_long_pair'] = list(zip(df['latitude'], df['longitude']))
df['geocode_results'] = df['lat_long_pair'].apply(reverse_geocode)  # this part takes forever.
df['ISO-3166-1 alpha-2 code'] = df['lat_long_pair'].apply(get_country_code)
df['location_name'] = df['lat_long_pair'].apply(get_name)
df['admin1'] = df['lat_long_pair'].apply(get_admin1)

print(df.head())


# THANK YOU TO THIS GUY ON GITHUB 
# https://gist.github.com/tadast/8827699
code_conversion = pd.read_csv("/Users/ellison/sql-for-the-internshuip/countries_codes_and_coordinates.csv")

quotestrip = lambda x: re.sub('"', '', x).strip()

code_conversion['Alpha-2 code'] = code_conversion['Alpha-2 code'].apply(quotestrip)
code_conversion['Alpha-3 code'] = code_conversion['Alpha-3 code'].apply(quotestrip)

df_converted = df.merge(code_conversion, how='left', left_on='ISO-3166-1 alpha-2 code', right_on='Alpha-2 code')
print(df_converted.head())

df_converted.to_csv('data_for_map_with_countries.csv', columns=('ID_ENTITY', 'ID_SITE', 'depositional_context', 'entity_name', 'latitude', 'longitude', 'min_age', 'max_age', 'min_depth', 'max_depth', '#_of_samples', 'Alpha-2 code', 'Alpha-3 code'), index_label='delete this column afterwards!')



