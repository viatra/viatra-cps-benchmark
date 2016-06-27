/*******************************************************************************
 * Copyright (c) 2014-2016 IncQuery Labs Ltd.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Akos Horvath, Abel Hegedus, Tamas Borbas, Zoltan Ujhelyi, Daniel Segesdi - initial API and implementation
 *******************************************************************************/
package com.incquerylabs.examples.cps.rcpapplication.headless

import java.io.File
import org.apache.log4j.FileAppender
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.apache.log4j.PatternLayout
import org.eclipse.equinox.app.IApplication
import org.eclipse.equinox.app.IApplicationContext
import com.incquerylabs.examples.cps.performance.tests.ToolchainPerformanceStatisticsBasedTest
import com.incquerylabs.examples.cps.performance.tests.config.GeneratorType
import org.eclipse.viatra.examples.cps.xform.m2m.tests.wrappers.TransformationType

/** 
 * This class controls all aspects of the application's execution
 */
class Application implements IApplication {
 	val static COMMON_LAYOUT = "%c{1} - %m%n";
	val static FILE_LOG_LAYOUT_PREFIX = "[%d{MMM/dd HH:mm:ss}] ";
	extension Logger logger = Logger.getLogger("cps.testrunner")
	/* (non-Javadoc)
	 * @see IApplication#start(org.eclipse.equinox.app.IApplicationContext)
	 */
	override Object start(IApplicationContext context) throws Exception {
		info("************ Test started ************")
		val args = context.arguments.get("application.args") as String[]
		var TransformationType trafoType
		var int scale
		var int runIndex
		var GeneratorType generatorType
		
		try {
			info("************ Start parse")
			trafoType = TransformationType.valueOf(args.get(0))
			scale = Integer.parseInt(args.get(1))
			generatorType = GeneratorType.valueOf(args.get(2))
			runIndex = Integer.parseInt(args.get(3))
			
			initLogger(trafoType, generatorType, scale)
			
			info('''
					
				Parameters:
					XFORM:		«trafoType»
					GENERATOR:	«generatorType»
					SCALE:		«scale»
					RUN INDEX:	«runIndex»
					
			''')
			
			val warmupFolderPath = "./results/json/warmup/"
			var warmupFolder = new File(warmupFolderPath)
			if(!warmupFolder.exists){
				warmupFolder.mkdirs
			}
			val resultsFolderPath = "./results/json/"
			var resultsFolder = new File(resultsFolderPath)
			if(!resultsFolder.exists){
				resultsFolder.mkdirs
			}
			
			runTest(trafoType, 1, generatorType, warmupFolderPath, runIndex)
			runTest(trafoType, scale, generatorType, resultsFolderPath, runIndex)
			
		} catch (IllegalArgumentException ex){
			ex.printStackTrace
		} catch (Exception ex) {
			info(ex.message)
		}
		info("************ Test finished ************")
		info('''
			---
			---
			---
		''')
		return IApplication.EXIT_OK
	}
	
	private def initLogger(TransformationType trafoType, GeneratorType generatorType, int scale) {	
		Logger.getLogger("org.eclipse.incquery").level = Level.INFO
		
		val logFilePath = '''./results/log/log_«trafoType»_«generatorType»_size_«scale»_startedAt_«System.currentTimeMillis».log'''
		val fileAppender = new FileAppender(new PatternLayout(FILE_LOG_LAYOUT_PREFIX+COMMON_LAYOUT),logFilePath,true)
		val rootLogger = Logger.rootLogger
		rootLogger.removeAllAppenders
		rootLogger.addAppender(fileAppender)
		rootLogger.additivity = false
		rootLogger.level = Level.INFO
	}

	def runTest(TransformationType trafoType, int scale, GeneratorType generatorType, String resultsFolder,  int runIndex) {
		// init class
		info("************ Start class init")
		ToolchainPerformanceStatisticsBasedTest.callGCBefore()
		
		// init instance
		info("************ Start instance init")
		var test = new ToolchainPerformanceStatisticsBasedTest(trafoType, scale, generatorType, runIndex)
		test.cleanupBefore()
		
		// run test
		info("************ Run test")
		test.completeToolchainIntegrationTest(resultsFolder)
		
		// clean instance
		info("************ Start instance clean")
		test.cleanup()
		
		// clean class
		info("************ Start class clean")
		ToolchainPerformanceStatisticsBasedTest.callGC()
	}

	/* (non-Javadoc)
	 * @see IApplication#stop()
	 */
	override void stop() {
		// nothing to do
	}

}
