FROM araport/agave-ncbi-blast:2.2.30
MAINTAINER Matthew Vaughn <vaughn@tacc.utexas.edu>
#VOLUME /opt/databases

RUN wget "ftp://ftp.arabidopsis.org/home/tair/Genes/TAIR10_genome_release/TAIR10_blastsets/TAIR10_pep_20101214_updated" && makeblastdb -in TAIR10_pep_20101214_updated -dbtype prot -title 'TAIR10 Protein sequences (CDS translation)' -out /opt/databases/TAIR10_pep_20101214_updated && rm TAIR10_pep_20101214_updated

RUN wget "ftp://ftp.arabidopsis.org/home/tair/Genes/TAIR10_genome_release/TAIR10_transposable_elements/TAIR10_TE.fas" && makeblastdb -in TAIR10_TE.fas -dbtype nucl -title 'TAIR10 Transposable Elements' -out /opt/databases/TAIR10_TE

RUN wget "ftp://ftp.arabidopsis.org/home/tair/Genes/TAIR10_genome_release/TAIR10_blastsets/TAIR10_seq_20101214_updated" && makeblastdb -in TAIR10_seq_20101214_updated -dbtype nucl -title 'TAIR10 Gene sequences (defined as UTRs + CDSs + introns)' -out /opt/databases/TAIR10_seq_20101214_updated && rm TAIR10_seq_20101214_updated

VOLUME /opt/databases

CMD ["true"]

