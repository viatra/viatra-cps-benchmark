#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )/.."

# First parameter is used to specify benchmark config name (folder inside scripts/configs)
CPS_BENCHMARK=$1

rm -rf benchmark

mkdir benchmark
cp -r releng/com.incquerylabs.examples.cps.rcpapplication.headless.product/target/products/com.incquerylabs.examples.cps.benchmark.app/linux/gtk/x86_64/. benchmark/eclipse
cp scripts/run_linux.py benchmark
cp scripts/convert_results.sh benchmark
cp ${WORKSPACE}/scripts/configs/${CPS_BENCHMARK}/data.json ${WORKSPACE}/benchmark

cd benchmark
python3 -u run_linux.py ${CPS_BENCHMARK}
chmod +x convert_results.sh
./convert_results.sh
