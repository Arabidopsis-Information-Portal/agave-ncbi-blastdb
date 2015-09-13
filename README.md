# Overview: Araport BLAST data container

This repo contains tooling to build and push a Docker image with a data volume containing an Araport BLAST database reference set, as well as register its contents with the Araport metadata service.

It assumes you have installed and know how to use:

1. Docker 1.7 or higher
2. The Araport CLI
3. Python 2.7.x with the yaml module installed

```
python createBlastDbDockerfile.py Manifest.yml
```

This creates a Dockerfile for the data image. It also prints out a set of Docker commands to run to build and push the resulting image. Run this set of Docker commands then the publish script

```
./publishDatabaseIndex.sh Dbindex.json $TOKEN
```

This will create an index document for the BLAST dabatases in the Agave metadata service. If it already exists, the index document will be updated based on the contents of Manifest.yml. You must have read/write access to the Agave metadata object named '' to perform this action.

