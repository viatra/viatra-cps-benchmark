# Benchmark CPS2DEP variant YAMTL (batch)

This project provides a solution of the **batch** component of the [VIATRA CPS benchmark](https://github.com/viatra/viatra-cps-benchmark) using the [YAMTL engine](https://yamtl.github.io).

The most relevant files are the following:

* [Transformation definition](https://github.com/yamtl/viatra-cps-batch-benchmark/blob/master/m2m.batch.cps2dep.yamtl/src/main/java/cps2dep/yamtl/Cps2DepYAMTL.xtend)
* [Runners for the various scenarios](https://github.com/yamtl/viatra-cps-batch-benchmark/tree/master/m2m.batch.cps2dep.yamtl/src/main/java/experiments/yamtl)
  * `Cps2DepRunner_YAMTL_SCENARIO`: runs one single experiment for models of different sizes of `SCENARIO`
  * `Cps2DepRunner_YAMTL_SCENARIO_full`: runs several experiments for models of different sizes of `SCENARIO`
* [Test cases](https://github.com/yamtl/viatra-cps-batch-benchmark/tree/master/m2m.batch.cps2dep.yamtl/src/test/java): more information on these test cases can be found in the following section.

## Benchmark sanity checks

The VIATRA CPS Benchmark provides a number of [test cases](https://github.com/viatra/org.eclipse.viatra.examples/tree/master/cps/tests/org.eclipse.viatra.examples.cps.xform.m2m.tests/src/org/eclipse/viatra/examples/cps/xform/m2m/tests/mappings) as sanity checks for the benchmark solutions.

The batch solution implemented with YAMTL is currently passing those tests, which are implemented under `src/test/java`. These classes have been extracted from the project [org.eclipse.viatra.examples.cps.xform.m2m.tests](https://github.com/viatra/org.eclipse.viatra.examples/tree/master/cps/tests/org.eclipse.viatra.examples.cps.xform.m2m.tests), keeping class namespaces for facilitating traceability. A few modifications were required in order to:
1. Execute the test driver on a local machine. 
2. To circumvent problems found in the tests and in the assumptions imposed by the VIATRA CPS benchmark framework on the different solutions.

Below we explain these two modifications in detail, providing the rationale for the modifications in the second point.


### 1. Adaptation of the VIATRA CPS Benchmark test driver

The classes `org.eclipse.viatra.examples.cps.xform.m2m.tests.CPS2DepTest` and `org.eclipse.viatra.examples.cps.xform.m2m.tests.CPS2DepTestWithoutParameters` have been altered in order to avoid dependencies with the VIATRA CPS benchmark test driver.

Test classes have been instrumented in order to reimplement the dependencies to the VIATRA CPS benchmark test driver:
* test classes are not parameterized
* the corresponding constructor has been replaced with:	

```
val extension Cps2DepTestDriver_YAMTL = new Cps2DepTestDriver_YAMTL
val extension CPSModelBuilderUtil = new CPSModelBuilderUtil
new() {
	super()
}
```

The class `experiments.yamtl.Cps2DepTestDriver_YAMTL` under `src/test/java` contains the code implementing the methods `initializeTransformation(CPSToDeployment)` and `executeTransformation()`. 



### 2. Modifications made to test cases

The following issues were found:

#### 2.1. Remove host instance

Removing a `hostInstance` does not trigger the deletion of the reference `allocatedTo` as the object is still in the resource.

Test cases affected:

  * `StateMachineMappingTest::removeHostInstanceOfBehavior()`
  * `StateMappingTest::removeHostInstanceOfState()`
  * `ActionMappingTest::removeHostInstanceOfSend`
  * `TransitionMappingTest::removeHostInstanceOfTransition`
  * `ApplicationMappingTest::removeHostInstanceOfApplication`
  
These test cases have been modified by unsetting the object features: `hostInstance.applications.clear`

### 2.2. Remove target state

Similarly to the aforementioned problem, the reference `targetState` is not unset when the state is removed from its container.  

Test case affected:

* `TransitionMappingTest::removeTargetState`

This test case has been modified by adding `transition.targetState = null`.


#### 2.3. Remove application instance

Similar problem as above - this time for removing an application instance.

Test case affected: `ActionMappingTest.removeApplicationInstanceOfWait`

After `app2.instances -= appInstance2` add `appInstance2.allocatedTo = null`

#### 2.4. ApplicationMappingTest

`ApplicationMappingTest::assertApplicationMapping` relies on the order in which traces are generated in order to assert whether objects are generated correctly. 

This assumption is felt to be too strong as model transformation engines with declarative features use different scheduling policies. Imposing an order in which traces are supposed to be generated becomes a constraint on the semantics of the corresponding transformation language.

Test cases affected: all the test cases in class `ApplicationMappingTest`.  

This issue has been fixed by searching a trace by the cps element `instance`, which must return a unique trace, instead of accessing the last trace. That is:

```
val trace = traces.findFirst[ trace |
	trace.cpsElements.contains(instance)
]
assertEquals("Trace is not complete (cpsElements)", #[instance], trace.cpsElements)
assertEquals("Trace is not complete (depElements)", applications, trace.deploymentElements)
assertEquals("ID not copied", instance.identifier, applications.head.id)
```

instead of

```
val lastTrace = traces.last
assertEquals("Trace is not complete (cpsElements)", #[instance], lastTrace.cpsElements)
assertEquals("Trace is not complete (depElements)", applications, lastTrace.deploymentElements)
assertEquals("ID not copied", instance.identifier, applications.head.id)
```


 

