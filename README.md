# VIATRA CPS Benchmark

Performance benchmark using the VIATRA CPS demonstrator

[![Build Status](https://build.incquerylabs.com/jenkins/job/viatra-cps-benchmark/job/master/badge/icon)](https://build.incquerylabs.com/jenkins/job/viatra-cps-benchmark/job/master/)

* Domain: [CPS Demonstrator](http://help.eclipse.org/2019-09/index.jsp?topic=%2Forg.eclipse.viatra.documentation.help%2Fhtml%2Fcps%2FHome.html&cp=102_0)
* [Specification](https://github.com/viatra/viatra-cps-benchmark/wiki/Benchmark-specification)
* [Build job for executing the benchmark](https://build.incquerylabs.com/jenkins/job/viatra-cps-benchmark/) 
* Results:
  * [Latest report](https://build.incquerylabs.com/jenkins/job/viatra-cps-benchmark/lastSuccessfulBuild/artifact/benchmark/cpsBenchmarkReport.html)
  * [Raw data](https://github.com/viatra/viatra-cps-benchmark-results)


## Getting started

You can use [Oomph](https://www.eclipse.org/oomph) to deploy a ready to go Eclipse IDE with the projects imported and all required dependencies already installed.

1. Start the [Oomph installer](https://wiki.eclipse.org/Eclipse_Oomph_Installer), select the Eclipse product and the product version
2. Add the VIATRA CPS Demonstrator project (see https://github.com/viatra/viatra-docs/blob/master/cps/Contributor-Guide.adoc for details)
3. Add the benchmark setup URL as well: https://raw.githubusercontent.com/viatra/viatra-cps-benchmark/master/setup/com.incquerylabs.examples.cps.setup/viatra-cps-benchmark.setup
4. Check the `VIATRA CPS Demo` and `CPS Benchmark` projects
5. Use the drop-down menus for each field on the Variables page to select the appropriate choices
  * For the repositories, select read-only, anonymous option if you have any doubts

Read the [Oomph help](http://download.eclipse.org/oomph/help/org.eclipse.oomph.setup.doc/html/user/wizard/index.html) if you are lost in the wizard's forest.
