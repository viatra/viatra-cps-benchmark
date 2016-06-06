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

import eu.mondo.sam.core.phases.IterationPhase
import eu.mondo.sam.core.phases.SequencePhase
import org.eclipse.viatra.examples.cps.generator.utils.RandomUtils
import com.incquerylabs.examples.cps.performance.tests.config.cases.BenchmarkCase
import com.incquerylabs.examples.cps.performance.tests.config.phases.EMFResourceInitializationPhase
import com.incquerylabs.examples.cps.performance.tests.config.phases.InitializationPhase
import com.incquerylabs.examples.cps.performance.tests.config.phases.M2MTransformationPhase

class BasicXformScenario extends CPSBenchmarkScenario {
	protected extension RandomUtils randUtil = new RandomUtils;

	new(BenchmarkCase benchmarkCase) {
		super(benchmarkCase)
	}

	override build() {
		val seq = new SequencePhase
		val innerSeq = new SequencePhase
		innerSeq.addPhases(
			benchmarkCase.getModificationPhase("Modification"),
			new M2MTransformationPhase("Transformation")
		)

		val iter = new IterationPhase(5)
		iter.phase = innerSeq

		seq.addPhases(
			new EMFResourceInitializationPhase("ResourceInitialization"),
			benchmarkCase.getGenerationPhase("Generation"),
			new InitializationPhase("Initialization"),
			new M2MTransformationPhase("Transformation"),
			iter
		)
		rootPhase = seq
	}
	
	override getName() {
		"BasicXform"
	}
}