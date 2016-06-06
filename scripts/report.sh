#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )"

python3 ../../mondo-sam/reporting/report.py --source ../../incquery-examples-cps/tests/org.eclipse.incquery.examples.cps.performance.tests/results/results.csv \
--output ../../incquery-examples-cps/diagrams/ --config ../../incquery-examples-cps/scripts/config.json
