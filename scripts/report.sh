#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )/.."

# First parameter is used to specify benchmark config name (folder inside scripts/configs)
CPS_BENCHMARK=$1

cd benchmark
rm -rf diagrams
mkdir diagrams
python3 ${WORKSPACE}/mondo-sam/reporting/report.py --source ${WORKSPACE}/benchmark/results/results.csv \
--output ${WORKSPACE}/benchmark/diagrams/ --config ${WORKSPACE}/scripts/configs/${CPS_BENCHMARK}/config.json

cp ${WORKSPACE}/scripts/configs/${CPS_BENCHMARK}/report.header ${WORKSPACE}/benchmark/cpsBenchmarkReport.html
cat ${WORKSPACE}/benchmark/*.properties >> ${WORKSPACE}/benchmark/cpsBenchmarkReport.html
cat ${WORKSPACE}/scripts/configs/${CPS_BENCHMARK}/report.body >> ${WORKSPACE}/benchmark/cpsBenchmarkReport.html
