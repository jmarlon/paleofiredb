SELECT ID_ENTITY, entity_name, publication.* FROM entity
INNER JOIN entity_link_publication USING(ID_ENTITY)
INNER JOIN publication USING(ID_PUB)