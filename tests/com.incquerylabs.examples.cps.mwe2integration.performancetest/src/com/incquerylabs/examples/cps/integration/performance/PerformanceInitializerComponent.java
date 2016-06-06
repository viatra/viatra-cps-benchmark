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

import java.io.File;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.viatra.examples.cps.generator.CPSPlanBuilder;
import org.eclipse.viatra.examples.cps.generator.dtos.CPSFragment;
import org.eclipse.viatra.examples.cps.generator.dtos.CPSGeneratorInput;
import org.eclipse.viatra.examples.cps.generator.dtos.GeneratorPlan;
import org.eclipse.viatra.examples.cps.generator.queries.Validation;
import org.eclipse.viatra.examples.cps.generator.utils.CPSModelBuilderUtil;
import org.eclipse.viatra.examples.cps.integration.InitializerComponent;
import org.eclipse.viatra.examples.cps.planexecutor.PlanExecutor;
import org.eclipse.viatra.examples.cps.traceability.CPSToDeployment;
import org.eclipse.viatra.examples.cps.xform.serializer.DefaultSerializer;
import org.eclipse.viatra.examples.cps.xform.serializer.javaio.JavaIOBasedFileAccessor;
import org.eclipse.viatra.query.runtime.exception.ViatraQueryException;

import eu.mondo.sam.core.metrics.MemoryMetric;
import eu.mondo.sam.core.metrics.TimeMetric;
import eu.mondo.sam.core.results.BenchmarkResult;
import eu.mondo.sam.core.results.CaseDescriptor;
import eu.mondo.sam.core.results.JsonSerializer;
import eu.mondo.sam.core.results.PhaseResult;

public class PerformanceInitializerComponent extends InitializerComponent {
    protected String toolName;
    
    public String getToolName() {
        return toolName;
    }

    public void setToolName(String toolName) {
        this.toolName = toolName;
    }
    

    @Override
    public void invoke(IWorkflowContext ctx) {
        CPSModelBuilderUtil modelBuilderUtil = new CPSModelBuilderUtil();
        DefaultSerializer serializer = new DefaultSerializer();
        
        
        ////////////////////////////////////
        //////   EMF initialization phase
        ////////////////////////////////////
        
        Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put(Resource.Factory.Registry.DEFAULT_EXTENSION,
                new XMIResourceFactoryImpl());

        CPSToDeployment cps2dep = modelBuilderUtil.preparePersistedCPSModel(getModelDir() + "/" + getModelName(), getModelName());
        
        ////////////////////////////////////
        //////   Generation phase
        ////////////////////////////////////
        PhaseResult generatorResult = new PhaseResult();
        generatorResult.setPhaseName("Generation");
        TimeMetric generatorTimer = new TimeMetric("Time");
        MemoryMetric generatorMemory = new MemoryMetric("Memory");
        if(ctx.get("modelsize")!= null){
            modelSize = (int) ctx.get("modelsize");
        }
        
        
        try {

            CPSGeneratorInput input = new CPSGeneratorInput(getSeed(), getConstraints(getModelSize()), cps2dep.getCps());
            GeneratorPlan plan = CPSPlanBuilder.buildCharacteristicBasedPlan();
            PlanExecutor<CPSFragment, CPSGeneratorInput> generator = new PlanExecutor<CPSFragment, CPSGeneratorInput>();
            
            generatorTimer.startMeasure();
            CPSFragment fragment = generator.process(plan, input);
            generatorTimer.stopMeasure();
            generatorMemory.measure();
            
            Validation.instance().prepare(fragment.getEngine());

            fragment.getEngine().dispose();
            
            generatorResult.addMetrics(generatorTimer, generatorMemory);
            

        } catch (ViatraQueryException e) {
            e.printStackTrace();
        }

        serializer.createProject(getOutputProjectLocation(), getOutputProjectName(), new JavaIOBasedFileAccessor());
        File project = new File(getOutputProjectLocation(), getOutputProjectName());
        File srcFolder = new File(project.getAbsolutePath(), "src");
        for(File file : srcFolder.listFiles()){
            file.delete();
        }        
        
        JsonSerializer.setResultPath(project.getAbsolutePath()+"\\results\\json\\");
        
        BenchmarkResult benchmarkResult = new BenchmarkResult();
        benchmarkResult.addResults(generatorResult);
        
        CaseDescriptor descriptor = new CaseDescriptor();
                descriptor.setTool(toolName);
                descriptor.setCaseName("1");
                descriptor.setSize(getModelSize());
                descriptor.setRunIndex(0);
                descriptor.setScenario("1");
        benchmarkResult.setCaseDescriptor(descriptor);

        ctx.put("model", cps2dep);
        ctx.put("benchmarkresult", benchmarkResult);
        ctx.put("projectname", getOutputProjectName());
        ctx.put("projectPath", project.getAbsolutePath());
        ctx.put("folder", srcFolder.getAbsolutePath());
    }


}
