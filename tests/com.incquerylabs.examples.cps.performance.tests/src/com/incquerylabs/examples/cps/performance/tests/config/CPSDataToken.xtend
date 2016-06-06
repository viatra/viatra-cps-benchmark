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

package com.incquerylabs.examples.cps.performance.tests.config

import eu.mondo.sam.core.DataToken
import org.eclipse.core.resources.IFolder
import org.eclipse.viatra.examples.cps.traceability.CPSToDeployment
import org.eclipse.viatra.examples.cps.xform.m2m.tests.wrappers.CPSTransformationWrapper
import org.eclipse.viatra.examples.cps.xform.m2m.tests.wrappers.TransformationType
import org.eclipse.viatra.examples.cps.xform.m2t.api.ICPSGenerator
import org.eclipse.viatra.examples.cps.xform.m2t.monitor.DeploymentChangeMonitor
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class CPSDataToken implements DataToken{
	
	GeneratorType generatorType
	TransformationType transformationType
	String scenarioName
	CPSToDeployment cps2dep
	String instancesDirPath
	DeploymentChangeMonitor changeMonitor
	ICPSGenerator codeGenerator 
	IFolder srcFolder
	String folderPath
	int seed
	int size
	int modificationIndex
	
	CPSTransformationWrapper xform
	
	override init() {
		modificationIndex = 1
	}
	
	override destroy() {
		
	}
	
	
	
}