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
package com.incquerylabs.examples.cps.performance.tests.config.cases

import java.util.Random

class CaseFactory {
	
	def static create() {
		return new CaseFactory
	}
	
	def createCase(CaseIdentifier caseId, int scale, Random random) {
		switch caseId {
			case CLIENT_SERVER: {
				new ClientServerCase(scale, random)
			}
			case ADVANCED_CLIENT_SERVER: {
				new AdvancedClientServerCase(scale, random)
			}
			case LOW_SYNCH: {
				new LowSynchCase(scale, random)
			}
			case PUBLISH_SUBSCRIBE: {
				new PublishSubscribeCase(scale, random)
			}
			case SIMPLE_SCALING: {
				new SimpleScalingCase(scale, random)
			}
			case STATISTICS_BASED: {
				new StatisticBasedCase(scale, random)
			}
		}
	}
}

enum CaseIdentifier {
	
	ADVANCED_CLIENT_SERVER,
	CLIENT_SERVER,
	LOW_SYNCH,
	PUBLISH_SUBSCRIBE,
	SIMPLE_SCALING,
	STATISTICS_BASED
	
}