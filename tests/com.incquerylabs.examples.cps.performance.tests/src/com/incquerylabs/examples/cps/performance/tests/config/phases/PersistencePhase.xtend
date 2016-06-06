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
import eu.mondo.sam.core.phases.OptionalPhase
import eu.mondo.sam.core.results.PhaseResult
import com.incquerylabs.examples.cps.performance.tests.config.CPSDataToken
import org.eclipse.viatra.examples.cps.tests.util.PropertiesUtil

class PersistencePhase extends OptionalPhase{
	
	new(){
		phase = new PersistenceAtomicPhase("Persistence")
	}
	
	override condition() {
		PropertiesUtil.persistResults
	}
}


class PersistenceAtomicPhase extends AtomicPhase{
	
	new(String name) {
		super(name)
	}
	
	override execute(DataToken token, PhaseResult phaseResult) {
		val cpsToken = token as CPSDataToken
		val persistenceTimer = new TimeMetric("Time")
		val persistenceMemory = new MemoryMetric("Memory")
		
		persistenceTimer.startMeasure
		cpsToken.cps2dep.eResource.resourceSet.resources.forEach[save(null)]
		persistenceTimer.stopMeasure
		persistenceMemory.measure
		phaseResult.addMetrics(persistenceTimer, persistenceMemory)
	}
	
	
}