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
import com.google.common.collect.Maps
import java.util.Random
import org.apache.log4j.Logger
import org.eclipse.viatra.examples.cps.generator.dtos.AppClass
import org.eclipse.viatra.examples.cps.generator.dtos.BuildableCPSConstraint
import org.eclipse.viatra.examples.cps.generator.dtos.HostClass
import org.eclipse.viatra.examples.cps.generator.dtos.MinMaxData
import org.eclipse.viatra.examples.cps.generator.dtos.Percentage
import org.eclipse.viatra.examples.cps.generator.utils.RandomUtils
import com.incquerylabs.examples.cps.performance.tests.config.phases.ClientServerModificationPhase
import com.incquerylabs.examples.cps.performance.tests.config.phases.GenerationPhase

class AdvancedClientServerCase extends BenchmarkCase {
	protected extension Logger logger = Logger.getLogger("cps.performance.tests.config.cases.AdvancedClientServerCase")
	protected extension RandomUtils randUtil = new RandomUtils
	
	int C;
	
	double Ssig = 0.1; // Scattering of Signals
	
	Iterable<HostClass> hostClasses = ImmutableList.of()
	HostClass serverHostClass
	HostClass clientHostClass
	
	new(int scale, Random rand) {
		super(scale, rand)
	}
	
	override getGenerationPhase(String phaseName) {
		return new GenerationPhase(phaseName, constraints)
	}
	
	override getModificationPhase(String phaseName) {
		return new ClientServerModificationPhase(phaseName)
	}
	
	def getConstraints() {
		C = Math.ceil(Math.sqrt(scale*1000)) as int; // xxx
		
		info("--> Element count = " + scale);
		info("--> C = " + C);
		
		this.hostClasses = createHostClassList()
		
		val min = Math.ceil(C*(5-Ssig)) as int;
		val max = Math.ceil(C*(5+Ssig)) as int;
		
		info('''--> Signal min: «min», max: «max»''');
		val BuildableCPSConstraint cons = new BuildableCPSConstraint(
			"Advanced Client-Server Case",
			new MinMaxData<Integer>(min, max), // Signals
			createAppClassList(),
			this.hostClasses	
		);
		
		return cons;
	}
	
	def Iterable<HostClass> createHostClassList() {
		val hostClasses = Lists.<HostClass>newArrayList;
		
		val hostClassCount = new MinMaxData<Integer>(2, 2).randInt(rand);
		info("--> HostClass count = " + hostClassCount);
		
		val typCount = 1 + C/2;
		info("--> HostType count = " + typCount);
		val serverHostTypeCount = (typCount*0.2) as int
		info("-->    Server HostType count = " + serverHostTypeCount);
		val clientHostTypeCount = (typCount*0.8) as int
		info("-->    Client HostType count = " + clientHostTypeCount);
		
		
		val instCount = C * 4
		info("--> HostInstance count = " + instCount);
		val serverHostInstanceCount = (instCount*0.3 / serverHostTypeCount) as int
		info("-->    Server HostInstance count = " + serverHostInstanceCount);
		val clientHostInstanceCount = (instCount*0.7 / clientHostTypeCount) as int
		info("-->    Client HostInstance count = " + clientHostInstanceCount);
		
		val int comCount = (instCount*0.7 / typCount*0.82) as int;
		info("--> Server Host comm count = " + comCount);
		
		val serverCommRatio = <HostClass, Integer>newHashMap
		val clientCommRatio = <HostClass, Integer>newHashMap

		var serverTypeMin = serverHostTypeCount
		if(serverTypeMin < 1){
			serverTypeMin = 1
		}
		var serverInstMin = serverHostInstanceCount
		if(serverInstMin < 1){
			serverInstMin = 1
		}
		this.serverHostClass = new HostClass(
			"server", // name
			new MinMaxData<Integer>(serverTypeMin, serverTypeMin), // Type
			new MinMaxData<Integer>(serverInstMin, serverInstMin), //Instance
			new MinMaxData<Integer>(comCount/2, comCount), //ComLines
			Maps.newHashMap(serverCommRatio)
		)
		
		
		var clientTypeMin = clientHostTypeCount
		if(serverTypeMin < 1){
			serverTypeMin = 1
		}
		var clientInstMin = clientHostInstanceCount
		if(serverInstMin < 1){
			serverInstMin = 1
		}
		this.clientHostClass = new HostClass(
			"client", // name
			new MinMaxData<Integer>(clientTypeMin, clientTypeMin), // Type
			new MinMaxData<Integer>(clientInstMin, clientInstMin), //Instance
			new MinMaxData<Integer>(0, 0), //ComLines
			Maps.newHashMap(clientCommRatio)
		)
		
		serverCommRatio.put(clientHostClass, 1)
		hostClasses.add(serverHostClass)
		hostClasses.add(clientHostClass)
		
		return hostClasses;
	}
	
	private def Iterable<AppClass> createAppClassList() {
		val appClasses = Lists.<AppClass>newArrayList;
		
		val appClassCount = new MinMaxData<Integer>(2, 2).randInt(rand);
		info("--> AppClass count = " + appClassCount);
		
		val appTypeCount = new MinMaxData<Integer>(appClassCount, C + appClassCount).randInt(rand);
		info("--> AppClass type = " + appTypeCount);
		info("-->    Server AppClass type = " + (appTypeCount * 0.3) as int);
		info("-->    Client AppClass type = " + (appTypeCount * 0.7) as int);
		
		val appInstanceCount = new MinMaxData<Integer>(appClassCount, C + appClassCount).randInt(rand);
		info("--> appInstanceCount = " + appInstanceCount);
		info("-->    Server AppClass type = " + (appInstanceCount * 0.25) as int);
		info("-->    Client AppClass type = " + (appInstanceCount * 0.75) as int);
		
		
		// Server Apps
		var serverAllocRatios = <HostClass, Integer>newHashMap();
		// alloc ratios
		serverAllocRatios.put(serverHostClass, 1);
		
		val serverAppClass = new AppClass(
			"ServerAppClass",
			new MinMaxData<Integer>((appTypeCount * 0.3) as int, (appTypeCount * 0.3) as int), // AppTypes
			new MinMaxData<Integer>((appInstanceCount * 0.22) as int, (appInstanceCount * 0.27) as int), // AppInstances
			new MinMaxData<Integer>(C, C), // States
			new MinMaxData<Integer>(C/2, C/2), // Transitions
			new Percentage(100), // AllocInst
			serverAllocRatios,
			new Percentage(30), // Action %
			new Percentage(100) // Send %
		)
		appClasses += serverAppClass
		
		
		// Client
		var clientAllocRatios = <HostClass, Integer>newHashMap();
		// alloc ratios
		clientAllocRatios.put(clientHostClass, 1)
		
		val clientAppClass = new AppClass(
			"ClientAppClass",
			new MinMaxData((appTypeCount * 0.7) as int, (appTypeCount * 0.7) as int), // AppTypes
			new MinMaxData((appInstanceCount * 0.72) as int, (appInstanceCount * 0.77) as int), // AppInstances
			new MinMaxData(5, 10), // States
			new MinMaxData(3, 8), // Transitions
			new Percentage(100), // AllocInst
			clientAllocRatios,
			new Percentage(5), // Action %
			new Percentage(0) // Send %
		)
		appClasses += clientAppClass
		
		return appClasses;
	}
	
}