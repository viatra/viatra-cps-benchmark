#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )/.."

rm -rf benchmark

mkdir benchmark
cp -r releng/com.incquerylabs.examples.cps.rcpapplication.headless.product/target/products/com.incquerylabs.examples.cps.benchmark.app/linux/gtk/x86_64/. benchmark/eclipse
cp scripts/run_linux.py benchmark
cp scripts/convert_results.sh benchmark
cp scripts/config.json benchmark
cp scripts/report.sh benchmark

cd benchmark
python3 run_linux.py
./convert_results.sh
./report.sh