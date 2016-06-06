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
import eu.mondo.sam.core.results.PhaseResult
import com.incquerylabs.examples.cps.performance.tests.config.CPSDataToken
import org.eclipse.viatra.examples.cps.xform.m2t.monitor.DeploymentChangeMonitor
import org.eclipse.viatra.query.runtime.api.AdvancedViatraQueryEngine
import org.eclipse.viatra.query.runtime.emf.EMFScope

class ChangeMonitorInitializationPhase extends AtomicPhase {
	
	new(String phaseName) {
		super(phaseName)
	}
	
	override execute(DataToken token, PhaseResult phaseResult) {
		val cpsToken = token as CPSDataToken
		val changeMonitorInitTimer = new TimeMetric("Time")
		val changeMonitorInitMemory = new MemoryMetric("Memory")
		
		changeMonitorInitTimer.startMeasure
		val engine = AdvancedViatraQueryEngine.createUnmanagedEngine(new EMFScope(cpsToken.cps2dep.deployment))
		val changeMonitor = new DeploymentChangeMonitor(cpsToken.cps2dep.deployment, engine)
		cpsToken.changeMonitor = changeMonitor
		changeMonitor.startMonitoring
		changeMonitorInitTimer.stopMeasure
		changeMonitorInitMemory.measure
		phaseResult.addMetrics(changeMonitorInitTimer, changeMonitorInitMemory)
	}
	
}