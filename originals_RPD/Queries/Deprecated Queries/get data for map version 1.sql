-- Gets the  Entity_id, Site_id, Site name, Lat, Lon, Max age, Min age, Number of samples
-- Outputs to table and saves as csv, for use in the map plot

SELECT ID_ENTITY, ID_SITE, entity_name, latitude, longitude, MIN(avg_depth) AS 'min_depth', MAX(avg_depth) AS 'max_depth', COUNT(ID_SAMPLE) AS '#_of_samples' FROM entity
INNER JOIN sample USING(ID_ENTITY)
GROUP BY ID_ENTITY
