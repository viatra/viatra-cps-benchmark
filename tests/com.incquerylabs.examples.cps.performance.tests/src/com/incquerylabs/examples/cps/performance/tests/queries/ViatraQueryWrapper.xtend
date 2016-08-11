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

import java.util.Map
import org.eclipse.viatra.examples.cps.model.validation.Rules
import org.eclipse.viatra.examples.cps.traceability.CPSToDeployment
import org.eclipse.viatra.query.runtime.api.AdvancedViatraQueryEngine
import org.eclipse.viatra.query.runtime.api.IQuerySpecification
import org.eclipse.viatra.query.runtime.api.ViatraQueryMatcher
import org.eclipse.viatra.query.runtime.emf.EMFScope
import org.eclipse.viatra.query.runtime.matchers.backend.QueryEvaluationHint
import org.eclipse.viatra.examples.cps.xform.m2m.batch.eiq.queries.CpsXformM2M

class ViatraQueryWrapper extends CPSQueryWrapper {
	
	AdvancedViatraQueryEngine engine
	// TODO raw type used since that is the only error-free combination
	IQuerySpecification<? extends ViatraQueryMatcher> querySpecification
	QueryEvaluationHint hint

	new(QueryEvaluationHint hint, QueryIdentifier queryId) {
		this.hint = hint
		this.querySpecification = switch queryId {
			case TRIGGER_PAIR: {
				CpsXformM2M.instance.triggerPair
			}
			case DUPLICATE_ACTION: {
				Rules.instance.multipleTransitionsWithSameAction
			}
			case REACHABLE_APP_INSTANCE: {
				Rules.instance.reachableAppInstance
			}
		}
	}
	
	override initializeQueryTool(CPSToDeployment cps2dep) {
		engine = AdvancedViatraQueryEngine.createUnmanagedEngine(new EMFScope(cps2dep.eResource.resourceSet));
	}
	
	override executeQueryTool(Map<String,Object> parameterBinding) {
		val matcher = engine.getMatcher(querySpecification, hint)
		val match = matcher.newEmptyMatch()
		parameterBinding.forEach[paramName, paramValue|
			match.set(paramName, paramValue)
		]
		val matches = matcher.getAllMatches(match)
		info('''«querySpecification.fullyQualifiedName» has «matches.size» matches for «match» binding''')
	}
	
	override cleanupQueryTool() {
		if (engine != null) {
			engine.dispose
		}
		engine = null
	}
	
}