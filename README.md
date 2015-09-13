# Overview: Araport BLAST data container

This repo contains tooling to build and push a Docker image with a data volume containing an Araport BLAST database reference set, as well as register its contents with the Araport metadata service.

It assumes you have installed and know how to use:

1. Docker 1.7 or higher
2. The Araport CLI
3. Python 2.7.x with the yaml and json modules installed
4. [The jq JSON parser](https://stedolan.github.io/jq/)

## Bootstrapping

```
python createBlastDbDockerfile.py Manifest.yml
```

This creates a Dockerfile for the data image. It also prints out a set of Docker commands to run to build and push the resulting image. Run this set of Docker commands. When they have completed successfully, run the database publication script.

```
./publishDatabaseIndex.sh Dbindex.json [$TOKEN]
```

This will publish an index document for the BLAST dabatases to the Agave metadata service. If it already exists, the index document will be updated based on the contents of Manifest.yml. You must have read/write access to the Agave metadata object named 'araport.agave-ncbi-blastdb.index' to perform this action.

## Updating to release new data

1. Update the Manifest.yml so that the new Docker data volume uses the previous one as its base.
2. Create a new name for the data release AKA 'mynewdata'
3. Update the Manifest.yml to build and tag the new release
4. Update the sources section to *ADD* new data sets
4. Run the appropriate Docker build, tag, and push commands
5. Run the database index publishing script
6. Optional: Validate that the Araport BLAST app on the web site sees the new data set

Here's an example. Say we want to add Medicago CDS and proteins to the BLAST service. The FASTA files are publicly accessible here:
* ftp://ftp.jcvi.org/pub/data/m_truncatula/Mt4.0/Annotation/Mt4.0v1/Mt4.0v1_GenesCDSSeq_20130731_1800.fasta
* ftp://ftp.jcvi.org/pub/data/m_truncatula/Mt4.0/Annotation/Mt4.0v1/Mt4.0v1_GenesProteinSeq_20130731_1800.fasta

### Update the Manifest.yml from and this sections

```yaml
docker_from:
    image: araport/agave-ncbi-blastdb # point to most recent build @Dockerhub
    tag: latest
docker_this:
    image: araport/agave-ncbi-blastdb
    tag: mt401genes
    latest: true
    volume: /opt/databases # This must exist in the source image. Env variable BLASTDB must point to it
    cmd: "true"
    maintainer: "vaughn@tacc.utexas.edu"
```

### Update the Manifest.yml sources, maing sure to remove the previous ones

```yaml
sources:
    - uri : ftp://ftp.jcvi.org/pub/data/m_truncatula/Mt4.0/Annotation/Mt4.0v1/Mt4.0v1_GenesCDSSeq_20130731_1800.fasta
      filename: Mt4.0v1_GenesCDSSeq_20130731_1800.fasta
      label: "M. truncatula 4.0v1 Gene CDS"
      dbtype: nucl
    - uri: ftp://ftp.jcvi.org/pub/data/m_truncatula/Mt4.0/Annotation/Mt4.0v1/Mt4.0v1_GenesProteinSeq_20130731_1800.fasta
      filename: Mt4.0v1_GenesProteinSeq_20130731_1800.fasta
      label "M. truncatula 4.0v1 Protein sequence"
      dbtype: prot
```

Now, run the scripts as per the Boostrapping section and follow the instructions printed to the screen. As an aside, do NOT tag the build Docker image with 'latest' until you are sure that the database download and creation scripts have run successfully.

