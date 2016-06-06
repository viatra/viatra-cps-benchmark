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
package com.incquerylabs.examples.cps.integration.performance.test;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.mwe2.language.Mwe2StandaloneSetup;
import org.eclipse.emf.mwe2.launch.runtime.Mwe2Runner;
import org.eclipse.emf.mwe2.runtime.workflow.WorkflowContextImpl;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;

import com.google.inject.Injector;

@RunWith(Parameterized.class)
public class MWEPerformanceTest {
    public static final String batchpath= "src/org/eclipse/incquery/examples/cps/integration/performance/batch/BatchTransformation.mwe2";
    public static final String edControllablepath= "src/org/eclipse/incquery/examples/cps/integration/performance/eventdriven/PerformanceEventDrivenTransformation.mwe2";
    
    @Parameters
    public static Collection<Object[]> data() {
        return Arrays.asList(new Object[][] {  
                 { batchpath, 1 }, 
                 { batchpath, 1 }, 
                 { batchpath, 2 }, 
                 { batchpath, 4 }, 
                 { batchpath, 8 }, 
                 { batchpath, 16 }, 
                 { batchpath, 32 }, 
                 { edControllablepath, 1 }, 
                 { edControllablepath, 1 }, 
                 { edControllablepath, 2 }, 
                 { edControllablepath, 4 }, 
                 { edControllablepath, 8 }, 
                 { edControllablepath, 16 }, 
                 { edControllablepath, 32 }, 

           });
    }
    
    private String mweFile;
    private int modelscale;

    public MWEPerformanceTest(String mweFile, int modelscale) {
        this.mweFile= mweFile;
        this.modelscale= modelscale;
    }

    @Test
    public void test() {
        Injector injector = new Mwe2StandaloneSetup().createInjectorAndDoEMFRegistration();
        Mwe2Runner mweRunner = injector.getInstance(Mwe2Runner.class);
        WorkflowContextImpl context = new WorkflowContextImpl();
        context.put("modelsize", modelscale);
        
        mweRunner.run(
                URI.createURI(mweFile), 
                new HashMap<String,String>(), context
        );
        
    }

}
