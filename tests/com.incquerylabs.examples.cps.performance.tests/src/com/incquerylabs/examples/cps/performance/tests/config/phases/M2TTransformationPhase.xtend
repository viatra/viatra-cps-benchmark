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

import eu.mondo.sam.core.DataToken
import eu.mondo.sam.core.metrics.MemoryMetric
import eu.mondo.sam.core.metrics.TimeMetric
import eu.mondo.sam.core.phases.AtomicPhase
import eu.mondo.sam.core.results.PhaseResult
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.NullProgressMonitor
import com.incquerylabs.examples.cps.performance.tests.config.CPSDataToken
import com.incquerylabs.examples.cps.performance.tests.config.GeneratorType
import org.eclipse.viatra.examples.cps.xform.m2t.api.DefaultM2TOutputProvider
import org.eclipse.viatra.examples.cps.xform.m2t.api.ICPSGenerator
import org.eclipse.viatra.examples.cps.xform.m2t.jdt.CodeGenerator
import org.eclipse.viatra.examples.cps.xform.serializer.DefaultSerializer
import org.eclipse.viatra.examples.cps.xform.serializer.eclipse.EclipseBasedFileAccessor
import org.eclipse.viatra.examples.cps.xform.serializer.javaio.JavaIOBasedFileAccessor
import org.eclipse.viatra.query.runtime.api.AdvancedViatraQueryEngine
import org.eclipse.viatra.query.runtime.emf.EMFScope
import org.eclipse.core.runtime.Platform
import org.eclipse.viatra.examples.cps.xform.serializer.IFileAccessor
import java.io.File

class M2TTransformationPhase extends AtomicPhase {
	extension DefaultSerializer serializer = new DefaultSerializer

	new(String name) {
		super(name)
	}

	override execute(DataToken token, PhaseResult phaseResult) {
		val cpsToken = token as CPSDataToken
		val timer = new TimeMetric("Time")
		val memory = new MemoryMetric("Memory")

		timer.startMeasure

		val engine = AdvancedViatraQueryEngine.createUnmanagedEngine(new EMFScope(cpsToken.cps2dep))

		val projectName = "integration.test.generated.code"
		var ICPSGenerator codeGenerator = null
		if (cpsToken.generatorType.equals(GeneratorType.TEMPLATE)) {
			codeGenerator = new org.eclipse.viatra.examples.cps.xform.m2t.distributed.CodeGenerator(projectName, engine, true);
		} else if (cpsToken.generatorType.equals(GeneratorType.JDT)) {
			codeGenerator = new CodeGenerator(projectName, engine);
		}
		cpsToken.codeGenerator = codeGenerator
		
		var String folderString = null
		if(Platform.isRunning){
			prepareEclipseBasedSerialization(projectName, cpsToken)
		} else {
			val fileAccessor = new JavaIOBasedFileAccessor
			val projectPath = "results/temp/"
			createProject(projectPath ,projectName, fileAccessor)
			folderString = projectPath + projectName + "/src"
			val srcFolder = new File(folderString)
			srcFolder.listFiles.forEach[delete]
			cpsToken.folderPath = folderString
			performSerialization(cpsToken, folderString, fileAccessor)
		}

		timer.stopMeasure
		memory.measure
		
		phaseResult.addMetrics(timer, memory)
	}

	private def performSerialization(CPSDataToken cpsToken, String folderString, IFileAccessor fileAccessor) {
		// Source generation
		val provider = new DefaultM2TOutputProvider(cpsToken.cps2dep.deployment, cpsToken.codeGenerator,folderString)
		serialize(folderString, provider, fileAccessor)
	}
	
	private def prepareEclipseBasedSerialization(String projectName, CPSDataToken cpsToken) {
		val fileAccessor = new EclipseBasedFileAccessor
		createProject("",projectName, fileAccessor)
		val project = ResourcesPlugin.workspace.root.getProject(projectName)
		val srcFolder = project.getFolder("src");
		val folderString = srcFolder.location.toOSString
		cpsToken.srcFolder = srcFolder
		val monitor = new NullProgressMonitor();
		if (!srcFolder.exists()) {
			srcFolder.create(true, true, monitor);
		}
		srcFolder.members.forEach[delete(true, null)]
		
		performSerialization(cpsToken, folderString, fileAccessor)
	}
	
}