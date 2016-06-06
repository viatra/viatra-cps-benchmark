/*******************************************************************************
 * Copyright (c) 2014-2016 IncQuery Labs Ltd.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Akos Horvath, Abel Hegedus, Zoltan Ujhelyi, Peter Lunk - initial API and implementation
 *******************************************************************************/
package com.incquerylabs.examples.cps.integration.performance.eventdriven;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.viatra.examples.cps.integration.eventdriven.M2MScheduledEventDrivenViatraTransformationStep;
import org.eclipse.viatra.examples.cps.traceability.CPSToDeployment;
import org.eclipse.viatra.examples.cps.xform.m2m.incr.viatra.CPS2DeploymentTransformationViatra;
import org.eclipse.viatra.query.runtime.api.AdvancedViatraQueryEngine;
import org.eclipse.viatra.query.runtime.emf.EMFScope;
import org.eclipse.viatra.query.runtime.exception.ViatraQueryException;
import org.eclipse.viatra.transformation.evm.specific.event.ViatraQueryEventRealm;

import eu.mondo.sam.core.metrics.MemoryMetric;
import eu.mondo.sam.core.metrics.TimeMetric;
import eu.mondo.sam.core.results.BenchmarkResult;
import eu.mondo.sam.core.results.PhaseResult;

public class PerformanceEventDrivenViatraTransformationStep extends M2MScheduledEventDrivenViatraTransformationStep {
    @Override
    public void initialize(IWorkflowContext ctx) {

        this.context = ctx;
        CPSToDeployment cps2dep = (CPSToDeployment) ctx.get("model");
        BenchmarkResult benchmarkResult = (BenchmarkResult) ctx.get("benchmarkresult");
        
        ////////////////////////////////////
        //////   Transformation initialization phase
        ////////////////////////////////////
        
        PhaseResult initResult = new PhaseResult();
        initResult.setPhaseName("Initialization");
        TimeMetric initTimer = new TimeMetric("Time");
        
        initTimer.startMeasure();	
        try {
            engine = AdvancedViatraQueryEngine.createUnmanagedEngine(new EMFScope(cps2dep.eResource().getResourceSet()));
            transformation = new CPS2DeploymentTransformationViatra();
            transformation.setScheduler(factory);
            transformation.initialize(cps2dep,engine);
        } catch (ViatraQueryException e) {
            e.printStackTrace();
        }
        initTimer.stopMeasure();
        initResult.addMetrics(initTimer);
        benchmarkResult.addResults(initResult);
        
        ctx.put("engine", engine);
        System.out.println("Initialized model-to-model transformation");
 
    }

    public void doEexecute() {
        BenchmarkResult benchmarkResult = (BenchmarkResult) context.get("benchmarkresult");
        
        ////////////////////////////////////
        //////  MTM Transformation phase
        ////////////////////////////////////
        
        PhaseResult mtmResult = new PhaseResult();
        mtmResult.setPhaseName("M2MTransformation");
        TimeMetric mtmTimer = new TimeMetric("Time");
        MemoryMetric mtmMemory = new MemoryMetric("Memory");
        
        mtmTimer.startMeasure();
        factory.run();
     
        while(!factory.isFinished()){
            try {
                Thread.sleep(10);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        mtmTimer.stopMeasure();
        mtmMemory.measure();
        
        mtmResult.addMetrics(mtmTimer,mtmMemory);
        benchmarkResult.addResults(mtmResult);
        System.out.println("Model-to-model transformation executed");
    }
}
