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

class EmptyPhase extends CPSBenchmarkPhase {

	new(String phaseName) {
		super("Empty" + phaseName, false)
	}
	
	override execute(CPSDataToken cpsToken, TimeMetric timer, MemoryMetric memory) {
		timer.startMeasure
		timer.stopMeasure
		return emptySet
	}

}