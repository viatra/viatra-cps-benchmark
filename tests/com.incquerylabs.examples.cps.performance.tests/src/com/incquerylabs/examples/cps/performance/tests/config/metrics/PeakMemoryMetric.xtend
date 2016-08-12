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