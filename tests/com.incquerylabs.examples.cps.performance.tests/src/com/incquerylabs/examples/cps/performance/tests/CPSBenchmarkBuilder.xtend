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
import com.incquerylabs.examples.cps.performance.tests.queries.CPSQueryWrapper

@Accessors
class CPSBenchmarkBuilder {
	
	var int scale
	var BenchmarkScenario scenario
	var GeneratorType generatorType
	var TransformationType wrapperType
	var CPSQueryWrapper queryWrapper
	
	def static create() {
		return new CPSBenchmarkBuilder
	}
	
	def build() {
		val benchmark = new ScenarioBenchmarkingBase() => [
			token.transformationType = getWrapperType
			token.generatorType = getGeneratorType
			token.scale = getScale
			token.xform = wrapperType?.wrapper
			token.query = queryWrapper
			scenario = getScenario
			token.toolName = scenario.tool
			token.scenarioName = scenario.class.simpleName
		]
		return benchmark
	}
}