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
import com.incquerylabs.examples.cps.performance.tests.config.metrics.AverageMemoryMetric
import com.incquerylabs.examples.cps.performance.tests.config.metrics.PeakMemoryMetric
import eu.mondo.sam.core.metrics.MemoryMetric
import eu.mondo.sam.core.metrics.TimeMetric

class M2MTransformationPhase extends CPSBenchmarkPhase {
	
	new(String name) {
		super(name, true)
	}
	
	override execute(CPSDataToken cpsToken, TimeMetric timer, MemoryMetric memory) {
		
		// prepare metrics
		val peakMetric = new PeakMemoryMetric("PeakMemory")
		val averageMetric = new AverageMemoryMetric("AverageMemory", AVERAGE_MEMORY_INTERVAL)
		averageMetric.startMeasurement
		peakMetric.reset
		timer.startMeasure
		
		// do computation
		cpsToken.xform.executeTransformation
		
		// measure metrics
		timer.stopMeasure
		averageMetric.stopMeasurement
		peakMetric.measure
		memory.measure
		
		return #{peakMetric, averageMetric}
	}
	
}