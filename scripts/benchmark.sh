#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )"

cp -r releng/com.incquerylabs.examples.cps.rcpapplication.headless.product/target/products/com.incquerylabs.examples.cps.benchmark.app/linux/gtk/x86_64/. benchmark/eclipse
cp scripts/run_linux.py benchmark
python3 benchmark/run_linux.py
./scripts/report.sh