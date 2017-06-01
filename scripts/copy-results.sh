#!/bin/bash

#$1=${BENCHMARK_CONFIG}
#$2=${BUILD_ID}-build${BUILD_NUMBER}
resultFolder=$2
resultPath=viatra-cps-benchmark-results/$1/$resultFolder

# Clone results repository if needed
if [ -d "viatra-cps-benchmark-results" ]; then
  # Repo exists, update
  cd viatra-cps-benchmark-results
  git fetch
  git reset origin/master --hard
  cd ..
else
  # Clone repo
  git clone git@github.com:viatra/viatra-cps-benchmark-results.git
fi

# Make result folder with parents
mkdir -p $resultPath

# Copy results to new folder
cp -R benchmark/results/* $resultPath
cp benchmark/*.json $resultPath
cp benchmark/*.properties $resultPath

# Git commit (with add all) then push
cd viatra-cps-benchmark-results
git add $1/$resultFolder
git commit -q -m "Add results for $resultFolder with config $1"
git push origin
