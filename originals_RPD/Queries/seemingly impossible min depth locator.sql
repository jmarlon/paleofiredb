SELECT ID_SITE, ID_ENTITY, entity_name, latitude, longitude, depositional_context, MIN(avg_depth), MAX(avg_depth) FROM entity
INNER JOIN sample USING(ID_ENTITY)
GROUP BY ID_ENTITY
HAVING MIN(avg_depth) <> -999999
ORDER BY MIN(avg_depth)
-- This query brings up entities that have seemingly impossible depths.