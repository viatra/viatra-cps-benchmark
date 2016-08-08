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
package com.incquerylabs.examples.cps.performance.tests.config.phases

import com.incquerylabs.examples.cps.performance.tests.config.phases.CPSBenchmarkPhase
import com.incquerylabs.examples.cps.performance.tests.config.CPSDataToken
import eu.mondo.sam.core.metrics.TimeMetric
import eu.mondo.sam.core.metrics.MemoryMetric

class QueryPhase extends CPSBenchmarkPhase {
	
	new(String phaseName) {
		super(phaseName, true)
	}
	
	override execute(CPSDataToken cpsToken, TimeMetric timer, MemoryMetric memory) {
		timer.startMeasure
		
		cpsToken.xform.executeTransformation
		
		timer.stopMeasure
		memory.measure
		return emptySet
	}
	
}