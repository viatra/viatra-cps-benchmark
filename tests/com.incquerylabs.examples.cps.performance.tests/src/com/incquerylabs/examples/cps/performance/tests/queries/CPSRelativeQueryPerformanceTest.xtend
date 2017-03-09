package com.incquerylabs.examples.cps.performance.tests.queries

import com.google.common.base.Stopwatch
import com.incquerylabs.examples.cps.performance.tests.config.cases.LowSynchCase
import java.util.Random
import java.util.concurrent.TimeUnit
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.CyberPhysicalSystemPackage
import org.eclipse.viatra.examples.cps.deployment.DeploymentPackage
import org.eclipse.viatra.examples.cps.generator.CPSPlanBuilder
import org.eclipse.viatra.examples.cps.generator.dtos.CPSFragment
import org.eclipse.viatra.examples.cps.generator.dtos.CPSGeneratorInput
import org.eclipse.viatra.examples.cps.generator.queries.Queries
import org.eclipse.viatra.examples.cps.generator.utils.CPSModelBuilderUtil
import org.eclipse.viatra.examples.cps.generator.utils.StatsUtil
import org.eclipse.viatra.examples.cps.planexecutor.PlanExecutor
import org.eclipse.viatra.examples.cps.traceability.TraceabilityPackage
import org.eclipse.viatra.query.runtime.api.AdvancedViatraQueryEngine
import org.eclipse.viatra.query.runtime.api.GenericQueryGroup
import org.eclipse.viatra.query.runtime.emf.EMFScope
import org.eclipse.viatra.query.runtime.exception.ViatraQueryException
import org.eclipse.viatra.query.testing.core.RelativeQueryPerformanceTest
import org.junit.BeforeClass

class CPSRelativeQueryPerformanceTest extends RelativeQueryPerformanceTest {
    protected extension CPSModelBuilderUtil modelBuilder = new CPSModelBuilderUtil
    
    override getQueryGroup() throws ViatraQueryException {
        GenericQueryGroup.of(
//          CpsXformM2M.instance
            Queries.instance
        )
    }
    
    override getScope() throws ViatraQueryException {
        val rs = executeScenarioXformForConstraints(256)
        return new EMFScope(rs);
    }
    
    def executeScenarioXformForConstraints(int size) {  
        val seed = 11111
        val Random rand = new Random(seed)
//      val StatisticBasedCase benchmarkCase = new StatisticBasedCase(size, rand)
        val LowSynchCase benchmarkCase = new LowSynchCase(size, rand)
        val constraints = benchmarkCase.getConstraints()
        val cps2dep = prepareEmptyModel("testModel"+System.nanoTime)
        
        val CPSGeneratorInput input = new CPSGeneratorInput(seed, constraints, cps2dep.cps)
        var plan = CPSPlanBuilder.buildDefaultPlan
        
        var PlanExecutor<CPSFragment, CPSGeneratorInput> generator = new PlanExecutor()
        
        var generateTime = Stopwatch.createStarted
        var fragment = generator.process(plan, input)
        generateTime.stop
        info("Generating time: " + generateTime.elapsed(TimeUnit.MILLISECONDS) + " ms")
        
        val engine = AdvancedViatraQueryEngine.from(fragment.engine);
        
        StatsUtil.generateStatsForCPS(engine, fragment.modelRoot).log
        
        engine.dispose
        
        cps2dep.eResource.resourceSet
    }
    
    @BeforeClass
    def static void setupRootLogger() {
        doStandaloneEMFSetup()
    }
    
    def static doStandaloneEMFSetup() {
        Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put("*", new XMIResourceFactoryImpl());
        
        CyberPhysicalSystemPackage.eINSTANCE.eClass
        DeploymentPackage.eINSTANCE.eClass
        TraceabilityPackage.eINSTANCE.eClass
    }
}