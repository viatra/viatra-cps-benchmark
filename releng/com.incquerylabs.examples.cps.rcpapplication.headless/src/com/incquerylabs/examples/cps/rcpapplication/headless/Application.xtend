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
import com.incquerylabs.examples.cps.performance.tests.queries.CPSQueryWrapper
import com.incquerylabs.examples.cps.performance.tests.queries.QueryIdentifier
import com.incquerylabs.examples.cps.performance.tests.queries.QueryWrapperIdentifier
import com.incquerylabs.examples.cps.performance.tests.queries.QueryWrapperFactory

/** 
 * This class controls all aspects of the application's execution
 */
class Application implements IApplication {
 	val static COMMON_LAYOUT = "%c{1} - %m%n"
	val static FILE_LOG_LAYOUT_PREFIX = "[%d{MMM/dd HH:mm:ss}] "
	
	val static CASE_ARGUMENT = "-case"
	val static GENERATOR_TYPE_ARGUMENT = "-generatorType"
	val static RESULTS_ARGUMENT = "-results"
	val static RUN_INDEX_ARGUMENT = "-runIndex"
	val static SCALE_ARGUMENT = "-scale"
	val static SCENARIO_ARGUMENT = "-scenario"
	val static TRANSFORMATION_TYPE_ARGUMENT = "-transformationType"
	val static QUERY_TOOL_ARGUMENT = "-queryTool"
	val static QUERY_ID_ARGUMENT = "-query"
	
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
				case QUERY_TOOL_ARGUMENT: {
					argIndex++
					params.put(QUERY_TOOL_ARGUMENT, args.get(argIndex))
				}
				case QUERY_ID_ARGUMENT: {
					argIndex++
					params.put(QUERY_ID_ARGUMENT, args.get(argIndex))
				}
				default: {
					argIndex++
				}
			}
		}
		
		val scale = Integer.parseInt(params.get(SCALE_ARGUMENT))
		val runIndex = Integer.parseInt(params.get(RUN_INDEX_ARGUMENT))
		
		val random = new Random(ScenarioBenchmarkingBase.RANDOM_SEED);
		
		val caseId = CaseIdentifier.valueOf(params.get(CASE_ARGUMENT))
		val bcase = CaseFactory.create.createCase(caseId, scale, random)
		val resultsFolderPath = params.get(RESULTS_ARGUMENT)

		var BenchmarkArguments arguments = null
		var String tool
		
		val scenarioId = ScenarioIdentifier.valueOf(params.get(SCENARIO_ARGUMENT))
		// TODO move scenario specific argument parsing to ScenarioFactory!
		if(scenarioId == ScenarioIdentifier.QUERY){
			val queryId = QueryIdentifier.valueOf(params.get(QUERY_ID_ARGUMENT))
			val queryTool = QueryWrapperIdentifier.valueOf(params.get(QUERY_TOOL_ARGUMENT))
			tool = queryTool + "-" + queryId
			val scenario = ScenarioFactory.create.createScenario(scenarioId, bcase, runIndex, tool)
			val queryWrapper = QueryWrapperFactory.create.createQueryWrapper(queryTool, queryId)
			arguments = new BenchmarkArguments(scenario, null, null, queryWrapper, scale, resultsFolderPath)
		} else {
			val trafoType = TransformationType.valueOf(params.get(TRANSFORMATION_TYPE_ARGUMENT))
			val generatorType = GeneratorType.valueOf(params.get(GENERATOR_TYPE_ARGUMENT))
			tool = trafoType.name + "-" + generatorType.name
			val scenario = ScenarioFactory.create.createScenario(scenarioId, bcase, runIndex, tool)
			arguments = new BenchmarkArguments(scenario, trafoType, generatorType, null, scale, resultsFolderPath)
		}
		
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
		
		val logFilePath = '''«arguments.resultsFolderPath»/log/log_«arguments.scenario.tool»_size_«arguments.scale»_startedAt_«System.currentTimeMillis».log'''
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
			arguments.queryWrapper,
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
			it.queryWrapper = arguments.queryWrapper
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
	CPSQueryWrapper queryWrapper
	int scale
	String resultsFolderPath
	
}
