#!/bin/bash

#SBATCH --job-name=nt_download # the name for the cluster scheduler
#SBATCH --time=24:00:00 # Maximum allowed runtime per iteration
#SBATCH --mem-per-cpu=80G
#SBATCH --output=logfiles/nt_download.out # the name of the output files
#SBATCH --mail-type=ALL
#SBATCH --mail-user=david.hemprich-bennett@biology.ox.ac.uk

module purge

export SINGULARITY_CACHEDIR=$DATA/sif_lib/

cd $DATA/BLAST_nt_db


# download the overall nt database
singularity exec --bind /home/zool2291/projects/qpcr_anopheles_gambiae:/home/zool2291/projects/qpcr_anopheles_gambiae,/data/zool-mosquito_ecology/zool2291/BLAST_nt_db:/data/zool-mosquito_ecology/zool2291/BLAST_nt_db docker://ncbi/blast:latest update_blastdb.pl --decompress nt

#download taxonomy
singularity exec --bind /home/zool2291/projects/qpcr_anopheles_gambiae:/home/zool2291/projects/qpcr_anopheles_gambiae,/data/zool-mosquito_ecology/zool2291/BLAST_nt_db:/data/zool-mosquito_ecology/zool2291/BLAST_nt_db docker://ncbi/blast:latest update_blastdb.pl taxdb

# makeblastdb with downloaded files
singularity exec --bind /home/zool2291/projects/qpcr_anopheles_gambiae:/home/zool2291/projects/qpcr_anopheles_gambiae,/data/zool-mosquito_ecology/zool2291/BLAST_nt_db:/data/zool-mosquito_ecology/zool2291/BLAST_nt_db docker://ncbi/blast:latest makeblastdb -in . -dbtype nucl -out taxdb

tar -zxvf taxdb.tar.gz

