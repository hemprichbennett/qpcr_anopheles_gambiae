#!/bin/bash

#SBATCH --job-name=db_check # the name for the cluster scheduler
#SBATCH --time=00:10:00 # Maximum allowed runtime per iteration
#SBATCH --mem-per-cpu=80G
#SBATCH --output=logfiles/db_check.out # the name of the output files
#SBATCH --mail-type=ALL
#SBATCH --mail-user=david.hemprich-bennett@biology.ox.ac.uk

module load BLAST+

export BLASTDB="/data/zool-mosquito_ecology/zool2291/BLAST_nt_db:/data/zool-mosquito_ecology/zool2291/BLAST_taxonomy_db"
export BLASTDB_TAXDB=/data/zool-mosquito_ecology/zool2291/BLAST_taxonomy_db
export BLAST_TAXDB=/data/zool-mosquito_ecology/zool2291/BLAST_taxonomy_db

# verify environment
echo "BLASTDB='$BLASTDB'"
echo "BLASTDB_TAXDB='$BLASTDB_TAXDB'"

# now test
blastdbcmd -info -db nt            # should print nt info (as before)
blastdbcmd -info -db taxdb         # should now print taxdb info (no error)