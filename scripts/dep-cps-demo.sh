#!/bin/bash

cd "$( cd "$( dirname "$0" )" && pwd )/.."

rm -rf cps-demo
git clone https://git.eclipse.org/r/viatra/org.eclipse.viatra.examples cps-demo