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

import com.incquerylabs.examples.cps.performance.tests.config.CPSDataToken
import eu.mondo.sam.core.metrics.MemoryMetric
import eu.mondo.sam.core.metrics.TimeMetric
import org.eclipse.viatra.examples.cps.generator.CPSPlanBuilder
import org.eclipse.viatra.examples.cps.generator.dtos.CPSFragment
import org.eclipse.viatra.examples.cps.generator.dtos.CPSGeneratorInput
import org.eclipse.viatra.examples.cps.generator.interfaces.ICPSConstraints
import org.eclipse.viatra.examples.cps.generator.utils.StatsUtil
import org.eclipse.viatra.examples.cps.planexecutor.PlanExecutor

class GenerationPhase extends CPSBenchmarkPhase {
	
	ICPSConstraints constraints
	
	new(String name, ICPSConstraints constraints) {
		super(name, true)
		this.constraints = constraints
	}
	
	override execute(CPSDataToken cpsToken, TimeMetric timer, MemoryMetric memory) {

		val CPSGeneratorInput input = new CPSGeneratorInput(cpsToken.seed, constraints, cpsToken.cps2dep.cps);
		var plan = getPlan();
		var PlanExecutor<CPSFragment, CPSGeneratorInput> generator = new PlanExecutor();
		
		timer.startMeasure
		
		// Generating
		var fragment = generator.process(plan, input);
		
		timer.stopMeasure
		memory.measure
		
		val cpsStats = StatsUtil.generateStatsForCPS(fragment.engine, fragment.modelRoot)
		cpsStats.log
		fragment.engine.dispose
		
		return emptySet
	}
	
	protected def getPlan() {
		CPSPlanBuilder.buildDefaultPlan
	}
}