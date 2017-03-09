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
import eu.mondo.sam.core.metrics.MemoryMetric
import eu.mondo.sam.core.metrics.TimeMetric
import org.eclipse.viatra.examples.cps.generator.utils.CPSModelBuilderUtil

class AddAppInstanceModificationPhase extends CPSBenchmarkPhase {
	
	extension CPSModelBuilderUtil modelBuilder
    
    String appTypeIdFilter
    String hostInstanceNameFilter
	
	new(String name, String appTypeIdFilter, String hostInstanceNameFilter) {
		super(name, true)
		modelBuilder = new CPSModelBuilderUtil
		this.appTypeIdFilter = appTypeIdFilter
		this.hostInstanceNameFilter = hostInstanceNameFilter
	}
	
	override execute(CPSDataToken cpsToken, TimeMetric timer, MemoryMetric memory) {
		
		timer.startMeasure
		
		val appType = cpsToken.cps2dep.cps.appTypes.findFirst[it.identifier.contains(appTypeIdFilter)]
		val hostInstance = cpsToken.cps2dep.cps.hostTypes.findFirst[it.identifier.contains(hostInstanceNameFilter)].instances.head
		val appID = "new.app.instance" + cpsToken.nextModificationIndex 
		appType.prepareApplicationInstanceWithId(appID, hostInstance)
		
		timer.stopMeasure
		memory.measure
		return emptySet
	}
	
}