UPDATE entity
SET measurement_method = REPLACE(measurement_method, -777777, -999999)
WHERE ID_ENTITY <> 0;
UPDATE entity
SET core_location = REPLACE(core_location, -777777, -999999)
WHERE ID_ENTITY <> 0;
UPDATE entity
SET depositional_context = REPLACE(depositional_context, -777777, -999999)
WHERE ID_ENTITY <> 0;
UPDATE entity
SET core_location = REPLACE(core_location, -888888, -999999)
WHERE ID_ENTITY <> 0;
UPDATE entity
SET elevation = REPLACE(elevation, -888888, -999999)
WHERE ID_ENTITY <> 0;

SELECT * FROM entity
WHERE measurement_method <> -999999
AND core_location <> -999999
AND elevation <> -999999
AND depositional_context <> -999999
LIMIT 5000