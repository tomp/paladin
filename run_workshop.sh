#!/usr/bin/bash
# This runs the jobs that Kevin created for his paladin workshop, back in March 2026
# This workflow is described in https://github.com/kmboehm/paladin/blob/main/README.md

DATA_DIR="workshop_data"
DATA_SCRIPT="scripts/synthesize_workshop_data.py"
DATA_FILE="${DATA_DIR}/synthetic_data.parquet"

YMDHM=$(date +%y%m%d-%H%M)
LOG_FILE="workshop-${YMDHM}.log"

# Send all further output to the log file
echo "Log file: '${LOG_FILE}'"
exec > $LOG_FILE 2>&1

echo "## $0"
echo "Start: $(date)"
echo

# Generate synthetic data
if [[ ! -d $DATA_DIR || ! -f $DATA_FILE ]]; then
    echo "Create a random input data set..."
    time uv run "${DATA_SCRIPT} --output-dir '${DATA_DIR}'"
else
    echo "Skip data creation - test data already exists."
fi

# The simple configs automatically use CPU if no GPU is available.

# Classification (binary biomarker prediction, beta-binomial loss)
echo
echo "---------------- simple-clf ----------------"
time uv run src/paladin/run.py --config-name simple-clf

# Regression (continuous value prediction, MSE loss)
echo
echo "---------------- simple-reg ----------------"
time uv run src/paladin/run.py --config-name simple-reg

# Survival analysis (Cox proportional hazards)
echo
echo "---------------- simple-surv ----------------"
time uv run src/paladin/run.py --config-name simple-surv

echo "---------------------------------------------"
echo
echo "Stop: $(date)"
echo





