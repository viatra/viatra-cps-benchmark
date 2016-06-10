#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )/.."

cd benchmark
rm -rf diagrams
mkdir diagrams
python3 ${WORKSPACE}/mondo-sam/reporting/report.py --source ${WORKSPACE}/benchmark/results/results.csv \
--output ${WORKSPACE}/benchmark/diagrams/ --config ${WORKSPACE}/scripts/config.json
