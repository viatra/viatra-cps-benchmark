#!/bin/bash

cd "$( cd "$( dirname "$0" )" && pwd )/.."

rm -rf mondo-sam
git clone --branch 0.1-maintenance git@github.com:FTSRG/mondo-sam.git mondo-sam