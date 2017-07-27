#!/bin/bash

cd "$( cd "$( dirname "$0" )" && pwd )/.."

# Clone results repository if needed
if [ -d "mondo-sam" ]; then
  # Repo exists, update
  cd mondo-sam
  git fetch
  git reset origin/0.1-maintenance --hard
  cd ..
else
  # Clone repo
  git clone git@github.com:FTSRG/mondo-sam.git mondo-sam
  cd mondo-sam
  git fetch
  git checkout 0.1-maintenance
fi
