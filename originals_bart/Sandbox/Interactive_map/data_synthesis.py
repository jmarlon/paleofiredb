import matplotlib.pyplot as plt
import pandas as pd

# You'll need to change the filepath to be right for you. Use the "entities_in_africa version [x].sql" query to grab the file.
df = pd.read_csv("/Users/ellison/sql-for-the-internshuip/entities_in_africa.csv")

entities = df['ID_ENTITY'].unique() # This gets all the entity IDs
new_entities = []
for i in range(len(entities)):
    new_entities.append('entity_' + str(entities[i]))

# Programatically defines the variables
_g = globals()
for id in new_entities:
    _g[id] = df[df['ID_ENTITY'] == entities[new_entities.index(id)]]
    

# This loop makes the graphs. It draws one, saves it, and clears the figure so the next graph can be drawn on it.
for entity_name in new_entities:
    entity = _g[entity_name]
    plt.title(entity_name)
    plt.scatter(entity['original_est_age'], entity['charcoal_measurement'])
    plt.xlabel('Age')
    plt.ylabel('Charcoal Measurement')
    # You'll have to change the filepath here, obviously, but this should save them all to a folder.
    plt.savefig('/Users/ellison/Desktop/data_synthesis/' + entity_name + '.png', dpi=300, bbox_inches='tight')
    plt.clf()

print('Successfully generated graphs! Check your filepath for the generated graphs.')

