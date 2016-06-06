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

package com.incquerylabs.examples.cps.performance.tests.config.phases

import org.eclipse.viatra.examples.cps.generator.CPSPlanBuilder
import org.eclipse.viatra.examples.cps.generator.interfaces.ICPSConstraints

class StatisticsBasedGenerationPhase extends GenerationPhase {

	new(String name, ICPSConstraints constraints) {
		super(name, constraints)
	}

	override protected getPlan() {
		CPSPlanBuilder.buildCharacteristicBasedPlan
	}

}