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
package com.incquerylabs.examples.cps.integration.performance;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.viatra.examples.cps.integration.M2TDistributedTransformationStep;
import org.eclipse.viatra.examples.cps.xform.m2t.api.ChangeM2TOutputProvider;
import org.eclipse.viatra.examples.cps.xform.m2t.distributed.CodeGenerator;
import org.eclipse.viatra.query.runtime.api.AdvancedViatraQueryEngine;

import eu.mondo.sam.core.metrics.MemoryMetric;
import eu.mondo.sam.core.metrics.TimeMetric;
import eu.mondo.sam.core.results.BenchmarkResult;
import eu.mondo.sam.core.results.PhaseResult;

public class PerformanceM2TDistributedTransformationStep extends M2TDistributedTransformationStep {   
    
    @Override
    public void initialize(IWorkflowContext ctx) {
        System.out.println("Initialized model-to-text transformation");
        this.context = ctx;
        engine = (AdvancedViatraQueryEngine) ctx.get("engine");
        projectName = (String) ctx.get("projectname");
        sourceFolder = (String) ctx.get("folder");
        generator = new CodeGenerator(projectName,engine,true);
        
    }

    @Override
    public void doExecute() {
        ////////////////////////////////////
        //////   M2T Transformation phase
        ////////////////////////////////////
        
        //Execution of M2T transformation with mondo-sam metrics
        PhaseResult m2tResult = new PhaseResult();
        m2tResult.setPhaseName("M2TTransformation");
        TimeMetric m2tTimer = new TimeMetric("Time");
        MemoryMetric m2tMemory = new MemoryMetric("Memory");
        
        m2tTimer.startMeasure();
        ChangeM2TOutputProvider provider = new ChangeM2TOutputProvider(delta, generator, sourceFolder);
        m2tTimer.stopMeasure();
        m2tMemory.measure();
        output = provider.generateChanges();
        
                
        BenchmarkResult benchmarkResult = (BenchmarkResult) context.get("benchmarkresult");
        m2tResult.addMetrics(m2tTimer,m2tMemory);
        benchmarkResult.addResults(m2tResult);
        
        System.out.println("Model-to-text transformation executed");
    }

}
