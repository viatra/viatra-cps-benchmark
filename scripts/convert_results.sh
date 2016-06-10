#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )"

python3 ../mondo-sam/reporting/convert_results.py --source results/json/ \
--jsonfile results/results.json \
--csvfile results/results.csv
