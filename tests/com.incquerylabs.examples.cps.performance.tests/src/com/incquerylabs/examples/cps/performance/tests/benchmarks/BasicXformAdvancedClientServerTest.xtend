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

package com.incquerylabs.examples.cps.performance.tests.benchmarks

import java.util.Random
import com.incquerylabs.examples.cps.performance.tests.config.GeneratorType
import com.incquerylabs.examples.cps.performance.tests.config.cases.AdvancedClientServerCase
import org.eclipse.viatra.examples.cps.xform.m2m.launcher.TransformationType

class BasicXformAdvancedClientServerTest extends com.incquerylabs.examples.cps.performance.tests.BasicXformTest {
	
	new(TransformationType wrapperType, int scale, GeneratorType generatorType, int runIndex) {
		super(wrapperType, scale, generatorType, runIndex)
	}
	
	override getCase(int scale, Random rand) {
		return new AdvancedClientServerCase(scale, rand)
	}
	
}
