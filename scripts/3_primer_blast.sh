#!/bin/bash

#SBATCH --job-name=primer_blast # the name for the cluster scheduler
#SBATCH --time=50:00:00 # Maximum allowed runtime per iteration
#SBATCH --mem-per-cpu=80G
#SBATCH --array=1-96 # the number of iterations
#SBATCH --output=logfiles/primer_blast_%A_%a.out # the name of the output files
#SBATCH --mail-type=ALL
#SBATCH --mail-user=david.hemprich-bennett@biology.ox.ac.uk

module purge
module load BLAST+

export SINGULARITY_CACHEDIR=$DATA/sif_lib/

primers=data/primer_pairs/${SLURM_ARRAY_TASK_ID}.fasta

echo primers are ${primers}

export BLASTDB=/data/zool-mosquito_ecology/zool2291/BLAST_nt_db
export BLASTDB_TAXDB=/data/zool-mosquito_ecology/zool2291/BLAST_taxonomy_db


blastn -num_threads 34 \
 -db nt \
 -query ${primers} \
 -out /home/zool2291/projects/qpcr_anopheles_gambiae/data/blast_outputs/${SLURM_ARRAY_TASK_ID}.txt \
 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids sscinames scomnames"



