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
import com.incquerylabs.examples.cps.performance.tests.config.CPSDataToken
import org.eclipse.viatra.examples.cps.xform.m2t.api.ChangeM2TOutputProvider
import org.eclipse.viatra.examples.cps.xform.serializer.DefaultSerializer
import org.eclipse.viatra.examples.cps.xform.serializer.eclipse.EclipseBasedFileAccessor
import org.eclipse.core.runtime.Platform
import org.eclipse.viatra.examples.cps.xform.serializer.javaio.JavaIOBasedFileAccessor

class M2TDeltaTransformationPhase extends AtomicPhase {
	protected extension DefaultSerializer serializer = new DefaultSerializer

	new(String name) {
		super(name)
	}

	override execute(DataToken token, PhaseResult phaseResult) {
		val cpsToken = token as CPSDataToken
		val timer = new TimeMetric("Time")
		val memory = new MemoryMetric("Memory")

		timer.startMeasure

		val monitor = cpsToken.changeMonitor
		val generator = cpsToken.codeGenerator
		val folder = cpsToken.srcFolder
		val folderString = if(folder != null){
			folder.location.toOSString
		} else {
			cpsToken.folderPath
		}
		val delta = monitor.deltaSinceLastCheckpoint
	
		
		val changeprovider = new ChangeM2TOutputProvider(delta, generator, folderString)
		val fileAccessor = if(Platform.running){
			new EclipseBasedFileAccessor
		} else {
			new JavaIOBasedFileAccessor
		}
		folderString.serialize(changeprovider, fileAccessor)

		timer.stopMeasure
		memory.measure

		phaseResult.addMetrics(timer, memory)
	}
}