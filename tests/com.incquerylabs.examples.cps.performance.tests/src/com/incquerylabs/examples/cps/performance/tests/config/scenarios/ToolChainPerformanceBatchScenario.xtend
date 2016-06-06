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

package com.incquerylabs.examples.cps.performance.tests.config.scenarios

import eu.mondo.sam.core.phases.SequencePhase
import com.incquerylabs.examples.cps.performance.tests.config.cases.BenchmarkCase
import com.incquerylabs.examples.cps.performance.tests.config.phases.EMFResourceInitializationPhase
import com.incquerylabs.examples.cps.performance.tests.config.phases.EmptyPhase
import com.incquerylabs.examples.cps.performance.tests.config.phases.InitializationPhase
import com.incquerylabs.examples.cps.performance.tests.config.phases.M2MTransformationPhase
import com.incquerylabs.examples.cps.performance.tests.config.phases.M2TTransformationPhase

/*
 * Scenario for given model statistics
 */
class ToolChainPerformanceBatchScenario extends CPSBenchmarkScenario {
	new(BenchmarkCase benchmarkCase) {
		super(benchmarkCase)
	}
	
	override build() {
		
		val seq = new SequencePhase
		seq.addPhases(
			new EMFResourceInitializationPhase("EMFResourceInitialization"),
			benchmarkCase.getGenerationPhase("Generation"),
			new InitializationPhase("Initialization"),
			new M2MTransformationPhase("M2MTransformation1"),
			new M2TTransformationPhase("M2TTransformation1"),
			new EmptyPhase("ChangeMonitorInitialization"),
			benchmarkCase.getModificationPhase("Modification"),
			new M2MTransformationPhase("M2MTransformation2"),
			new M2TTransformationPhase("M2TTransformation2")
		)
		rootPhase = seq
	}
	
	override getName() {
		return "ToolChainPerformance"
	}

}
