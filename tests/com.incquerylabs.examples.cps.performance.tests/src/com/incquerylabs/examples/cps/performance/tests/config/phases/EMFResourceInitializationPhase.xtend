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

package com.incquerylabs.examples.cps.performance.tests.config.phases

import com.incquerylabs.examples.cps.performance.tests.config.CPSDataToken
import eu.mondo.sam.core.metrics.MemoryMetric
import eu.mondo.sam.core.metrics.TimeMetric
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.CyberPhysicalSystemFactory
import org.eclipse.viatra.examples.cps.deployment.DeploymentFactory
import org.eclipse.viatra.examples.cps.generator.utils.CPSModelBuilderUtil
import org.eclipse.viatra.examples.cps.traceability.TraceabilityFactory

class EMFResourceInitializationPhase extends CPSBenchmarkPhase{
	
	protected extension CyberPhysicalSystemFactory cpsFactory = CyberPhysicalSystemFactory.eINSTANCE
	protected extension DeploymentFactory depFactory = DeploymentFactory.eINSTANCE
	protected extension TraceabilityFactory traceFactory = TraceabilityFactory.eINSTANCE
	
	protected extension CPSModelBuilderUtil modelBuilderUtil = new CPSModelBuilderUtil 
	
	
	new(String phaseName) {
		super(phaseName, true)
	}
	
	override execute(CPSDataToken cpsToken, TimeMetric timer, MemoryMetric memory) {
		
		timer.startMeasure
		
		cpsToken.cps2dep = preparePersistedCPSModel(cpsToken.instancesDirURI.appendSegment(cpsToken.scenarioName),
			cpsToken.xform.class.simpleName + cpsToken.size + "_" + System.nanoTime)
		
		timer.stopMeasure
		memory.measure
		return emptySet
	}
	
}