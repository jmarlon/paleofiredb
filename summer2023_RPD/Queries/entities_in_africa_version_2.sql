# This query uses the Country Xwalk table, and the results of the reverse geocoder, to see which entities are in Africa.
# This query was used in my data synthesis to generate all those tables. The sythesis currently lies in Fire/database/Africa Records/data_synthesis

SELECT data_for_map_with_countries.*, country_xwalk.Country, country_xwalk.Region_EPI, country_xwalk.Continent, country_xwalk.`Secondary Continent`, country_xwalk.Island, chronology.original_est_age, sample.charcoal_measurement FROM data_for_map_with_countries
INNER JOIN country_xwalk USING(ISO3)
INNER JOIN sample USING(ID_ENTITY)
INNER JOIN chronology USING(ID_SAMPLE)
WHERE country_xwalk.Continent = 'Africa'
