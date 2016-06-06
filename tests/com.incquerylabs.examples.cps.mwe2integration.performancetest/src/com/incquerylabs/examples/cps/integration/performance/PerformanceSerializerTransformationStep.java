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

import java.io.IOException;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.viatra.examples.cps.integration.SerializerTransformationStep;
import org.eclipse.viatra.examples.cps.xform.serializer.DefaultSerializer;
import org.eclipse.viatra.examples.cps.xform.serializer.javaio.JavaIOBasedFileAccessor;

import eu.mondo.sam.core.metrics.MemoryMetric;
import eu.mondo.sam.core.metrics.TimeMetric;
import eu.mondo.sam.core.results.BenchmarkResult;
import eu.mondo.sam.core.results.PhaseResult;

public class PerformanceSerializerTransformationStep extends SerializerTransformationStep {  

    private boolean firstRun = true;
    
    @Override
    public void initialize(IWorkflowContext ctx) {
        this.context = ctx;
        System.out.println("Initialized serializer");
        serializer = new DefaultSerializer();
        sourceFolder = (String) ctx.get("folder"); 
    }

    public void doExecute() {
        ////////////////////////////////////
        //////   Serialization phase
        ////////////////////////////////////
        
        //Mondo-sam metrics
        PhaseResult serializerResult = new PhaseResult();
        serializerResult.setPhaseName("Serialization");
        TimeMetric serializerTimer = new TimeMetric("Time");
        MemoryMetric serializerMemory = new MemoryMetric("Memory");

        serializerTimer.startMeasure();
        ListBasedOutputProvider provider = new ListBasedOutputProvider(m2tOutput);
        serializer.serialize(sourceFolder, provider, new JavaIOBasedFileAccessor());
        serializerTimer.stopMeasure();
        serializerMemory.measure();
        
        
        BenchmarkResult benchmarkResult = (BenchmarkResult) context.get("benchmarkresult");
        serializerResult.addMetrics(serializerTimer,serializerMemory);
        benchmarkResult.addResults(serializerResult);
        System.out.println("Serialization completed");
        
        if(firstRun){
            firstRun = false;
        } else {
            int i = 0;
            for (PhaseResult result : benchmarkResult.getPhaseResults()) {
                result.setSequence(i);
                i++;
            }
            try {
                benchmarkResult.publishResults();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
