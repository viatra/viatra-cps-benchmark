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
import org.eclipse.core.resources.IWorkspace
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.ICoreRunnable
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Platform
import org.eclipse.viatra.examples.cps.xform.m2t.api.ChangeM2TOutputProvider
import org.eclipse.viatra.examples.cps.xform.serializer.DefaultSerializer
import org.eclipse.viatra.examples.cps.xform.serializer.eclipse.EclipseBasedFileAccessor
import org.eclipse.viatra.examples.cps.xform.serializer.javaio.JavaIOBasedFileAccessor

class M2TDeltaTransformationPhase extends CPSBenchmarkPhase {
	protected extension DefaultSerializer serializer = new DefaultSerializer

	new(String name) {
		super(name, true)
	}

	override execute(CPSDataToken cpsToken, TimeMetric timer, MemoryMetric memory) {

        val workspace = ResourcesPlugin.workspace
        while(workspace.isTreeLocked){
            Thread.sleep(1000);
        }

		timer.startMeasure

		val monitor = cpsToken.changeMonitor
		val generator = cpsToken.codeGenerator
		val folder = cpsToken.srcFolder
		val folderString = if(folder !== null){
			folder.location.toOSString
		} else {
			cpsToken.folderPath
		}
		val delta = monitor.createCheckpoint
		
		val changeprovider = new ChangeM2TOutputProvider(delta, generator, folderString)
		if(Platform.running){
			val fileAccessor = new EclipseBasedFileAccessor
			val myRunnable = new ICoreRunnable() {
                override run(IProgressMonitor monitor) throws CoreException {
            		folderString.serialize(changeprovider, fileAccessor)
                }
            }
            workspace.run(myRunnable, folder.project, IWorkspace.AVOID_UPDATE, null)
		} else {
			val fileAccessor = new JavaIOBasedFileAccessor
    		folderString.serialize(changeprovider, fileAccessor)
		}

		timer.stopMeasure
		memory.measure
		return emptySet
	}
}