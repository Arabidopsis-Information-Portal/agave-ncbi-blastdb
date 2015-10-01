FROM araport/agave-ncbi-blastdb:tair10
MAINTAINER vaughn@tacc.utexas.edu

COPY data/araport11/Araport11_genes.20150701.cds.fasta /home/
RUN makeblastdb -in Araport11_genes.20150701.cds.fasta -dbtype nucl -title 'Araport11 Coding sequences' -out /opt/databases/Araport11_genes.20150701.cds.fasta && rm -rf Araport11_genes.20150701.cds.fasta
COPY data/araport11/Araport11_genes.20150701.pep.fasta /home/
RUN makeblastdb -in Araport11_genes.20150701.pep.fasta -dbtype prot -title 'Araport11 Protein sequences' -out /opt/databases/Araport11_genes.20150701.pep.fasta && rm -rf Araport11_genes.20150701.pep.fasta

VOLUME /opt/databases
CMD ["true"]
