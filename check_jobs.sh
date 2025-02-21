#!/usr/bin/env bash

echo "started at: `date`"

log_dir="$(pwd)"
log_file="logs/dada2-analysis.log.txt"

file=$log_dir/$log_file

echo "FILE: '$file'"

# 1) Extract job IDs from the log
job_IDs=$(
  grep -i "Submitted batch job" "${file}" \
    | rev \
    | cut -d ' ' -f1 \
    | rev \
    | grep -v "rule(s)." \
    | sed "s/'\.$//" \
    | sort \
    | uniq
)

# 2) Initialize (or empty) the 'result' file
> jobIDs_info.txt

cat << EOF > jobIDs_info.txt
JobID                               JobName  Partition    Account  AllocCPUS     MaxRSS      State    Elapsed ExitCode 
------------ ------------------------------ ---------- ---------- ---------- ---------- ---------- ---------- -------- 
EOF


# 3) Loop over each job ID
for i in $job_IDs; do
  # 4) Run sacct for this job ID, filter unwanted lines, and append to 'result'
  sacct -j "$i" \
    --format="JobID,JobName%30,Partition,Account,AllocCPUS,MaxRSS,State,Elapsed,ExitCode" --noheader\
    | grep -vE '(\.ex\+)' \
    >> jobIDs_info.txt

  # Optionally, echo a newline (or any text) afterward:
  echo "" >> jobIDs_info.txt
done

echo "Finished at: `date`"
