SELECT entity.*, AVG(original_est_age) from entity
INNER JOIN sample USING(ID_ENTITY)
INNER JOIN chronology USING(ID_SAMPLE)
GROUP BY entity.ID_ENTITY
LIMIT 1000