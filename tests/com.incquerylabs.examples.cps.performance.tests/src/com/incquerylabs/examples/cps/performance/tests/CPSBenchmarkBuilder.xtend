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
package com.incquerylabs.examples.cps.performance.tests

import com.incquerylabs.examples.cps.performance.tests.config.GeneratorType
import eu.mondo.sam.core.scenarios.BenchmarkScenario
import org.eclipse.viatra.examples.cps.xform.m2m.tests.wrappers.TransformationType
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class CPSBenchmarkBuilder {
	
	var int scale
	var BenchmarkScenario scenario
	var GeneratorType generatorType
	var TransformationType wrapperType
	
	def static create() {
		return new CPSBenchmarkBuilder
	}
	
	def build() {
		val benchmark = new ScenarioBenchmarkingBase() => [
			wrapperType = getWrapperType
			generatorType = getGeneratorType
			scale = getScale
			scenario = getScenario
			xform = wrapperType.wrapper
		]
		return benchmark
	}
}