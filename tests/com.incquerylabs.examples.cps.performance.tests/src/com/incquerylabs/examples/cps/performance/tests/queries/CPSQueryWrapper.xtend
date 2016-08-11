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
package com.incquerylabs.examples.cps.performance.tests.queries

import com.google.common.collect.ImmutableMap
import java.util.Map
import org.apache.log4j.Logger
import org.eclipse.viatra.examples.cps.traceability.CPSToDeployment
import org.eclipse.viatra.query.runtime.localsearch.matcher.integration.LocalSearchBackendFactory
import org.eclipse.viatra.query.runtime.localsearch.matcher.integration.LocalSearchHintKeys
import org.eclipse.viatra.query.runtime.matchers.backend.QueryEvaluationHint
import org.eclipse.viatra.query.runtime.rete.matcher.ReteBackendFactory
import org.eclipse.viatra.query.runtime.matchers.psystem.rewriters.IFlattenCallPredicate
import org.eclipse.viatra.query.runtime.matchers.psystem.basicenumerables.PositivePatternCall
import org.eclipse.viatra.query.runtime.localsearch.planner.cost.impl.VariableBindingBasedCostFunction

abstract class CPSQueryWrapper {
	protected extension Logger logger = Logger.getLogger("cps.query.CPSQueryWrapper")

	def void initializeQueryTool(CPSToDeployment cps2dep)

	def void executeQueryTool(Map<String, Object> parameterBinding)

	def void cleanupQueryTool()
}

enum QueryIdentifier {
	TRIGGER_PAIR,
	DUPLICATE_ACTION,
	REACHABLE_APP_INSTANCE
}

class QueryWrapperFactory {

	def static create() {
		return new QueryWrapperFactory
	}

	def createQueryWrapper(QueryWrapperIdentifier queryWrapperId, QueryIdentifier queryID) {
		
		val queryWrapper = switch queryWrapperId {
			case VIATRA_QUERY_RETE: {
				val hint = new QueryEvaluationHint(new ReteBackendFactory(), ImmutableMap.<String, Object>of())
	    	new ViatraQueryWrapper(hint, queryID)
			}
			case VIATRA_QUERY_LOCAL_SEARCH: {
				val hint = new QueryEvaluationHint(LocalSearchBackendFactory.INSTANCE, ImmutableMap.<String, Object>of())
	    	new ViatraQueryWrapper(hint, queryID)
			}
			case VIATRA_QUERY_LOCAL_SEARCH_NO_FLAT: {
				val IFlattenCallPredicate predicate = new IFlattenCallPredicate() {
					override shouldFlatten(PositivePatternCall positivePatternCall) {
						return false
					}
				}
				val hint = new QueryEvaluationHint(LocalSearchBackendFactory.INSTANCE, ImmutableMap.<String, Object>of(
                    LocalSearchHintKeys.FLATTEN_CALL_PREDICATE, predicate))
	    	new ViatraQueryWrapper(hint, queryID)
			}
			case VIATRA_QUERY_LOCAL_SEARCH_DUMB_PLANNER: {
				val hint = new QueryEvaluationHint(LocalSearchBackendFactory.INSTANCE, ImmutableMap.<String, Object>of(
                    LocalSearchHintKeys.PLANNER_COST_FUNCTION, new VariableBindingBasedCostFunction()
                    ))
        new ViatraQueryWrapper(hint, queryID)          
			}
			case VIATRA_QUERY_LOCAL_SEARCH_WO_INDEXER: {
				val hint = new QueryEvaluationHint(LocalSearchBackendFactory.INSTANCE, ImmutableMap.<String, Object>of(
                    LocalSearchHintKeys.ALLOW_INVERSE_NAVIGATION, Boolean.FALSE,
                    LocalSearchHintKeys.USE_BASE_INDEX, Boolean.FALSE,
                    LocalSearchHintKeys.PLANNER_COST_FUNCTION, new VariableBindingBasedCostFunction()
                    ))
        new ViatraQueryWrapper(hint, queryID)      
			}
		}
		
		return queryWrapper
	}


}

enum QueryWrapperIdentifier {
	VIATRA_QUERY_RETE,
	VIATRA_QUERY_LOCAL_SEARCH,
	VIATRA_QUERY_LOCAL_SEARCH_NO_FLAT,
	VIATRA_QUERY_LOCAL_SEARCH_DUMB_PLANNER,
	VIATRA_QUERY_LOCAL_SEARCH_WO_INDEXER
}
