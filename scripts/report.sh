#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )"

python3 ../mondo-sam/reporting/report.py --source results/results.csv \
--output diagrams/ --config config.json
