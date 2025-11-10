#!/bin/bash

#SBATCH --job-name=db_check # the name for the cluster scheduler
#SBATCH --time=00:10:00 # Maximum allowed runtime per iteration
#SBATCH --mem-per-cpu=80G
#SBATCH --output=logfiles/db_check.out # the name of the output files
#SBATCH --mail-type=ALL
#SBATCH --mail-user=david.hemprich-bennett@biology.ox.ac.uk

module load BLAST+

export BLASTDB=/data/zool-mosquito_ecology/zool2291/BLAST_nt_db
export BLASTDB_TAXDB=/data/zool-mosquito_ecology/zool2291/BLAST_taxonomy_db
export BLAST_TAXDB=/data/zool-mosquito_ecology/zool2291/BLAST_taxonomy_db

echo "ENV:"
echo "BLASTDB='$BLASTDB'"
echo "BLASTDB_TAXDB='$BLASTDB_TAXDB'"
echo "BLAST_TAXDB='$BLAST_TAXDB'"

echo "LIST nt dir:"
ls -l /data/zool-mosquito_ecology/zool2291/BLAST_nt_db | sed -n '1,200p'

echo "LIST taxdb dir:"
ls -l /data/zool-mosquito_ecology/zool2291/BLAST_taxonomy_db | sed -n '1,200p'

echo "BLAST check (nt):"
blastdbcmd -info -db /data/zool-mosquito_ecology/zool2291/BLAST_nt_db/nt 2>&1 | sed -n '1,200p'

# verify
echo "BLASTDB='$BLASTDB'"
echo "BLASTDB_TAXDB='$BLASTDB_TAXDB'"
echo "BLAST_TAXDB='$BLAST_TAXDB'"

# check taxdb is readable
blastdbcmd -info -db "$BLASTDB_TAXDB/taxdb"