FROM araport/agave-ncbi-blastdb:tair10
MAINTAINER vaughn@tacc.utexas.edu

COPY data/araport11/Araport11_genes.20151006.cds.fasta /home/
RUN makeblastdb -in Araport11_genes.20151006.cds.fasta -dbtype nucl -title 'Araport11 Coding sequences' -out Araport11_genes.20151006.cds.fasta
RUN mv Araport11_genes.20151006.cds.fasta.* /opt/databases
COPY data/araport11/Araport11_genes.20151006.pep.fasta /home/
RUN makeblastdb -in Araport11_genes.20151006.pep.fasta -dbtype prot -title 'Araport11 Protein sequences' -out Araport11_genes.20151006.pep.fasta
RUN mv Araport11_genes.20151006.pep.fasta.* /opt/databases

#VOLUME /opt/databases
CMD ["true"]
