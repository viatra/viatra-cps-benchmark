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

import com.incquerylabs.examples.cps.performance.tests.CPSBenchmarkBuilder
import com.incquerylabs.examples.cps.performance.tests.ScenarioBenchmarkingBase
import com.incquerylabs.examples.cps.performance.tests.config.GeneratorType
import com.incquerylabs.examples.cps.performance.tests.config.cases.CaseFactory
import com.incquerylabs.examples.cps.performance.tests.config.cases.CaseIdentifier
import com.incquerylabs.examples.cps.performance.tests.config.scenarios.ScenarioFactory
import com.incquerylabs.examples.cps.performance.tests.config.scenarios.ScenarioIdentifier
import eu.mondo.sam.core.scenarios.BenchmarkScenario
import java.io.File
import java.util.Random
import org.apache.log4j.FileAppender
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.apache.log4j.PatternLayout
import org.eclipse.equinox.app.IApplication
import org.eclipse.equinox.app.IApplicationContext
import org.eclipse.viatra.examples.cps.xform.m2m.tests.wrappers.TransformationType
import org.eclipse.xtend.lib.annotations.Data

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
		val args = context.arguments.get(IApplicationContext.APPLICATION_ARGS) as String[]
		
		try {
			val arguments = args.processArguments
			runWarmup(arguments)
			runBenchmark(arguments)
			
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
	
	private def BenchmarkArguments processArguments(String[] args) {
		info("************ Start parse")
		
		var params = newHashMap(
			"-runIndex" -> "1",
		 	"-results" -> "./results")
		var argIndex = 0
		while(argIndex < args.length) {
			switch args.get(argIndex) {
				case "-scenario": {
					argIndex++
					params.put("-scenario", args.get(argIndex))
				}
				case "-case": {
					argIndex++
					params.put("-case", args.get(argIndex))
				}
				case "-transformationType": {
					argIndex++
					params.put("-transformationType", args.get(argIndex))
				}
				case "-generatorType": {
					argIndex++
					params.put("-generatorType", args.get(argIndex))
				}
				case "-scale": {
					argIndex++
					params.put("-scale", args.get(argIndex))
				}
				case "-runIndex": {
					argIndex++
					params.put("-runIndex", args.get(argIndex))
				}
				case "-results": {
					argIndex++
					params.put("-results", args.get(argIndex))
				}
				default: {
					argIndex++
				}
			}
		}
		
		// TODO move scenario specific argument parsing to ScenarioFactory!
		val trafoType = TransformationType.valueOf(params.get("-transformationType"))
		val scale = Integer.parseInt(params.get("-scale"))
		val generatorType = GeneratorType.valueOf(params.get("-generatorType"))
		val runIndex = Integer.parseInt(params.get("-runIndex"))
		
		val random = new Random(ScenarioBenchmarkingBase.RANDOM_SEED);
		
		val caseId = CaseIdentifier.valueOf(params.get("-case"))
		val scenarioId = ScenarioIdentifier.valueOf(params.get("-scenario"))

		val bcase = CaseFactory.create.createCase(caseId, scale, random)
		val tool = trafoType.name + "-" + generatorType.name
		val scenario = ScenarioFactory.create.createScenario(scenarioId, bcase, runIndex, tool)
		
		val resultsFolderPath = params.get("-results")
		val arguments = new BenchmarkArguments(scenario, trafoType, generatorType, scale, resultsFolderPath)
		
		initLogger(arguments)
		
		info('''
				
			Parameters:
				SCENARIO:	«scenarioId»
				CASE:		«caseId»
				TOOL:		«tool»
				SCALE:		«scale»
				RUN INDEX:	«runIndex»
				
		''')
		
		return arguments
	}
	
	private def initLogger(BenchmarkArguments arguments) {	
		Logger.getLogger("org.eclipse.viatra.query").level = Level.INFO
		
		val logFilePath = '''«arguments.resultsFolderPath»/log/log_«arguments.transformationType»_«arguments.generatorType»_size_«arguments.scale»_startedAt_«System.currentTimeMillis».log'''
		val fileAppender = new FileAppender(new PatternLayout(FILE_LOG_LAYOUT_PREFIX+COMMON_LAYOUT),logFilePath,true)
		val rootLogger = Logger.rootLogger
		rootLogger.removeAllAppenders
		rootLogger.addAppender(fileAppender)
		rootLogger.additivity = false
		rootLogger.level = Level.INFO
	}
	
	def runWarmup(BenchmarkArguments arguments) {
		val warmupFolderPath = arguments.resultsFolderPath + "/json/warmup/"
		var warmupFolder = new File(warmupFolderPath)
		if(!warmupFolder.exists){
			warmupFolder.mkdirs
		}
		val warmupArguments = new BenchmarkArguments(
			arguments.scenario,
			arguments.transformationType,
			arguments.generatorType,
			1,
			arguments.resultsFolderPath
		)
			
		runTest(warmupArguments, warmupFolderPath)
	}
	
	def runBenchmark(BenchmarkArguments arguments) {
		val resultsFolderPath = arguments.resultsFolderPath + "/json/"
		var resultsFolder = new File(resultsFolderPath)
		if(!resultsFolder.exists){
			resultsFolder.mkdirs
		}
		runTest(arguments, resultsFolderPath)
	}

	def runTest(BenchmarkArguments arguments, String resultsFolder) {
		
		// init class
		info("************ Start class init")
		ScenarioBenchmarkingBase.callGCBefore()
		
		// init instance
		info("************ Start instance init")
		val builder = CPSBenchmarkBuilder.create => [
			it.scenario = arguments.scenario
			it.scale = arguments.scale
			it.wrapperType = arguments.transformationType
			it.generatorType = arguments.generatorType
		]
		val benchmark = builder.build
		benchmark.cleanupBefore()
		
		// run test
		info("************ Run test")
		benchmark.completeToolchainIntegrationTest(resultsFolder)
		
		// clean instance
		info("************ Start instance clean")
		benchmark.cleanup()
		
		// clean class
		info("************ Start class clean")
		ScenarioBenchmarkingBase.callGC()
	}

	/* (non-Javadoc)
	 * @see IApplication#stop()
	 */
	override void stop() {
		// nothing to do
	}
	
	def printUsage() {
		info('''
			usage: eclipse -scenario <scenario> [scenario_arguments] [-results <resultsFolderPath>]
				scenario: which benchmark scenario to run
				scenario_arguments: optional arguments depending on scenario
				resultsFolderPath: optional path for storing results (defaults to './results')
		''')
	}

}

@Data
class BenchmarkArguments {
	
	BenchmarkScenario scenario
	TransformationType transformationType
	GeneratorType generatorType
	int scale
	String resultsFolderPath
	
}
