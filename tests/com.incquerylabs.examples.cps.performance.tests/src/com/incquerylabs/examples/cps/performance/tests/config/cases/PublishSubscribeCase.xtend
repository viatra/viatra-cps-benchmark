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
import com.incquerylabs.examples.cps.performance.tests.config.phases.EmptyPhase
import com.incquerylabs.examples.cps.performance.tests.config.phases.GenerationPhase

class PublishSubscribeCase extends BenchmarkCase {
	protected extension Logger logger = Logger.getLogger("cps.performance.tests.config.cases.PublishSubscribeCase")
	protected extension RandomUtils randUtil = new RandomUtils
	
	
	Iterable<HostClass> hostClasses = ImmutableList.of()
	HostClass serverHostClass
	HostClass clientHostClass
	
	new(int scale, Random rand) {
		super(scale, rand)
	}
	
	override getGenerationPhase(String name) {
		return new GenerationPhase(name, constraints)
	}
	
	override getModificationPhase(String name) {
		return new EmptyPhase(name)
	}
	
	def getConstraints() {
		info("--> Scale = " + scale);
		
		this.hostClasses = createHostClassList()

		val BuildableCPSConstraint cons = new BuildableCPSConstraint(
			"Publish-Subscribe Case",
			new MinMaxData<Integer>(1, 1), // Signals
			createAppClassList(),
			this.hostClasses	
		);
		
		return cons;
	}
	
	def Iterable<HostClass> createHostClassList() {
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
		
		// Client
		var clientTypeMin = clientHostTypeCount
		if(clientTypeMin < 1){
			clientTypeMin = 1
		}
		var clientInstMin = clientHostInstanceCount
		if(clientInstMin < 1){
			clientInstMin = 1
		}
		this.clientHostClass = new HostClass(
			"client", // name
			new MinMaxData<Integer>(clientTypeMin, clientTypeMin), // Type
			new MinMaxData<Integer>(clientInstMin, clientInstMin), //Instance
			new MinMaxData<Integer>(0, 0), //ComLines
			Maps.newHashMap(clientCommRatio)
		)
		
		// Server
		serverCommRatio.put(clientHostClass, 1)
		
		this.serverHostClass = new HostClass(
			"server", // name
			new MinMaxData<Integer>(serverHostTypeCount, serverHostTypeCount), // Type
			new MinMaxData<Integer>(serverHostInstanceCount, serverHostInstanceCount), //Instance
			new MinMaxData<Integer>(comCount, comCount), //ComLines
			Maps.newHashMap(serverCommRatio)
		)
		
		hostClasses.add(serverHostClass)
		hostClasses.add(clientHostClass)
		
		return hostClasses;
	}
	
	private def Iterable<AppClass> createAppClassList() {
		val appClasses = Lists.<AppClass>newArrayList;
		
		val appClassCount = new MinMaxData<Integer>(2, 2).randInt(rand);
		info("--> AppClass count = " + appClassCount);
		
//		val appTypeCount = new MinMaxData<Integer>(C/3 + appClassCount, C/3 + appClassCount).randInt(rand);
//		info("--> AppType count = " + appTypeCount);
		val serverAppTypeCount = 1
		info("-->    Server AppType = " + serverAppTypeCount);
		val clientAppTypeCount = 10 * scale // appTypeCount - serverAppTypeCount
		info("-->    Client AppType = " + clientAppTypeCount);
		
//		val appInstanceCount = new MinMaxData<Integer>(appClassCount, C + appClassCount).randInt(rand);
//		info("--> AppInstanceCount = " + appInstanceCount);
		val serverAppInstanceCount = 1
		info("-->    Server AppInstance = " + serverAppInstanceCount);
		val clientAppInstanceCount = 1 // Math.ceil((appInstanceCount - serverAppInstanceCount) / clientAppTypeCount) as int
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
			new Percentage(80), // Action %
			new Percentage(100) // Send %
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
			new Percentage(0) // Send %
		)
		appClasses += clientAppClass
		
		return appClasses;
	}
	
}