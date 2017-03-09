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

package com.incquerylabs.examples.cps.performance.tests.config.cases

import com.google.common.collect.ImmutableList
import com.google.common.collect.Lists
import com.incquerylabs.examples.cps.performance.tests.config.phases.AddAppInstanceModificationPhase
import com.incquerylabs.examples.cps.performance.tests.config.phases.GenerationPhase
import java.util.HashMap
import java.util.Map
import java.util.Random
import org.apache.log4j.Logger
import org.eclipse.viatra.examples.cps.generator.dtos.AppClass
import org.eclipse.viatra.examples.cps.generator.dtos.BuildableCPSConstraint
import org.eclipse.viatra.examples.cps.generator.dtos.HostClass
import org.eclipse.viatra.examples.cps.generator.dtos.MinMaxData
import org.eclipse.viatra.examples.cps.generator.dtos.Percentage
import org.eclipse.viatra.examples.cps.generator.utils.RandomUtils

class SimpleScalingCase extends BenchmarkCase {
	protected extension Logger logger = Logger.getLogger("cps.performance.tests.config.cases.SimpleScalingCase")
	protected extension RandomUtils randUtil = new RandomUtils
	
	
	Iterable<HostClass> hostClasses = ImmutableList.of()
	
	int C;
	
	double Ssig = 0.0; // Scattering of Signals
	double Shc = 0.0;
	double Sac = 0.0;
	
	new(int scale, Random rand) {
		super(scale, rand)
	}
	
	override getGenerationPhase(String phaseName) {
		return new GenerationPhase(phaseName, constraints)
	}
	
	override getModificationPhase(String phaseName) {
		return new AddAppInstanceModificationPhase(phaseName, "AC", "HC")
	}
	
	
	def getConstraints() {
		C = Math.ceil(Math.sqrt(scale)) as int; // xxx
		
		info("--> Element count = " + scale);
		info("--> C = " + C);
		
		this.hostClasses = createHostClassList()
		
		val min = Math.ceil((C/2+1)*(5-Ssig)) as int;
		val max = Math.ceil((C/2+1)*(5+Ssig)) as int;
		info('''--> Signal min: «min», max: «max»''');
		val BuildableCPSConstraint cons = new BuildableCPSConstraint(
			"Simple Scaling Case",
			new MinMaxData<Integer>(min, max), // Sig
			createAppClassList(),
			this.hostClasses	
		);
		
		return cons;
	}
	
	private def Iterable<HostClass> createHostClassList() {
		val hostClasses = Lists.<HostClass>newArrayList;
		
		val min = Math.ceil((C/5+1)*(2-Shc)) as int
		val max = Math.ceil((C/5+1)*(2+Shc)) as int
		val hostClassCount = new MinMaxData<Integer>(min, max).randInt(rand);
		info("--> HostClass count = " + hostClassCount);
		
		val typCount = hostClassCount;
		info("--> HostType count = " + typCount);
		val instCount = (hostClassCount * 10) as int;
		info("--> HostInstance count = " + instCount);
		val comCount = Math.ceil(typCount / 3 + 4) as int;
		info("--> Host comm count = " + comCount);
		
		for(i : 0 ..< hostClassCount){
			hostClasses.add(
				new HostClass(
					"HC"+i, // name
					new MinMaxData(typCount, typCount),// Type
					new MinMaxData(instCount, instCount), //Instance
					new MinMaxData(0, comCount), //ComLines
					new HashMap
				)
			);
		}
		
		return hostClasses;
	}
	
	private def Iterable<AppClass> createAppClassList() {
		val appClasses = Lists.<AppClass>newArrayList;
		
		val min = (C*(5-Sac)) as int
		val max = (C*(5+Sac)) as int
		val appClassCount = new MinMaxData<Integer>(min, max).randInt(rand);
		info("--> AppClass count = " + appClassCount);
		var Map<HostClass, Integer> allocRatios = new HashMap();
		
		// alloc ratios
		for(hc : this.hostClasses){
			allocRatios.put(hc, 1);
		}
		
		for(i : 0 ..< appClassCount){
			appClasses.add(
				new AppClass(
					"AC" + i + "-",
					new MinMaxData(appClassCount, appClassCount), // AppTypes
					new MinMaxData(5, 10), // AppInstances
					new MinMaxData(5, 7), // States
					new MinMaxData(7, 10), // Transitions
					new Percentage(30), // Alloc 
					allocRatios,
					new Percentage(30), // Action
					new Percentage(30) // Send
				)
			);
		}
		
		return appClasses;
	}
	
}