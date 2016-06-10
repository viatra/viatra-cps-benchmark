#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )"

python3 ../mondo-sam/reporting/convert_results.py --source benchmark/results/json/ \
--jsonfile benchmark/results.json \
--csvfile benchmark/results/results.csv
