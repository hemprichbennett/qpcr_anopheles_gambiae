#!/bin/bash

#SBATCH --job-name=primer_blast # the name for the cluster scheduler
#SBATCH --time=50:00:00 # Maximum allowed runtime per iteration
#SBATCH --mem-per-cpu=80G
#SBATCH --array=1-96 # the number of iterations
#SBATCH --output=logfiles/primer_blast_%A_%a.out # the name of the output files
#SBATCH --cpus-per-task=10
#SBATCH --mail-type=ALL
#SBATCH --mail-user=david.hemprich-bennett@biology.ox.ac.uk

module purge
module load BLAST+

primers=data/primer_pairs/${SLURM_ARRAY_TASK_ID}.fasta
echo "Running array task ${SLURM_ARRAY_TASK_ID} on $(hostname)"
echo "Primers file: ${primers}"
ls -l "${primers}" || { echo "Primer file missing"; exit 1; }
sed -n '1,40p' "${primers}" || true

export BLASTDB=/data/zool-mosquito_ecology/zool2291/BLAST_nt_db
export BLASTDB_TAXDB=/data/zool-mosquito_ecology/zool2291/BLAST_taxonomy_db

# run blastn optimized for short queries; capture both stdout and stderr
blastn -num_threads ${SLURM_CPUS_PER_TASK} \
 -task blastn-short -word_size 7 -evalue 1000 \
 -db nt \
 -query "${primers}" \
 -max_target_seqs 5000 \
 -out /home/zool2291/projects/qpcr_anopheles_gambiae/data/blast_outputs/${SLURM_ARRAY_TASK_ID}.txt \
 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids sscinames scomnames" \
 2> /home/zool2291/projects/qpcr_anopheles_gambiae/data/blast_outputs/${SLURM_ARRAY_TASK_ID}.err || true
