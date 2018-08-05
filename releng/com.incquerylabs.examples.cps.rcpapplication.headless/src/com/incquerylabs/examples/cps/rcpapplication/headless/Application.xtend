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

import com.incquerylabs.examples.cps.performance.tests.ScenarioBenchmarkingBase
import com.incquerylabs.examples.cps.performance.tests.config.CPSDataToken
import com.incquerylabs.examples.cps.performance.tests.config.GeneratorType
import com.incquerylabs.examples.cps.performance.tests.config.cases.CaseFactory
import com.incquerylabs.examples.cps.performance.tests.config.cases.CaseIdentifier
import com.incquerylabs.examples.cps.performance.tests.config.scenarios.CPSBenchmarkScenario
import com.incquerylabs.examples.cps.performance.tests.config.scenarios.ScenarioFactory
import com.incquerylabs.examples.cps.performance.tests.config.scenarios.ScenarioIdentifier
import eu.mondo.sam.core.BenchmarkEngine
import eu.mondo.sam.core.metrics.MemoryMetric
import eu.mondo.sam.core.results.JsonSerializer
import java.io.File
import java.util.Random
import org.apache.log4j.FileAppender
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.apache.log4j.PatternLayout
import org.eclipse.equinox.app.IApplication
import org.eclipse.equinox.app.IApplicationContext
import org.eclipse.viatra.examples.cps.xform.m2m.launcher.TransformationType
import org.eclipse.xtend.lib.annotations.Data

import static eu.mondo.sam.core.metrics.MemoryMetric.*
import org.eclipse.emf.common.util.URI
import org.apache.log4j.ConsoleAppender
import m2m.batch.cps2dep.yamtl.tests.BatchYAMTL

/** 
 * This class controls all aspects of the application's execution
 */
class Application implements IApplication {
 	val static COMMON_LAYOUT = "%c{1} - %m%n"
	val static FILE_LOG_LAYOUT_PREFIX = "[%d{MMM/dd HH:mm:ss}] "
	
	val static CASE_ARGUMENT = "-case"
	val static CONSOLELOG_ARGUMENT = "-logToEclipseConsole"
	val static GENERATOR_TYPE_ARGUMENT = "-generatorType"
	val static RESULTS_ARGUMENT = "-results"
	val static RUN_INDEX_ARGUMENT = "-runIndex"
	val static SCALE_ARGUMENT = "-scale"
	val static SCENARIO_ARGUMENT = "-scenario"
	val static TRANSFORMATION_TYPE_ARGUMENT = "-transformationType"
	
	extension Logger logger = Logger.getLogger("cps.testrunner")

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
			RUN_INDEX_ARGUMENT -> "1",
		 	RESULTS_ARGUMENT -> "./results")
		var argIndex = 0
		while(argIndex < args.length) {
			switch args.get(argIndex) {
				case SCENARIO_ARGUMENT: {
					argIndex++
					params.put(SCENARIO_ARGUMENT, args.get(argIndex))
				}
				case CASE_ARGUMENT: {
					argIndex++
					params.put(CASE_ARGUMENT, args.get(argIndex))
				}
				case CONSOLELOG_ARGUMENT: {
				    argIndex++
					params.put(CONSOLELOG_ARGUMENT, "true")
				}
				case TRANSFORMATION_TYPE_ARGUMENT: {
					argIndex++
					params.put(TRANSFORMATION_TYPE_ARGUMENT, args.get(argIndex))
				}
				case GENERATOR_TYPE_ARGUMENT: {
					argIndex++
					params.put(GENERATOR_TYPE_ARGUMENT, args.get(argIndex))
				}
				case SCALE_ARGUMENT: {
					argIndex++
					params.put(SCALE_ARGUMENT, args.get(argIndex))
				}
				case RUN_INDEX_ARGUMENT: {
					argIndex++
					params.put(RUN_INDEX_ARGUMENT, args.get(argIndex))
				}
				case RESULTS_ARGUMENT: {
					argIndex++
					params.put(RESULTS_ARGUMENT, args.get(argIndex))
				}
				default: {
					argIndex++
				}
			}
		}
		
		// TODO move scenario specific argument parsing to ScenarioFactory!
		val trafo = params.get(TRANSFORMATION_TYPE_ARGUMENT)
		val scale = Integer.parseInt(params.get(SCALE_ARGUMENT))
		val generatorType = GeneratorType.valueOf(params.get(GENERATOR_TYPE_ARGUMENT))
		val runIndex = Integer.parseInt(params.get(RUN_INDEX_ARGUMENT))
		val consoleLog = Boolean.parseBoolean(params.get(CONSOLELOG_ARGUMENT))
		
		val random = new Random(ScenarioBenchmarkingBase.RANDOM_SEED);
		
		val caseId = CaseIdentifier.valueOf(params.get(CASE_ARGUMENT))
		val scenarioId = ScenarioIdentifier.valueOf(params.get(SCENARIO_ARGUMENT))

		val bcase = CaseFactory.create.createCase(caseId, scale, random)
		val tool = trafo + "-" + generatorType.name
		val scenario = ScenarioFactory.create.createScenario(scenarioId, bcase, runIndex, tool)
		
		val resultsFolderPath = params.get(RESULTS_ARGUMENT)
		val arguments = new BenchmarkArguments(scenario, trafo, generatorType, scale, resultsFolderPath, consoleLog)
		
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
		if(arguments.consoleLog){
    		val consoleAppender = new ConsoleAppender(new PatternLayout(FILE_LOG_LAYOUT_PREFIX+COMMON_LAYOUT))
    		rootLogger.addAppender(consoleAppender)
		}
		rootLogger.additivity = false
		rootLogger.level = Level.INFO
	}
	
	def runWarmup(BenchmarkArguments arguments) {
		val warmupFolderPath = arguments.resultsFolderPath + "/json/warmup/"
		var warmupFolder = new File(warmupFolderPath)
		if(!warmupFolder.exists){
			warmupFolder.mkdirs
		}
		
		val bcase = arguments.scenario.benchmarkCase
		val scale = bcase.scale
		
		bcase.scale = 1
		
		val warmupArguments = new BenchmarkArguments(
			arguments.scenario,
			arguments.transformationType,
			arguments.generatorType,
			1,
			arguments.resultsFolderPath,
			arguments.consoleLog
		)
			
		runTest(warmupArguments, warmupFolderPath)
		
		bcase.scale = scale
	}
	
	def runBenchmark(BenchmarkArguments arguments) {
		val resultsFolderPath = arguments.resultsFolderPath + "/json/"
		var resultsFolder = new File(resultsFolderPath)
		if(!resultsFolder.exists){
			resultsFolder.mkdirs
		}
		ScenarioBenchmarkingBase.printVQRevision(resultsFolderPath)
		
		runTest(arguments, resultsFolderPath)
	}

	def runTest(BenchmarkArguments arguments, String resultsFolder) {
		
		val RANDOM_SEED = 11111
		
		// init class
		info("************ Start class init")
		ScenarioBenchmarkingBase.callGC()
		
		// init instance
		info("************ Start instance init")
		
		// communication unit between the phases
		val CPSDataToken token = new CPSDataToken
		token.scenarioName = arguments.scenario.class.simpleName
		token.instancesDirURI = URI.createFileURI(arguments.resultsFolderPath).appendSegment("models") 
		token.seed = RANDOM_SEED
		token.size = arguments.scale
		// TODO xform and generator scenario specific!
		if (arguments.transformationType == "BATCH_YAMTL") {
		    token.xform = new BatchYAMTL
		} else {
    		token.xform = TransformationType.valueOf(arguments.transformationType).wrapper
		}
		token.generatorType = arguments.generatorType
		
		val engine = new BenchmarkEngine
		JsonSerializer::setResultPath(resultsFolder)
		MemoryMetric.numberOfGC = 5
		
		// run test
		info("************ Run test")
		engine.runBenchmark(arguments.scenario, token)
		
		// clean instance
		info("************ Start instance clean")
		// TODO xform scenario specific!
		token.xform.cleanupTransformation()
		
		// clean class
		info("************ Start class clean")
		ScenarioBenchmarkingBase.callGC()
	}

	override void stop() {
		// nothing to do
	}
	
	def printUsage() {
		info('''
			usage: eclipse -scenario <scenario> [scenario_arguments] [-results <resultsFolderPath>] [-logToEclipseConsole]
				scenario: which benchmark scenario to run
				scenario_arguments: optional arguments depending on scenario
				resultsFolderPath: optional path for storing results (defaults to './results')
				logToEclipseConsole: optional, if present the logger will output to Eclipse console (useful when debugging)
		''')
	}

}

@Data
class BenchmarkArguments {
	
	CPSBenchmarkScenario scenario
	String transformationType
	GeneratorType generatorType
	int scale
	String resultsFolderPath
	boolean consoleLog
	
}
