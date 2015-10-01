# Overview: Araport BLAST data container

This repo contains tooling to build and push a Docker image with a data volume containing an Araport BLAST database reference set, as well as register its contents with the Araport metadata service.

It assumes you have installed and know how to use:

1. Docker 1.7 or higher
2. The Araport CLI
3. Python 2.7.x with the yaml and json modules installed
4. [The jq JSON parser](https://stedolan.github.io/jq/)

## Bootstrapping

Create or edit Manifest.yml. You may specify remote URLs in the sources section by specifying any protocol recognized by wget or local data by using the ```file://``` convention. All local files *MUST* be stored in the data/ directory when the Docker image is built. They will not be included in this repo as data/ is in the ```.gitignore``` file.

```
python createBlastDbDockerfile.py Manifest.yml
```

This creates the Dockerfile to build a data container image. It prints out a set of Docker commands to run to build and push the resulting image. Run the proscribed set of commands - when they have completed successfully, run the database publication script.

```
./publishDatabaseIndex.sh Dbindex.json [$TOKEN]
```

This will publish an index document for the BLAST dabatases to the Agave structured data service. If it already exists, the index document will be updated based on the contents of Manifest.yml. The structured data records have a common name ```araport.blastdb.index``` and are distinguished by the ```value.docker_this.tag```.

The result of this sequence of activities will be:
* a new or updated Docker Hub image at araport/agave-ncbi-blastdb tagged with latest as well as the dataset release name
* a new or updated record in Agave's structured data service ```araport.blastdb.index```

## Updating to release new data

The process is similar to the initial bootstrapping sequence.

0. Decide on the short name of the new data release. For example, *araport99*
1. Create a new branch in this repo. For example, ```git checkout -b araport99``
2. Update Manifest.yml so that the new Docker data image uses the previous one as its base. This is done by setting the ```docker_from.image``` and ```docker_from.tag``` to the values from ```docker_this.image``` and ```docker_this.tag```
3. Update ```docker_this.tag``` in Manifest.yml to the short name
4. Remove all previous data set descriptions from the ```sources``` list
5. Add new data set descriptions and run ```python createBlastDbDockerfile.py Manifest.yml```
6. Run the appropriate Docker build, tag, and push commands
7. Run the database index publishing script
8. Optional: Validate that the Araport BLAST app on the web site sees the new data set

Now, run the scripts as per the Boostrapping section and follow the instructions printed to the screen. As an aside, do NOT tag the newly built data image with 'latest' until you are sure that the database download and creation scripts have run successfully.

