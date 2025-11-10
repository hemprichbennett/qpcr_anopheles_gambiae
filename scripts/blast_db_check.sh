#!/bin/bash

#SBATCH --job-name=db_check # the name for the cluster scheduler
#SBATCH --time=00:10:00 # Maximum allowed runtime per iteration
#SBATCH --mem-per-cpu=80G
#SBATCH --output=logfiles/db_check.out # the name of the output files
#SBATCH --mail-type=ALL
#SBATCH --mail-user=david.hemprich-bennett@biology.ox.ac.uk

module load BLAST

export BLASTDB=$DATA/BLAST_nt_db/nt
export BLASTDB_TAXDB=$DATA/BLAST_taxonomy_db/taxdb
export BLAST_TAXDB=$DATA/BLAST_taxonomy_db/taxdb

blastdbcmd -info -db /data/zool-mosquito_ecology/zool2291/BLAST_nt_db/nt
blastdbcmd -info -db /data/zool-mosquito_ecology/zool2291/BLAST_taxonomy_db/taxdb
