#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )"

../../mondo-sam/reporting/convert_results.py --source ../../incquery-examples-cps/tests/org.eclipse.incquery.examples.cps.performance.tests/results/json/ \
--jsonfile ../../incquery-examples-cps/tests/org.eclipse.incquery.examples.cps.performance.tests/results/results.json \
--csvfile ../../incquery-examples-cps/tests/org.eclipse.incquery.examples.cps.performance.tests/results/results.csv
