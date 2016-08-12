/*******************************************************************************
 * Copyright (c) 2014-2016, Abel Hegedus, IncQuery Labs Ltd.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   Abel Hegedus - initial API and implementation
 *******************************************************************************/
 package com.incquerylabs.examples.cps.performance.tests.config.metrics

import eu.mondo.sam.core.metrics.BenchmarkMetric

class AverageMemoryMetric extends BenchmarkMetric {
	
	protected val long interval
	protected long averageMemory
	protected int memoryCount
	
	protected Thread backgroundThread
	
	new(String name, long interval) {
		super(name)
		this.interval = interval
	}
	
	override getValue() {
		return Long.toString(averageMemory);
	}
	
	def startMeasurement() {
		memoryCount = 0
		averageMemory = 0
		
		Runtime.getRuntime().gc();
		
		val backgroundMemoryMeasurement = new Runnable() {
			
			override run() {
				try{
					while(true) {
						updateAverage
						
						Thread.sleep(interval)
					}
				} catch(InterruptedException ex){
					// do nothing
				}
			}
		}
		
		backgroundThread = new Thread(backgroundMemoryMeasurement)
		backgroundThread.start
	}
	
	def stopMeasurement() {
		backgroundThread.interrupt
		updateAverage
	}
	
	/**
	 * We are computing a cumulative moving average based on the current value,
	 * the number of measurements and the previous average.
	 */
	def updateAverage() {
		val currentMemory = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();
		
		memoryCount++
		val previousAverage = averageMemory
		val difference = (currentMemory - previousAverage) / memoryCount
		averageMemory = previousAverage + difference
	}
}