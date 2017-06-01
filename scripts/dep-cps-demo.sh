#!/bin/bash

cd "$( cd "$( dirname "$0" )" && pwd )/.."

# Clone results repository if needed
if [ -d "cps-demo" ]; then
  # Repo exists, update
  cd cps-demo
  git fetch
  git reset origin/master --hard
  cd ..
else
  # Clone repo
  git clone https://git.eclipse.org/r/viatra/org.eclipse.viatra.examples cps-demo
fi
