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

class ClientServerModificationPhase extends CPSBenchmarkPhase{
	
	extension CPSModelBuilderUtil builderUtil
	
	new(String name) {
		super(name, false)
		builderUtil = new CPSModelBuilderUtil
	}
	
	override execute(CPSDataToken cpsToken, TimeMetric timer, MemoryMetric memory) {
		val editTimer = new TimeMetric("Edit Time")
		
//		info("Adding new host instance")
		timer.startMeasure
		
		val appType = cpsToken.cps2dep.cps.appTypes.findFirst[it.identifier.contains("Client")]
		val hostInstance = cpsToken.cps2dep.cps.hostTypes.findFirst[it.identifier.contains("client")].instances.head
		
		editTimer.startMeasure
		
		val appID = "new.app.instance" + cpsToken.nextModificationIndex 
		appType.prepareApplicationInstanceWithId(appID, hostInstance)
		
		editTimer.stopMeasure
		timer.stopMeasure
		return #{editTimer}
	}
	
}