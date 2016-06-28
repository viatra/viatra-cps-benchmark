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
import org.eclipse.viatra.examples.cps.xform.m2t.monitor.DeploymentChangeMonitor
import org.eclipse.viatra.query.runtime.api.AdvancedViatraQueryEngine
import org.eclipse.viatra.query.runtime.emf.EMFScope
import eu.mondo.sam.core.metrics.TimeMetric
import eu.mondo.sam.core.metrics.MemoryMetric

class ChangeMonitorInitializationPhase extends CPSBenchmarkPhase {
	
	new(String phaseName) {
		super(phaseName, true)
	}
	
	override execute(CPSDataToken cpsToken, TimeMetric timer, MemoryMetric memory) {
		timer.startMeasure
		
		val engine = AdvancedViatraQueryEngine.createUnmanagedEngine(new EMFScope(cpsToken.cps2dep.deployment))
		val changeMonitor = new DeploymentChangeMonitor(cpsToken.cps2dep.deployment, engine)
		cpsToken.changeMonitor = changeMonitor
		changeMonitor.startMonitoring
		
		timer.stopMeasure
		memory.measure
		return emptySet
	}
	
}