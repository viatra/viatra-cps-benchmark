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

class ClientServerCase extends BenchmarkCase{
	protected extension Logger logger = Logger.getLogger("cps.performance.tests.config.cases.ClientServerCase")
	protected extension RandomUtils randUtil = new RandomUtils
	
	
	Iterable<HostClass> hostClasses = ImmutableList.of()
	HostClass serverHostClass
	HostClass clientHostClass
	
	
	new(int scale, Random rand){
		super(scale, rand)
	}
	
	override getGenerationPhase(String phaseName) {
		return new GenerationPhase(phaseName, constraints)
	}
	
	override getModificationPhase(String phaseName) {
		return new ClientServerModificationPhase(phaseName)
	}
	
	def getConstraints() {
		info("--> Scale = " + scale);
		
		this.hostClasses = createHostClassList(scale);

		val BuildableCPSConstraint cons = new BuildableCPSConstraint(
			"Client-Server Case",
			new MinMaxData<Integer>(1, 1), // Signals
			createAppClassList(scale),
			this.hostClasses	
		);
		
		return cons;
	}
	
	private def Iterable<HostClass> createHostClassList(int scale) {
		val hostClasses = Lists.<HostClass>newArrayList;
		
		val hostClassCount = new MinMaxData<Integer>(2, 2).randInt(rand);
		info("--> HostClass count = " + hostClassCount);
		
//		val typCount = 2;
//		info("--> HostType count = " + typCount);
		val serverHostTypeCount = 1
		info("-->    Server HostType count = " + serverHostTypeCount);
		val clientHostTypeCount = 1 //typCount - serverHostTypeCount
		info("-->    Client HostType count = " + clientHostTypeCount);
		
		
//		val instCount = C * 4
//		info("--> HostInstance count = " + instCount);
		val serverHostInstanceCount = 1
		info("-->    Server HostInstance count = " + serverHostInstanceCount);
		val clientHostInstanceCount = 10 * Math.sqrt(scale) as int // (instCount-serverHostInstanceCount) / clientHostTypeCount
		info("-->    Client HostInstance count = " + clientHostInstanceCount);
		
		val int comCount = clientHostInstanceCount //instCount
		info("--> Server Host comm count = " + comCount);
		
		val serverCommRatio = <HostClass, Integer>newHashMap
		val clientCommRatio = <HostClass, Integer>newHashMap
		
		
		this.serverHostClass = new HostClass(
			"server", // name
			new MinMaxData<Integer>(serverHostTypeCount, serverHostTypeCount), // Type
			new MinMaxData<Integer>(serverHostInstanceCount, serverHostInstanceCount), //Instance
			new MinMaxData<Integer>(0, 0), //ComLines
			serverCommRatio
		)
		
		// Client
		var clientTypeMin = clientHostTypeCount
		if(clientTypeMin < 1){
			clientTypeMin = 1
		}
		var clientInstMin = clientHostInstanceCount
		if(clientInstMin < 1){
			clientInstMin = 1
		}
		clientCommRatio.put(serverHostClass, 1)
		this.clientHostClass = new HostClass(
			"client", // name
			new MinMaxData<Integer>(clientTypeMin, clientTypeMin), // Type
			new MinMaxData<Integer>(clientInstMin, clientInstMin), //Instance
			new MinMaxData<Integer>(comCount, comCount), //ComLines
			clientCommRatio
		)
		
		// Server
		
		hostClasses.add(serverHostClass)
		hostClasses.add(clientHostClass)
		
		return hostClasses;
	}
	
	private def Iterable<AppClass> createAppClassList(int scale) {
		val appClasses = Lists.<AppClass>newArrayList;
		
		val appClassCount = new MinMaxData<Integer>(2, 2).randInt(rand);
		info("--> AppClass count = " + appClassCount);
		
		val serverAppTypeCount = 1
		info("-->    Server AppType = " + serverAppTypeCount);
		val clientAppTypeCount = 10 * scale 
		info("-->    Client AppType = " + clientAppTypeCount);

		val serverAppInstanceCount = 1
		info("-->    Server AppInstance = " + serverAppInstanceCount);
		val clientAppInstanceCount = 1
		info("-->    Client AppInstance = " + clientAppInstanceCount);
		
		
		// Server Apps
		var serverAllocRatios = <HostClass, Integer>newHashMap();
		// alloc ratios
		serverAllocRatios.put(serverHostClass, 1);
		
		val serverAppClass = new AppClass(
			"ServerAppClass",
			new MinMaxData<Integer>(serverAppTypeCount, serverAppTypeCount), // AppTypes
			new MinMaxData<Integer>(serverAppInstanceCount, serverAppInstanceCount), // AppInstances
			new MinMaxData<Integer>(30, 30), // States
			new MinMaxData<Integer>(40, 40), // Transitions
			new Percentage(100), // AllocInst
			serverAllocRatios,
			new Percentage(30), // Action %
			new Percentage(0) // Send %
		)
		appClasses += serverAppClass
		
		
		// Client
		var clientAllocRatios = <HostClass, Integer>newHashMap();
		// alloc ratios
		clientAllocRatios.put(clientHostClass, 1)
		
		val clientAppClass = new AppClass(
			"ClientAppClass",
			new MinMaxData(clientAppTypeCount, clientAppTypeCount), // AppTypes
			new MinMaxData(clientAppInstanceCount, clientAppInstanceCount), // AppInstances
			new MinMaxData(3, 3), // States
			new MinMaxData(5, 5), // Transitions
			new Percentage(100), // AllocInst
			clientAllocRatios,
			new Percentage(30), // Action %
			new Percentage(100) // Send %
		)
		appClasses += clientAppClass
		
		return appClasses;
	}
	
}