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
 package com.incquerylabs.examples.cps.performance.tests

import com.incquerylabs.examples.cps.performance.tests.config.CPSDataToken
import com.incquerylabs.examples.cps.performance.tests.config.GeneratorType
import eu.mondo.sam.core.BenchmarkEngine
import eu.mondo.sam.core.metrics.MemoryMetric
import eu.mondo.sam.core.results.JsonSerializer
import eu.mondo.sam.core.scenarios.BenchmarkScenario
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.Properties
import java.util.Random
import org.apache.log4j.Logger
import org.eclipse.core.runtime.Platform
import org.eclipse.viatra.examples.cps.tests.util.CPSTestBase
import org.eclipse.viatra.examples.cps.xform.m2m.tests.wrappers.CPSTransformationWrapper
import org.eclipse.viatra.examples.cps.xform.m2m.tests.wrappers.TransformationType
import org.eclipse.viatra.query.runtime.ViatraQueryRuntimePlugin
import org.junit.After
import org.junit.AfterClass
import org.junit.Before
import org.junit.BeforeClass

class ScenarioBenchmarkingBase extends CPSTestBase {
	protected extension CPSTransformationWrapper xform
	protected extension Logger logger = Logger.getLogger("cps.performance.tests.CPSPerformanceTest")
	
	public static val RANDOM_SEED = 11111
	
	protected var Random rand = new Random(RANDOM_SEED);
	protected var int scale
	protected var BenchmarkScenario scenario
	protected var GeneratorType generatorType
	protected var TransformationType wrapperType
    
    def startTest(){
    	info('''START TEST: Xform: «wrapperType», Gen: «generatorType», Scale: «scale», Scenario: «scenario.class.name»''')
    }
    
    def void printVQRevision(String jsonResultFolder){
	   val vqBundle = Platform.getBundle(ViatraQueryRuntimePlugin.PLUGIN_ID)
	   if (vqBundle == null) return
	   val version = vqBundle.version.toString
	   val scmRevision = vqBundle.getHeaders().get("SCM-Revision")
	   val props = new Properties;
	   props.put("viatra.query.version", version);
	   props.put("viatra.query.revision", scmRevision);
	   val file = new File(jsonResultFolder+File.separatorChar+"artifact.revision.properties");
	   try{
	       val out = new FileOutputStream(file)
	       props.store(out, "");
	       out.close    
	   }catch(IOException e){
	       throw new RuntimeException(e)
	   }
	}
	
	def void completeToolchainIntegrationTest(String jsonResultFolder) {
		startTest
	
		// communication unit between the phases
		val CPSDataToken token = new CPSDataToken
		token.scenarioName = scenario.class.simpleName
		token.instancesDirPath = instancesDirPath
		token.seed = RANDOM_SEED
		token.size = scale
		token.xform = xform
		token.generatorType = generatorType
		
		val engine = new BenchmarkEngine
		JsonSerializer::setResultPath(jsonResultFolder)
		MemoryMetric.numberOfGC = 5
		
		engine.runBenchmark(scenario, token)

		endTest
		printVQRevision(jsonResultFolder)
	}
    
    def endTest(){
    	info('''END TEST: Xform: «wrapperType», Gen: «generatorType», Scale: «scale», Scenario: «scenario.class.name»''')
    }
	
	@BeforeClass
	static def callGCBefore(){
		callGC
	}
	
	@Before
	def cleanupBefore() {
		callGC
	}

	@After
	def cleanup() {
		val oldWrapper = xform
		oldWrapper.cleanupTransformation;
		callGC
	}

	@AfterClass
	static def callGC(){
		(0..4).forEach[Runtime.getRuntime().gc()]
		
		try{
			Thread.sleep(1000)
		} catch (InterruptedException ex) {
			Logger.getLogger("cps.performance.tests.CPSPerformanceTest").warn("Sleep after System GC interrupted")
		}
	}
}