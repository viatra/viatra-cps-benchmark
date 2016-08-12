package com.incquerylabs.examples.cps.performance.tests.config.phases

import com.incquerylabs.examples.cps.performance.tests.config.CPSDataToken
import eu.mondo.sam.core.DataToken
import eu.mondo.sam.core.metrics.MemoryMetric
import eu.mondo.sam.core.metrics.TimeMetric
import eu.mondo.sam.core.phases.AtomicPhase
import eu.mondo.sam.core.results.PhaseResult
import java.util.Set
import eu.mondo.sam.core.metrics.BenchmarkMetric

abstract class CPSBenchmarkPhase extends AtomicPhase {
	
	boolean memoryMeasuredInPhase
	// 1 second
	protected static val int AVERAGE_MEMORY_INTERVAL = 1000 
	
	new(String phaseName, boolean measuresMemory) {
		super(phaseName)
		this.memoryMeasuredInPhase = measuresMemory
	}
	
	override execute(DataToken token, PhaseResult phaseResult) {
		val cpsToken = token as CPSDataToken
		cpsToken.logger.info('''«this.class.name» phase started''')

		val timer = new TimeMetric("Time")
		val memory = new MemoryMetric("Memory")
		
		val additionalMetrics = cpsToken.execute(timer, memory)
		
		val printMetrics = newArrayList
		if(timer.value != 0){
			phaseResult.addMetrics(timer)
			printMetrics.add('''Time: «timer.value» ns''')
		}
		if(memoryMeasuredInPhase){
			phaseResult.addMetrics(memory)
			printMetrics.add('''Memory: «memory.value» bytes''')
		}
		phaseResult.addMetrics(additionalMetrics)
		additionalMetrics.forEach[ metric |
			if(metric instanceof TimeMetric) {
				printMetrics.add('''«metric.metricName»: «metric.value» ns''')
			} else if(metric instanceof MemoryMetric) {
				printMetrics.add('''«metric.metricName»: «metric.value» bytes''')
			} else {
				printMetrics.add('''«metric.metricName»: «metric.value»''')
			}
		]
		cpsToken.logger.info('''
			«this.class.name» phase finished:
				«FOR m : printMetrics»
					«m»
				«ENDFOR»
		''')
	}
	
	/**
	 * Must measure memory if memoryMeasuredInPhase() returns true!
	 */
	def Set<BenchmarkMetric> execute(CPSDataToken cpsToken, TimeMetric timer, MemoryMetric memory)
}