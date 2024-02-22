import pandas as pd
import geopandas as gpd

world_map = gpd.read_file("countries.geojson")
country_data = pd.read_csv("states_edited.csv")

joined_country_data = world_map.merge(country_data, on="ISO_A3")
joined_country_data.to_file("country_data_edited.geojson", driver="GeoJSON")
