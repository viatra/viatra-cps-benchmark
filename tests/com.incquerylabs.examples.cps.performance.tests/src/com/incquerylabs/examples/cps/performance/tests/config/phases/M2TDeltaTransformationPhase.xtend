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
		val fileAccessor = if(Platform.running){
			new EclipseBasedFileAccessor
		} else {
			new JavaIOBasedFileAccessor
		}
		folderString.serialize(changeprovider, fileAccessor)

		timer.stopMeasure
		memory.measure
		return emptySet
	}
}