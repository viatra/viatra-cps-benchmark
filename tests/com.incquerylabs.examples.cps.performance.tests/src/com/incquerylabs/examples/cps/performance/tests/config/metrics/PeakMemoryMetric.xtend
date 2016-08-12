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
package com.incquerylabs.examples.cps.performance.tests.config.metrics

import eu.mondo.sam.core.metrics.BenchmarkMetric
import java.lang.management.ManagementFactory
import java.lang.management.MemoryMXBean
import java.lang.management.MemoryPoolMXBean
import java.util.List
import java.lang.management.MemoryType

class PeakMemoryMetric extends BenchmarkMetric {

	protected long peakMemory
	protected final MemoryMXBean mxBean;
	protected final List<MemoryPoolMXBean> memoryPools;
	
	new(String name) {
		super(name)
		mxBean = ManagementFactory.memoryMXBean
		memoryPools = ManagementFactory.memoryPoolMXBeans
	}
	
	override getValue() {
		return Long.toString(peakMemory);
	}
	
	def reset() {
		memoryPools.forEach[
			if(type == MemoryType.HEAP){
				resetPeakUsage
			}
		]
	}
	
	def measure() {
		peakMemory = 0
		memoryPools.forEach[
			if(type == MemoryType.HEAP){
				peakMemory += peakUsage.used
			}
		]
	}
	
}