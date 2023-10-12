SELECT * from entity
-- According to this wesite I found, these are the longitudinal and latitudinal extents of Africa.
-- https://www.toppr.com/ask/question/what-is-the-longitudinal-extent-of-africa/
-- I checked the values myself on a map, of course.
-- The only problem is, this current design grabs some bits of MENA.
-- Nothing that can't be solved, I'm sure of it.
WHERE latitude > -35 AND latitude < 36
AND longitude > -16 AND longitude < 51
LIMIT 1000