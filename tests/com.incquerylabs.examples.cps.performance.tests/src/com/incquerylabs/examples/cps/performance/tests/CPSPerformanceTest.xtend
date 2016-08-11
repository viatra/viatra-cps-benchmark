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

package com.incquerylabs.examples.cps.performance.tests

import com.incquerylabs.examples.cps.performance.tests.config.GeneratorType
import eu.mondo.sam.core.scenarios.BenchmarkScenario
import java.util.Random
import org.eclipse.viatra.examples.cps.xform.m2m.tests.wrappers.TransformationType
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized

@RunWith(Parameterized)
abstract class CPSPerformanceTest extends ScenarioBenchmarkingBase {
	
    new(TransformationType wrapperType,	int scale, GeneratorType generatorType, int runIndex) {
		this.token.transformationType = wrapperType
		this.token.scale = scale 
		this.token.generatorType = generatorType
		this.token.xform = wrapperType.wrapper
    	this.scenario = getScenario(scale, rand)
		this.scenario.runIndex = runIndex
		this.scenario.tool = wrapperType.name + "-" + generatorType.name
    }
    
	@Test
	def void completeToolchainIntegrationTest() {
		val jsonResultFolder="./results/json/"
		completeToolchainIntegrationTest(jsonResultFolder)
	}
	
	def BenchmarkScenario getScenario(int scale, Random rand)
}