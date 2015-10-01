#!/usr/bin/env python

# Back up the old Docker file
# Read in the Manifest.yml file
# Craft a Dockerfile to build a data volume container
# Print out the correct build command, just in case
#   the user is a novice Dockerist
# Also, print out the index object which should be published
#   via the Agave metadata service

import yaml
import json
import re
import os

f = open('Manifest.yml')
manifest = yaml.load(f)
f.close()

dbindex = dict()
dockerfile = open('Dockerfile', 'w')
# Header bits in Dockerfile
dockerfile.write('FROM ' + manifest['docker_from']['image'] + ':' + manifest['docker_from']['tag'] + '\n')
dockerfile.write('MAINTAINER ' + manifest['docker_this']['maintainer'] + '\n\n')
# Index
dbindex['docker_from'] = dict()
dbindex['docker_this'] = dict()
dbindex['docker_from']['registry'] = manifest['docker_from']['registry']
dbindex['docker_from']['image'] = manifest['docker_from']['image']
dbindex['docker_from']['tag'] = manifest['docker_from']['tag']
dbindex['docker_this']['maintainer'] = manifest['docker_this']['maintainer']
dbindex['docker_this']['registry'] = manifest['docker_this']['registry']
dbindex['docker_this']['image'] = manifest['docker_this']['image']
dbindex['docker_this']['tag'] = manifest['docker_this']['tag']
dbindex['docker_this']['volume'] = manifest['docker_this']['volume']
# Tags

# Iterate through sources
dbindex['docker_this']['databases'] = []
for i in manifest['sources']:
    # if url is file, run this as an COPY command followed by the index
    # otherwise, do it the same way we have been
    match = re.search(r'^(file://)(.*)', i['uri'])
    if match:
        local_path=match.group(2)
        local_fname=os.path.split(local_path)[1]
        print 'Adding ' + local_path + '\n'
        if os.path.isfile(local_path):
            dockerfile.write('COPY ' + local_path + ' /home/\n')
            dockerfile.write('RUN makeblastdb -in ' + local_fname + ' -dbtype ' + i['dbtype'] + ' -title \'' + i['label'] + '\' -out ' + manifest['docker_this']['volume'] + '/' + i['filename'] + ' && rm -rf ' + i['filename'] + '\n')
        else:
            raise NameError('File not found')
    else:
        dockerfile.write('RUN wget --no-verbose -O ' + i['filename'] + ' "' + i['uri'] + '" && makeblastdb -in ' + i['filename'] + ' -dbtype ' + i['dbtype'] + ' -title \'' + i['label'] + '\' -out ' + manifest['docker_this']['volume'] + '/' + i['filename'] + ' && rm -rf ' + i['filename'] + '\n' )

    # Manually create the dbsource dict in case we need to do any
    # manipulation in the future. Theoretically should just
    # be able to yaml->dict->json this
    dbsource = dict()
    dbsource['uri'] = i['uri']
    dbsource['label'] = i['label']
    dbsource['dbtype'] = i['dbtype']
    dbsource['filename'] = i['filename']
    # Now, add it to the list
    dbindex['docker_this']['databases'].append(dbsource)

# These commands need to go at the end
dockerfile.write('\nVOLUME ' + manifest['docker_this']['volume'] + '\n')
dockerfile.write('CMD ["' + manifest['docker_this']['cmd'] + '"]\n')
# dockerfile.write('RUN rm -rf /opt/ncbi-blast*; rm -rf /opt/blast\n')
dockerfile.close()

# We already dealt with these ^ pragmas in the dbindex so nothing needs to be done
# with them. We do need to transform dbindex into an Agave metadata doc
# which setting it as the value in the follow structure
# {'name': 'agave-ncbi-blastdb-index', 'value': dbindex }
# Then, print out the dbindex.json file and provide instructions on how to post it

agave_meta_dbindex = dict()
agave_meta_dbindex['name'] = 'araport.blastdb.index'
agave_meta_dbindex['value'] = dbindex

dbindexfname = 'Dbindex.json'
with open(dbindexfname, 'w') as outfile:
    json.dump(agave_meta_dbindex, outfile, sort_keys=True, indent=4)

print 'Now run the following from this directory:'
print 'docker build --rm=true -t ' + manifest['docker_this']['image'] + ':' + manifest['docker_this']['tag'] + ' .'
print 'docker tag -f ' + manifest['docker_this']['image'] + ':' + manifest['docker_this']['tag'] + ' ' + manifest['docker_this']['image'] + ':latest'
print 'docker push --disable-content-trust=true ' + manifest['docker_this']['image']
print './publishDatabaseIndex.sh Dbindex.json [Token]'
