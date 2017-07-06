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

package com.incquerylabs.examples.cps.performance.tests.benchmarks

import com.incquerylabs.examples.cps.performance.tests.config.cases.ClientServerCase
import java.io.File
import java.util.Random
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.CyberPhysicalSystemFactory
import org.eclipse.viatra.examples.cps.deployment.DeploymentFactory
import org.eclipse.viatra.examples.cps.generator.CPSPlanBuilder
import org.eclipse.viatra.examples.cps.generator.dtos.CPSFragment
import org.eclipse.viatra.examples.cps.generator.dtos.CPSGeneratorInput
import org.eclipse.viatra.examples.cps.planexecutor.PlanExecutor
import org.eclipse.viatra.examples.cps.traceability.TraceabilityFactory
import org.eclipse.viatra.examples.cps.xform.m2m.tests.CPS2DepTest
import org.eclipse.viatra.examples.cps.xform.m2m.launcher.CPSTransformationWrapper
import org.eclipse.viatra.examples.cps.xform.m2t.api.ChangeM2TOutputProvider
import org.eclipse.viatra.examples.cps.xform.m2t.api.DefaultM2TOutputProvider
import org.eclipse.viatra.examples.cps.xform.m2t.distributed.CodeGenerator
import org.eclipse.viatra.examples.cps.xform.m2t.monitor.DeploymentChangeMonitor
import org.eclipse.viatra.examples.cps.xform.serializer.DefaultSerializer
import org.eclipse.viatra.examples.cps.xform.serializer.IFileAccessor
import org.eclipse.viatra.examples.cps.xform.serializer.eclipse.EclipseBasedFileAccessor
import org.eclipse.viatra.examples.cps.xform.serializer.javaio.JavaIOBasedFileAccessor
import org.eclipse.viatra.query.runtime.api.ViatraQueryEngine
import org.eclipse.viatra.query.runtime.emf.EMFScope
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized

/**
 * Tests the whole toolchain using each transformation one-by-one
 */
@RunWith(Parameterized)
class CPSDemonstratorIntegrationTest extends CPS2DepTest {

	val seed = 11111
	val scale = 8

	protected extension CyberPhysicalSystemFactory cpsFactory = CyberPhysicalSystemFactory.eINSTANCE
	protected extension DeploymentFactory depFactory = DeploymentFactory.eINSTANCE
	protected extension TraceabilityFactory traceFactory = TraceabilityFactory.eINSTANCE
	protected extension DefaultSerializer serializer = new DefaultSerializer

	new(CPSTransformationWrapper wrapper, String wrapperType) {
		super(wrapper, wrapperType)
	}

	@Test
	def void completeToolchainIntegrationTest() {

		val rs = new ResourceSetImpl()
		val cpsRes = rs.createResource(URI.createURI("cps.cyberphysicalsystem"))
		val depRes = rs.createResource(URI.createURI("deployment.deployment"))
		val trcRes = rs.createResource(URI.createURI("trace.traceability"))
		
		val cps = createCyberPhysicalSystem => [
			identifier = "cps"
		]
		cpsRes.contents += cps
		
		val dep = createDeployment
		depRes.contents += dep
		 
		val cps2dep = createCPSToDeployment => [
			it.cps = cps
			it.deployment = dep
		]
		trcRes.contents += cps2dep
		
		
		
		// Generate model
		val Random rand = new Random(seed)
		val benchmarkCase = new ClientServerCase(scale, rand)

		val const = benchmarkCase.getConstraints();

		val CPSGeneratorInput input = new CPSGeneratorInput(seed, const, cps2dep.cps);
		var plan = CPSPlanBuilder.buildDefaultPlan;
		
		var PlanExecutor<CPSFragment, CPSGeneratorInput> generator = new PlanExecutor();
		
		// Generating
		var fragment = generator.process(plan, input);

		cps2dep.initializeTransformation

		executeTransformation

		val engine2 = ViatraQueryEngine.on(new EMFScope(cps2dep))

		val projectName = "integration.test.generated.code"
		val codeGenerator = new CodeGenerator(projectName, engine2, true);
		
		var String folderString = null
		var IFileAccessor fileAccessor = null
		if(Platform.isRunning){
			fileAccessor = new EclipseBasedFileAccessor
			createProject("",projectName, fileAccessor)
			val project = ResourcesPlugin.workspace.root.getProject(projectName)
			val srcFolder = project.getFolder("src");
			folderString = srcFolder.location.toOSString
			val monitor = new NullProgressMonitor();
			if (!srcFolder.exists()) {
				srcFolder.create(true, true, monitor);
			}
			srcFolder.members.forEach[delete(true, null)]
		} else {
			fileAccessor = new JavaIOBasedFileAccessor
			val projectPath = "results/temp/"
			createProject(projectPath ,projectName, fileAccessor)
			folderString = projectPath + projectName + "/src"
			val srcFolder = new File(folderString)
			srcFolder.listFiles.forEach[delete]
		}
		

		// Initial source generation
		val provider = new DefaultM2TOutputProvider(cps2dep.deployment, codeGenerator,folderString)
		serialize(folderString,provider, fileAccessor)
	
		val changeMonitor = new DeploymentChangeMonitor(cps2dep.deployment, engine2)

		changeMonitor.startMonitoring

		info("Adding new host instance")
		val appType = cps2dep.cps.appTypes.findFirst[it.identifier.contains("Client")]
		val hostInstance = cps2dep.cps.hostTypes.findFirst[it.identifier.contains("client")].instances.head
		appType.prepareApplicationInstanceWithId("new.app.instance", hostInstance)

		executeTransformation
		val changeprovider = new ChangeM2TOutputProvider(changeMonitor.deltaSinceLastCheckpoint, codeGenerator, folderString)
		folderString.serialize(changeprovider, fileAccessor)
	}

	
}
