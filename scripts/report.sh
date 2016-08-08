#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )/.."

cd benchmark
rm -rf diagrams
mkdir diagrams
python3 ${WORKSPACE}/mondo-sam/reporting/report.py --source ${WORKSPACE}/benchmark/results/results.csv \
--output ${WORKSPACE}/benchmark/diagrams/ --config ${WORKSPACE}/scripts/config.json
cp ${WORKSPACE}/benchmark/results/json/*.properties ${WORKSPACE}/benchmark

cp ${WORKSPACE}/scripts/report/report.header ${WORKSPACE}/benchmark/cpsBenchmarkReport.html
cat ${WORKSPACE}/benchmark/*.properties >> ${WORKSPACE}/benchmark/cpsBenchmarkReport.html
cat ${WORKSPACE}/scripts/report/report.body >> ${WORKSPACE}/benchmark/cpsBenchmarkReport.html
