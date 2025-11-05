#!/bin/bash

#SBATCH --job-name=primer_blast # the name for the cluster scheduler
#SBATCH --time=05:00:00 # Maximum allowed runtime per iteration
#SBATCH --mem-per-cpu=80G
#SBATCH --array=1-96 # the number of iterations
#SBATCH --output=logfiles/primer_blast_%A_%a.out # the name of the output files
#SBATCH --mail-type=ALL
#SBATCH --mail-user=david.hemprich-bennett@biology.ox.ac.uk

module purge
module load BLAST

export SINGULARITY_CACHEDIR=$DATA/sif_lib/

primers=data/primer_pairs/${SLURM_ARRAY_TASK_ID}.fasta

echo primers are ${primers}

export BLASTDB=$DATA/BLAST_nt_db/nt
export BLASTDB_TAXDB=$DATA/BLAST_nt_db/taxdb

# singularity exec --bind /home/zool2291/projects/qpcr_anopheles_gambiae:/home/zool2291/projects/qpcr_anopheles_gambiae,/data/zool-mosquito_ecology/zool2291/BLAST_nt_db:/data/zool-mosquito_ecology/zool2291/BLAST_nt_db docker://ncbi/blast:latest\
blastn -num_threads 34 \
 -db /data/zool-mosquito_ecology/zool2291/BLAST_nt_db/nt \
 -query ${primers} \
 -out /home/zool2291/projects/qpcr_anopheles_gambiae/data/blast_outputs/${SLURM_ARRAY_TASK_ID}.txt \
 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids sscinames scomnames"



