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
import com.incquerylabs.examples.cps.performance.tests.config.GeneratorType
import eu.mondo.sam.core.metrics.MemoryMetric
import eu.mondo.sam.core.metrics.TimeMetric
import java.io.File
import org.eclipse.core.resources.IWorkspace
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.ICoreRunnable
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Platform
import org.eclipse.viatra.examples.cps.xform.m2t.api.DefaultM2TOutputProvider
import org.eclipse.viatra.examples.cps.xform.m2t.api.ICPSGenerator
import org.eclipse.viatra.examples.cps.xform.m2t.jdt.CodeGenerator
import org.eclipse.viatra.examples.cps.xform.serializer.DefaultSerializer
import org.eclipse.viatra.examples.cps.xform.serializer.IFileAccessor
import org.eclipse.viatra.examples.cps.xform.serializer.eclipse.EclipseBasedFileAccessor
import org.eclipse.viatra.examples.cps.xform.serializer.javaio.JavaIOBasedFileAccessor
import org.eclipse.viatra.query.runtime.api.AdvancedViatraQueryEngine
import org.eclipse.viatra.query.runtime.emf.EMFScope

class M2TTransformationPhase extends CPSBenchmarkPhase {
	extension DefaultSerializer serializer = new DefaultSerializer

	new(String name) {
		super(name, true)
	}

	override execute(CPSDataToken cpsToken, TimeMetric timer, MemoryMetric memory) {

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
		return emptySet
	}

	private def performSerialization(CPSDataToken cpsToken, String folderString, IFileAccessor fileAccessor) {
		// Source generation
		val provider = new DefaultM2TOutputProvider(cpsToken.cps2dep.deployment, cpsToken.codeGenerator,folderString)
		serialize(folderString, provider, fileAccessor)
	}
	
	private def prepareEclipseBasedSerialization(String projectName, CPSDataToken cpsToken) {
		val workspace = ResourcesPlugin.workspace

		val fileAccessor = new EclipseBasedFileAccessor
		createProject("",projectName, fileAccessor)
		val project = workspace.root.getProject(projectName)
		
		// disable auto-building of workspace
		val description = workspace.getDescription();
        description.setAutoBuilding(false);
        workspace.setDescription(description);
        
		val srcFolder = project.getFolder("src");
		val folderString = srcFolder.location.toOSString
		cpsToken.srcFolder = srcFolder
		val monitor = new NullProgressMonitor();
		if (!srcFolder.exists()) {
			srcFolder.create(true, true, monitor);
		}
		srcFolder.members.forEach[delete(true, null)]
		
		val myRunnable = new ICoreRunnable() {
            override run(IProgressMonitor monitor) throws CoreException {
        		performSerialization(cpsToken, folderString, fileAccessor)
            }
        }
		workspace.run(myRunnable, project, IWorkspace.AVOID_UPDATE, null)
		
	}
	
}