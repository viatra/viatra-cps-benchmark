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
import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.Random
import org.apache.log4j.Logger
import org.eclipse.viatra.examples.cps.generator.dtos.AppClass
import org.eclipse.viatra.examples.cps.generator.dtos.BuildableCPSConstraint
import org.eclipse.viatra.examples.cps.generator.dtos.HostClass
import org.eclipse.viatra.examples.cps.generator.dtos.MinMaxData
import org.eclipse.viatra.examples.cps.generator.dtos.Percentage
import com.incquerylabs.examples.cps.performance.tests.config.phases.StatisticsBasedGenerationPhase
import com.incquerylabs.examples.cps.performance.tests.config.phases.StatisticsBasedModificationPhase

class StatisticBasedCase extends BenchmarkCase {
	protected extension Logger logger = Logger.getLogger("cps.performance.tests.config.cases.StatisticsBasedCase")
	
	Iterable<HostClass> hostClasses = ImmutableList.of();
	
	new(int scale, Random rand){
		super(scale, rand)
	}
	
	override getGenerationPhase(String phaseName) {
		return new StatisticsBasedGenerationPhase(phaseName, constraints)
	}
	
	override getModificationPhase(String phaseName) {
		return new StatisticsBasedModificationPhase(phaseName)
	}
	
	
	def getConstraints() {
		info("--> Scale = " + scale);

		this.hostClasses = createHostClassList()

		val signalCount = 143
		val BuildableCPSConstraint cons = new BuildableCPSConstraint(
			"Statistics-based Case",
			new MinMaxData<Integer>(signalCount, signalCount), // Sig
			createAppClassList(),
			this.hostClasses
		);

		return cons;
	}
	
	private def Iterable<HostClass> createHostClassList() {
		val hostClasses = Lists.<HostClass>newArrayList;
		
		// 1 for the empty, and scale for the host instances with allocated application instances
		val hostClassCount = 1 + scale;
		info("--> HostClass count = " + hostClassCount);

		val typCount = hostClassCount;
		info("--> HostType count = " + typCount);

		val instEmptyCount = scale * 22;
		val instAppContainerCount = scale * 4;
		val instHostCount = instEmptyCount + instAppContainerCount
		info("--> HostInstance count = " + instHostCount)
		val comCount = instAppContainerCount - 1;

		// TODO should we randomize the number of host communication for the hosts without allocated applications
		val emptyHostCommunicationCount = scale * 2
		val allComCount = comCount + emptyHostCommunicationCount
		info("--> Host comm count = " + allComCount)
		
		
		val emptyHostConnection = new HashMap
		val emptyHostClass = new HostClass(
			"HC_empty", // name
			new MinMaxData(1, 1), // Type
			new MinMaxData(instEmptyCount, instEmptyCount), //Instance
			new MinMaxData(emptyHostCommunicationCount, emptyHostCommunicationCount), //ComLines
			emptyHostConnection
		)
		hostClasses.add(emptyHostClass)

		val appContainerClasses = Lists.newArrayList
		for (i : 0 ..< scale) {

			// The application container host instances of the same type will form a complete graph of 4
			// when only taking the communicatesWith relation
			val appContainerConnection = new HashMap
			val appContainerHostClass = new HostClass(
				"HC_appContainer" + i, // name
				new MinMaxData(1, 1), // Type
				new MinMaxData(instAppContainerCount, instAppContainerCount), //Instance
				new MinMaxData(comCount, comCount), //ComLines
				appContainerConnection
			)
			appContainerConnection.put(appContainerHostClass, 1)

			hostClasses.add(appContainerHostClass)
			appContainerClasses.add(appContainerHostClass)
		}

		// Communications:
		// App containers only communicate with each other, the empty hosts might communicate with any instance		
		emptyHostConnection.put(emptyHostClass, 1)
		for (appContainerClass : appContainerClasses) {
			emptyHostConnection.put(appContainerClass, 1)
		}

		return hostClasses;
	}

	private def Iterable<AppClass> createAppClassList() {
		val appClasses = Lists.<AppClass>newArrayList;

		val expectedValueOfTypes = scale * 52

		// Every class will have 1 or 2 types, so that the expected value of the appTypes will be the expectedValueOfTypes using the formula below
		val int appClassCount = 2 * expectedValueOfTypes / 3
		
		info("--> AppClass count = " + appClassCount);

		// alloc ratios - allocate only to the second host type
		var Map<HostClass, Integer> allocRatios = new HashMap();
		val hostClassesList = this.hostClasses as List<HostClass>
		val emptyHostClass = hostClassesList.get(0)

		// The first in the list is the empty host class, the instances of the others should contain app instances
		for (hostClass : this.hostClasses) {
			if (hostClass.equals(emptyHostClass)) {
				allocRatios.put(hostClass, 0);
			} else {
				allocRatios.put(hostClass, 1);
			}
		}

		
		val appTypeMinCount = 1
		val appTypeMaxCount = 2

		// Each app type will have 1 instance to have an assignment between AppType and HostInstance
		val appInstCount = 1

		// Half of the app types will not have state machine, the other half will have 
		for(i : 0 ..< appClassCount/2){
			appClasses.add(
				new AppClass(
					"AC_withoutStateMachine" + i,
					new MinMaxData(appTypeMinCount, appTypeMaxCount), // AppTypes
					new MinMaxData(appInstCount, appInstCount), // AppInstances
					new MinMaxData(0, 0), // States
					new MinMaxData(0, 0), // Transitions
					new Percentage(100), // Alloc 
					allocRatios,
					new Percentage(0), // Action
					new Percentage(0) // Send
				)
			);
		}
		for(i : 0 ..< appClassCount/2){			
			appClasses.add(
				new AppClass(
					"AC_withStateMachine" + i,
					new MinMaxData(appTypeMinCount, appTypeMaxCount), // AppTypes
					new MinMaxData(appInstCount, appInstCount), // AppInstances
					new MinMaxData(3, 3), // States
					new MinMaxData(7, 8), // Transitions
					new Percentage(100), // Alloc 
					allocRatios,
					new Percentage(50), // Action
					new Percentage(50) // Send
				)
			);
		}

		return appClasses;
	}
}