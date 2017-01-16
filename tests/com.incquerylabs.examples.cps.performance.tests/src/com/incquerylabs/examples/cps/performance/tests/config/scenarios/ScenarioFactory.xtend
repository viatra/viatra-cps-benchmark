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
package com.incquerylabs.examples.cps.performance.tests.config.scenarios

import com.incquerylabs.examples.cps.performance.tests.config.cases.BenchmarkCase

class ScenarioFactory {
	
	def static create() {
		return new ScenarioFactory
	}
	
	def createScenario(ScenarioIdentifier scenarioId, BenchmarkCase benchmarkCase, int runIndex, String toolName) {
		val scenario = switch scenarioId {
			case TOOLCHAIN_BATCH: {
				new ToolChainPerformanceBatchScenario(benchmarkCase)
			}
			case TOOLCHAIN_INCREMENTAL: {
				new ToolChainPerformanceIncrementalScenario(benchmarkCase)
			}
			case M2M_ONLY: {
				new BasicXformScenario(benchmarkCase)
			}
			case M2M_PERSIST: {
				new XformPersistScenario(benchmarkCase)
			}
			case QUERY: {
				throw new UnsupportedOperationException("Query scenario not yet implemented")
			}
		}
		scenario.runIndex = runIndex
		scenario.tool = toolName
		return scenario
	}
	
}

enum ScenarioIdentifier {
	TOOLCHAIN_BATCH,
	TOOLCHAIN_INCREMENTAL,
	M2M_ONLY,
	M2M_PERSIST,
	QUERY
}