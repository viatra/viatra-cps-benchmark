/*******************************************************************************
 * Copyright (c) 2014-2016, Abel Hegedus, IncQuery Labs Ltd.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   Abel Hegedus - initial API and implementation
 *******************************************************************************/
package com.incquerylabs.examples.cps.performance.tests.config.scenarios

import com.incquerylabs.examples.cps.performance.tests.config.cases.BenchmarkCase
import com.incquerylabs.examples.cps.performance.tests.config.phases.EMFResourceInitializationPhase
import com.incquerylabs.examples.cps.performance.tests.config.phases.InitializationPhase
import com.incquerylabs.examples.cps.performance.tests.config.phases.QueryPhase
import eu.mondo.sam.core.phases.IterationPhase
import eu.mondo.sam.core.phases.SequencePhase

class QueryScenario extends CPSBenchmarkScenario {
	
	new(BenchmarkCase benchmarkCase) {
		super(benchmarkCase)
	}
	
	override getName() {
		"Query"
	}
	
	override build() {
		val seq = new SequencePhase
		val innerSeq = new SequencePhase
		innerSeq.addPhases(
			benchmarkCase.getModificationPhase("Modification"),
			new QueryPhase("Query2")
		)

		val iter = new IterationPhase(5)
		iter.phase = innerSeq

		seq.addPhases(
			new EMFResourceInitializationPhase("EMFResourceInitialization"),
			benchmarkCase.getGenerationPhase("Generation"),
			new InitializationPhase("Initialization"),
			new QueryPhase("Query1"),
			iter
		)
		rootPhase = seq
	}
	
}