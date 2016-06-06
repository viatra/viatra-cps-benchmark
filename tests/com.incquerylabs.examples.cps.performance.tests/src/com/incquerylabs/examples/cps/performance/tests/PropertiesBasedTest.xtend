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

import com.google.common.collect.ImmutableSet
import com.google.common.collect.Sets
import com.incquerylabs.examples.cps.performance.tests.config.GeneratorType
import org.eclipse.viatra.examples.cps.tests.util.PropertiesUtil
import org.eclipse.viatra.examples.cps.xform.m2m.tests.wrappers.TransformationType
import org.junit.runners.Parameterized.Parameters

abstract class PropertiesBasedTest extends CPSPerformanceTest {
	
	@Parameters(name = "{index}: xform: {0}, code generator: {2}, scale: {1}")
    public static def xformSizeGenerator() {
		val data = Sets::cartesianProduct(xforms,codegens)
       	data.map[ d |
	        scales.map[ scale |
        		#[d.get(0), scale, d.get(1), 1]
        	]
        ].flatten.map[it.toArray].toList
    }
	
	new(TransformationType wrapperType, int scale, GeneratorType generatorType, int runIndex) {
		super(wrapperType, scale, generatorType, runIndex)
	}
	
	new(TransformationType wrapperType,	int scale, GeneratorType generatorType) {
    	this(wrapperType, scale, generatorType,1)
	}
	
	static def getXforms() {
		val xformsBuilder = ImmutableSet.builder
		TransformationType.values.forEach[xformsBuilder.add(it)]
        val allXforms = xformsBuilder.build
		val disabledXforms = PropertiesUtil.disabledM2MTransformations
		
		return allXforms.filter[!disabledXforms.contains(it.name)].toSet
	}
	
	static def getCodegens() {
		val codegensBuilder = ImmutableSet.builder
		GeneratorType.values.forEach[codegensBuilder.add(it)]
		val allCodeGens = codegensBuilder.build
		val disabledCodegens = PropertiesUtil.disabledGeneratorTypes
		
		return allCodeGens.filter[!disabledCodegens.contains(it.name)].toSet
	}
	
	static def getScales() {
		return PropertiesUtil.enabledScales.map[Integer.valueOf(it)]
	}
}