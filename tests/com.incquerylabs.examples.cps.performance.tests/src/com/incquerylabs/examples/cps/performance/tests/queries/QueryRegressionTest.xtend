/*******************************************************************************
 * Copyright (c) 2014-2016, IncQuery Labs Ltd.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   Akos Horvath, Abel Hegedus, Tamas Borbas, Marton Bur, Zoltan Ujhelyi, Daniel Segesdi, Zsolt Kovari - initial API and implementation
 *******************************************************************************/

package com.incquerylabs.examples.cps.performance.tests.queries

import com.google.common.base.Stopwatch
import com.google.common.collect.Maps
import java.util.Map
import java.util.Random
import java.util.concurrent.TimeUnit
import org.apache.log4j.Logger
import org.eclipse.viatra.examples.cps.generator.CPSPlanBuilder
import org.eclipse.viatra.examples.cps.generator.dtos.CPSFragment
import org.eclipse.viatra.examples.cps.generator.dtos.CPSGeneratorInput
import org.eclipse.viatra.examples.cps.generator.queries.Validation
import org.eclipse.viatra.examples.cps.generator.utils.CPSModelBuilderUtil
import org.eclipse.viatra.examples.cps.generator.utils.StatsUtil
import com.incquerylabs.examples.cps.performance.tests.config.cases.StatisticBasedCase
import org.eclipse.viatra.examples.cps.planexecutor.PlanExecutor
import org.eclipse.viatra.examples.cps.tests.util.CPSTestBase
import org.eclipse.viatra.examples.cps.xform.m2m.incr.viatra.patterns.CpsXformM2M
import org.eclipse.viatra.query.runtime.api.AdvancedViatraQueryEngine
import org.eclipse.viatra.query.runtime.api.GenericQueryGroup
import org.eclipse.viatra.query.runtime.api.IQueryGroup
import org.eclipse.viatra.query.runtime.api.IQuerySpecification
import org.eclipse.viatra.query.runtime.emf.EMFScope
import org.junit.Test

class QueryRegressionTest extends CPSTestBase{
	
	protected static extension Logger logger = Logger.getLogger("cps.performance.tests.queries.QueryRegressionTest")
    protected extension CPSModelBuilderUtil modelBuilder = new CPSModelBuilderUtil
	
	AdvancedViatraQueryEngine incQueryEngine
	IQueryGroup queryGroup
	Map<String, Long> results = Maps.newTreeMap()
	
	public def prepare() {
		info("Preparing query performance test")
		
		val rs = executeScenarioXformForConstraints(16)
		incQueryEngine = AdvancedViatraQueryEngine.createUnmanagedEngine(new EMFScope(rs))
		queryGroup = GenericQueryGroup.of(
			CpsXformM2M.instance
		)
		queryGroup.prepare(incQueryEngine)
		debug("Base index created")
		incQueryEngine.wipe()
		debug("IncQuery engine wiped")
		logMemoryProperties
		info("Prepared query performance test")
	}
	
	def executeScenarioXformForConstraints(int size) {	
		val seed = 11111
		val Random rand = new Random(seed)
		val StatisticBasedCase benchmarkCase = new StatisticBasedCase(size, rand)
		val constraints = benchmarkCase.getConstraints()
		val cps2dep = prepareEmptyModel("testModel"+System.nanoTime)
		
		val CPSGeneratorInput input = new CPSGeneratorInput(seed, constraints, cps2dep.cps)
		var plan = CPSPlanBuilder.buildDefaultPlan
		
		var PlanExecutor<CPSFragment, CPSGeneratorInput> generator = new PlanExecutor()
		
		var generateTime = Stopwatch.createStarted
		var fragment = generator.process(plan, input)
		generateTime.stop
		info("Generating time: " + generateTime.elapsed(TimeUnit.MILLISECONDS) + " ms")
		
		val engine = AdvancedViatraQueryEngine.from(fragment.engine);
		Validation.instance.prepare(engine);
		
		StatsUtil.generateStatsForCPS(engine, fragment.modelRoot).log
		
		engine.dispose
		
		cps2dep.eResource.resourceSet
	}
	
	@Test
//	@Ignore
	public def queryPerformance() {
		prepare()
		
		info("Starting query performance test")
		
		for (IQuerySpecification<?> specification : queryGroup.getSpecifications) {
			
			debug("Measuring pattern " + specification.getFullyQualifiedName)
			incQueryEngine.wipe
			val usedHeapBefore = logMemoryProperties
			
			debug("Building Rete")
			val watch = Stopwatch.createStarted
			val matcher = specification.getMatcher(incQueryEngine)
			watch.stop()
			val countMatches = matcher.countMatches
			val usedHeapAfter = logMemoryProperties
			
			val usedHeap = usedHeapAfter - usedHeapBefore
			results.put(specification.getFullyQualifiedName, usedHeap)
			info("Pattern " + specification.fullyQualifiedName + "( " + countMatches + " matches, used " + usedHeap +
					" kByte heap, took " + watch.elapsed(TimeUnit.MILLISECONDS) + " ms)")
			
			incQueryEngine.wipe
			logMemoryProperties
		}
		
		info("Finished query performance test")
		
		printResults()
	}
	
	def printResults() {
		
		val resultSB = new StringBuilder("\n\nRegression test results:\n")
		results.entrySet.forEach[entry |
			resultSB.append("  " + entry.key + "," + entry.value + "\n")
		]
		info(resultSB)
		
	}
	
	/**
	 * Calls garbage collector 5 times, sleeps 1 second and logs the used, total and free heap sizes in MByte.
	 * 
	 * @param logger
	 * @return The amount of used heap memory in kBytes
	 */
	def static logMemoryProperties() {
		(0..4).forEach[Runtime.getRuntime().gc()]
		
		try {
			Thread.sleep(1000)
		} catch (InterruptedException e) {
			trace("Sleep after GC interrupted")
		}
		
		val totalHeapKB = Runtime.getRuntime().totalMemory() / 1024;
		val freeHeapKB = Runtime.getRuntime().freeMemory() / 1024;
		val usedHeapKB = totalHeapKB - freeHeapKB;
		info("Used Heap size: " + usedHeapKB / 1024 + " MByte (Total: " + totalHeapKB / 1024 + " MByte, Free: " + freeHeapKB / 1024 + " MByte)")
		
		usedHeapKB
	}
}