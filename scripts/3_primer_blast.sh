#!/bin/bash

#SBATCH --job-name=primer_blast # the name for the cluster scheduler
#SBATCH --time=05:00:00 # Maximum allowed runtime per iteration
#SBATCH --mem-per-cpu=80G
#SBATCH --array=1-1 # the number of iterations
#SBATCH --output=logfiles/primer_blast_%A_%a.out # the name of the output files
#SBATCH --mail-type=ALL
#SBATCH --mail-user=david.hemprich-bennett@biology.ox.ac.uk

module purge

export SINGULARITY_CACHEDIR=$DATA/sif_lib/

primers=$(cat data/primer_pairs/${SLURM_ARRAY_TASK_ID}.fasta)

cat primers are ${primers}

export BLASTDB=$DATA/BLAST_nt_db

singularity exec --bind /home/zool2291/projects/qpcr_anopheles_gambiae:/home/zool2291/projects/qpcr_anopheles_gambiae,/data/zool-mosquito_ecology/zool2291/BLAST_nt_db:/data/zool-mosquito_ecology/zool2291/BLAST_nt_db docker://ncbi/blast:latest blastn -num_threads 34 -db ${BLASTDB}/nt -query ${primers} -out data/blast_outputs/${SLURM_ARRAY_TASK_ID} -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids sscinames scomnames"



