#!/bin/bash

#SBATCH --job-name=db_check # the name for the cluster scheduler
#SBATCH --time=05:00:00 # Maximum allowed runtime per iteration
#SBATCH --mem-per-cpu=80G
#SBATCH --array=1-1 # the number of iterations
#SBATCH --output=logfiles/db_check.out # the name of the output files
#SBATCH --mail-type=ALL
#SBATCH --mail-user=david.hemprich-bennett@biology.ox.ac.uk

# 1) SLURM and BLAST binary environment
echo "SLURM: CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}, ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}"
module purge
module load BLAST+
which blastn || echo "blastn missing"
blastn -version || true
which blastdbcmd || true
env | egrep '^BLAST(DB|DB_TAXDB|TAXDB)='

# 2) Does the primer file exist & look OK?
primers=data/primer_pairs/${SLURM_ARRAY_TASK_ID}.fasta
echo "primer file: ${primers}"
ls -l "${primers}" || ls -l data/primer_pairs | sed -n '1,200p'
sed -n '1,120p' "${primers}" || true   # show headers + sequence lines

# 3) A single controlled blastn run for one primer (capture stderr too)
printf "\n--- single-test blast (capture stderr) ---\n"
blastn -db nt -task blastn-short -query "${primers}" -max_target_seqs 100 \
  -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids sscinames scomnames" \
  -num_threads 1 -evalue 1000  2>&1 | sed -n '1,200p'
