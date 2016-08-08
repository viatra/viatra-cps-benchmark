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

package com.incquerylabs.examples.cps.performance.tests.config.scenarios

import eu.mondo.sam.core.results.CaseDescriptor
import eu.mondo.sam.core.scenarios.BenchmarkScenario
import com.incquerylabs.examples.cps.performance.tests.config.cases.BenchmarkCase

abstract class CPSBenchmarkScenario extends BenchmarkScenario {
	protected BenchmarkCase benchmarkCase;
	
	new(BenchmarkCase benchmarkCase) {
		this.benchmarkCase = benchmarkCase
		this.size = benchmarkCase.scale
		this.caseName = benchmarkCase.class.simpleName
		this.runIndex = 1
	}
	
	override getCaseDescriptor() {
		val descriptor = new CaseDescriptor
		descriptor.tool = this.tool
		descriptor.caseName = this.caseName
		descriptor.size = this.size
		descriptor.runIndex = this.runIndex
		descriptor.scenario = this.name
		return descriptor
	}
	
	def String getName()
}