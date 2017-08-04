#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )"

python3 ${WORKSPACE}/mondo-sam/reporting/convert_results.py --source ${WORKSPACE}/benchmark/results/json/ \
--jsonfile ${WORKSPACE}/benchmark/results/results.json \
--csvfile ${WORKSPACE}/benchmark/results/results.csv
