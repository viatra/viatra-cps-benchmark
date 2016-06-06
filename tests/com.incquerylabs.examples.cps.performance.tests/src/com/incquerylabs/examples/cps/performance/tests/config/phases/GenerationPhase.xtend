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

package com.incquerylabs.examples.cps.performance.tests.config.phases

import eu.mondo.sam.core.DataToken
import eu.mondo.sam.core.metrics.MemoryMetric
import eu.mondo.sam.core.metrics.TimeMetric
import eu.mondo.sam.core.phases.AtomicPhase
import eu.mondo.sam.core.results.PhaseResult
import org.eclipse.viatra.examples.cps.generator.CPSPlanBuilder
import org.eclipse.viatra.examples.cps.generator.dtos.CPSFragment
import org.eclipse.viatra.examples.cps.generator.dtos.CPSGeneratorInput
import org.eclipse.viatra.examples.cps.generator.interfaces.ICPSConstraints
import org.eclipse.viatra.examples.cps.generator.queries.Validation
import org.eclipse.viatra.examples.cps.generator.utils.StatsUtil
import com.incquerylabs.examples.cps.performance.tests.config.CPSDataToken
import org.eclipse.viatra.examples.cps.planexecutor.PlanExecutor

class GenerationPhase extends AtomicPhase{
	
	ICPSConstraints constraints
	
	new(String name, ICPSConstraints constraints) {
		super(name)
		this.constraints = constraints
	}
	
	override execute(DataToken token, PhaseResult phaseResult) {
		val cpsToken = token as CPSDataToken
		val generatorTimer = new TimeMetric("Time")
		val generatorMemory = new MemoryMetric("Memory")

		val CPSGeneratorInput input = new CPSGeneratorInput(cpsToken.seed, constraints, cpsToken.cps2dep.cps);
		var plan = getPlan();
		
		var PlanExecutor<CPSFragment, CPSGeneratorInput> generator = new PlanExecutor();
		
		// Generating
		generatorTimer.startMeasure
		var fragment = generator.process(plan, input);
		generatorTimer.stopMeasure
		generatorMemory.measure
		
		
		Validation.instance.prepare(fragment.engine);
		val cpsStats = StatsUtil.generateStatsForCPS(fragment.engine, fragment.modelRoot)
		cpsStats.log
		fragment.engine.dispose
		
		phaseResult.addMetrics(generatorTimer, generatorMemory)
	}
	
	protected def getPlan() {
		CPSPlanBuilder.buildDefaultPlan
	}
}