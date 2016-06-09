# VIATRA CPS Benchmark

Performance benchmark using the VIATRA CPS demonstrator

[![Build Status](https://build.inf.mit.bme.hu/jenkins/job/CPS-Demonstrator/badge/icon)](https://build.inf.mit.bme.hu/jenkins/job/CPS-Demonstrator/)

A comprehensive example showing off VIATRA features on a Cyber Physical System modeling domain.
Includes:
  * live validation
  * query-based viewers
  * model transformations
  * code generators

## Getting started

You can use [Oomph](https://www.eclipse.org/oomph) to deploy a ready to go Eclipse IDE with the projects imported and all required dependencies already installed.

1. Start the [Oomph installer](https://wiki.eclipse.org/Eclipse_Oomph_Installer), select the Eclipse product and the product version.
1. Use the **Add a project to the user project of the selected catalog** option to provide the setup file with the following URL: https://git.eclipse.org/c/viatra/org.eclipse.viatra.examples.git/plain/cps/releng/org.eclipse.viatra.examples.cps.setup/CPSExample.setup
1. Add the benchmark setup URL as well: https://raw.githubusercontent.com/IncQueryLabs/viatra-cps-benchmark/master/setup/com.incquerylabs.examples.cps.setup/viatra-cps-benchmark.setup
1. Check the `VIATRA CPS Demo` and `CPS Benchmark` projects

Read the [Oomph help](http://download.eclipse.org/oomph/help/org.eclipse.oomph.setup.doc/html/user/wizard/index.html) if you are lost in the wizard's forest.
