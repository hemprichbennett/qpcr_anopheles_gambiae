#!/bin/bash

#SBATCH --job-name=db_check # the name for the cluster scheduler
#SBATCH --time=00:10:00 # Maximum allowed runtime per iteration
#SBATCH --mem-per-cpu=80G
#SBATCH --output=logfiles/db_check.out # the name of the output files
#SBATCH --mail-type=ALL
#SBATCH --mail-user=david.hemprich-bennett@biology.ox.ac.uk

# in your sbatch script or interactive shell
export BLASTDB=/data/zool-mosquito_ecology/zool2291/BLAST_nt_db
export BLASTDB_TAXDB=/data/zool-mosquito_ecology/zool2291/BLAST_taxonomy_db
module load BLAST+
which blastn
blastn -version
which blastdbcmd
blastdbcmd -version
env | egrep '^BLAST(DB|DB_TAXDB|TAXDB)='

module load BLAST+
which blastn
blastn -version
which blastdbcmd
blastdbcmd -version
env | egrep '^BLAST(DB|DB_TAXDB|TAXDB)='

printf ">q1\nA\n" > /tmp/test_query.fa
blastn -db nt -query /tmp/test_query.fa -max_target_seqs 1 \
  -outfmt "6 qseqid sacc staxids sscinames sblastname" -num_threads 1 | sed -n '1,5p'
