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
package com.incquerylabs.examples.cps.integration.performance.batch;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.viatra.examples.cps.integration.batch.M2MBatchViatraTransformationStep;
import org.eclipse.viatra.examples.cps.traceability.CPSToDeployment;
import org.eclipse.viatra.examples.cps.xform.m2m.batch.viatra.CPS2DeploymentBatchViatra;
import org.eclipse.viatra.query.runtime.api.AdvancedViatraQueryEngine;
import org.eclipse.viatra.query.runtime.emf.EMFScope;
import org.eclipse.viatra.query.runtime.exception.ViatraQueryException;

import eu.mondo.sam.core.metrics.MemoryMetric;
import eu.mondo.sam.core.metrics.TimeMetric;
import eu.mondo.sam.core.results.BenchmarkResult;
import eu.mondo.sam.core.results.PhaseResult;

public class PerformanceBatchViatraTransformationStep extends M2MBatchViatraTransformationStep {

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
            transformation = new CPS2DeploymentBatchViatra();
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

    public void execute() {
        BenchmarkResult benchmarkResult = (BenchmarkResult) context.get("benchmarkresult");
                
        ////////////////////////////////////
        //////  MTM Transformation phase
        ////////////////////////////////////
        
        PhaseResult mtmResult = new PhaseResult();
        mtmResult.setPhaseName("M2MTransformation");
        TimeMetric mtmTimer = new TimeMetric("Time");
        MemoryMetric mtmMemory = new MemoryMetric("Memory");
        
        mtmTimer.startMeasure();
        transformation.execute();
        mtmTimer.stopMeasure();
        mtmMemory.measure();
        
        mtmResult.addMetrics(mtmTimer,mtmMemory);
        benchmarkResult.addResults(mtmResult);
        
        System.out.println("Model-to-model transformation executed");
    }
}
