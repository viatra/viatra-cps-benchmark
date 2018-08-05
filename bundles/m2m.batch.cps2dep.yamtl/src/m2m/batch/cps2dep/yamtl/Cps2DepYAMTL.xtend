package m2m.batch.cps2dep.yamtl

import java.util.ArrayList
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.ApplicationInstance
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.ApplicationType
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.CyberPhysicalSystem
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.CyberPhysicalSystemPackage
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.HostInstance
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.Identifiable
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.State
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.StateMachine
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.Transition
import org.eclipse.viatra.examples.cps.deployment.BehaviorState
import org.eclipse.viatra.examples.cps.deployment.BehaviorTransition
import org.eclipse.viatra.examples.cps.deployment.Deployment
import org.eclipse.viatra.examples.cps.deployment.DeploymentApplication
import org.eclipse.viatra.examples.cps.deployment.DeploymentBehavior
import org.eclipse.viatra.examples.cps.deployment.DeploymentElement
import org.eclipse.viatra.examples.cps.deployment.DeploymentHost
import org.eclipse.viatra.examples.cps.deployment.DeploymentPackage
import org.eclipse.viatra.examples.cps.traceability.CPSToDeployment
import org.eclipse.viatra.examples.cps.traceability.TraceabilityFactory
import org.eclipse.xtend.lib.annotations.Accessors
import yamtl.core.YAMTLModule
import yamtl.dsl.Helper
import yamtl.dsl.Rule

class Cps2DepYAMTL extends YAMTLModule {
	
	@Accessors
	CPSToDeployment mapping;
	
	val CPS = CyberPhysicalSystemPackage.eINSTANCE  
	val DEP = DeploymentPackage.eINSTANCE  
	

	/**
	 * Creates a new transformation instance. The input cyber physical system model is given in the mapping
	 * @param mapping the traceability model root
	 */
	new () {
		header().in('cps', CPS).out('dep', DEP)
		
				
		helperStore( newArrayList(
			new Helper('waitingTransitions') [
				val Map<String,List<Transition>> reachableWaitForTransitionsMap = newHashMap	 
				CPS.transition.allInstances.forEach[ transition |
					val targetTransition = transition as Transition
					if (targetTransition.action?.isWaitSignal) {
						val signalId = targetTransition.action.waitTransitionSignalId
						val list = reachableWaitForTransitionsMap.get(signalId)
						if (list === null) {
							reachableWaitForTransitionsMap.put(targetTransition.action.waitTransitionSignalId, newArrayList(targetTransition))
						} else {
							list.add(targetTransition)
						}
					} 
				]
				reachableWaitForTransitionsMap
			].build()
		))
		
		ruleStore( newArrayList(
			
			new Rule('CyberPhysicalSystem_2_Deployment')
				.priority(0)
				.in('cps', CPS.cyberPhysicalSystem).build()
				.out('out', DEP.deployment, [ 
					val cps = 'cps'.fetch as CyberPhysicalSystem
					val out = 'out'.fetch as Deployment
					
					val deploymentHosts = cps.hostTypes.map[instances].flatten
						.fetch as List<DeploymentHost>
					out.hosts += deploymentHosts 
				]).build()
				.build(),
			
			new Rule('HostInstance_2_DeploymentHost')
				.priority(0)
				.in('hostInstance', CPS.hostInstance).build()
				.out('out', DEP.deploymentHost, 
					[ 
						val hostInstance = 'hostInstance'.fetch as HostInstance
						val out = 'out'.fetch as DeploymentHost
						
						out.ip = hostInstance.nodeIp
						
						val deploymentApps = hostInstance.applications.fetch as List<DeploymentApplication>
						out.applications += deploymentApps
					]).build()
				.build(),
	
			new Rule('ApplicationInstance_2_DeploymentApplication')
				.priority(0)
				.in('appInstance', CPS.applicationInstance)
					.filter([
						val appInstance = 'appInstance'.fetch as ApplicationInstance
						appInstance.allocatedTo !== null
					])
					.build()
				.out('out', DEP.deploymentApplication,
					[ 
						val appInstance = 'appInstance'.fetch as ApplicationInstance
						val out = 'out'.fetch as DeploymentApplication
						
						out.id = appInstance.identifier
						// Transform state machines
						val behavior = appInstance.type.behavior.fetch('StateMachine_2_DeploymentBehavior') as DeploymentBehavior
						out.behavior = behavior
						
   						appInstance.trackApplicationInstance(out)
						
					]
				).build()
				.build(),
	
			new Rule('StateMachine_2_DeploymentBehavior')
				.lazy
				.in('stateMachine', CPS.stateMachine).build()
				.out('out', DEP.deploymentBehavior,
					[ 
						val stateMachine = 'stateMachine'.fetch as StateMachine
						val out = 'out'.fetch as DeploymentBehavior
						
						out.description = stateMachine.identifier

						// Transform states
						val behaviorStates = stateMachine.states.fetch('State_2_BehaviorState') as List<BehaviorState>
						out.states += behaviorStates 
						
						// Transform transitions
						var behaviorTransitions = new ArrayList<BehaviorTransition>
						for (state : stateMachine.states) {
							behaviorTransitions += 
								state.outgoingTransitions.fetch('Transition_2_BehaviorTransition') as List<BehaviorTransition>
						}
						out.transitions += behaviorTransitions
				
						// set current state
						val initial = stateMachine.states.findFirst[stateMachine.initial == it]
						val initialBehaviorState = initial.fetch('State_2_BehaviorState') as BehaviorState
						out.current = initialBehaviorState
						
						trackStateMachine(stateMachine, out)
					]
				).build()
				.build(),
	
			new Rule('State_2_BehaviorState')
				.uniqueLazy
				.in('state', CPS.state).build()
				.out('out', DEP.behaviorState,
					[ 
						val state = 'state'.fetch as State
						val out = 'out'.fetch as BehaviorState
						
						out.description = state.identifier
						out.outgoing += state.outgoingTransitions.fetch('Transition_2_BehaviorTransition') as List<BehaviorTransition> 

						trackState(state,out)
					]
				).build()
				.build(),
	
			new Rule('Transition_2_BehaviorTransition')
				.uniqueLazy
				.in('transition', CPS.transition)
					.filter( [
						val transition = 'transition'.fetch as Transition 
						transition.targetState !== null
					]).build()
				.out('out', DEP.behaviorTransition, 
					[ 
						val transition = 'transition'.fetch as Transition
						val out = 'out'.fetch as BehaviorTransition
						
						out.description = transition.identifier
		
						val targetBehaviorState = transition.targetState.fetch('State_2_BehaviorState') as BehaviorState
						out.to = targetBehaviorState
						
						trackTransition(transition,out)
					]
				).build()
				.build(),
				
			new Rule('Transition_2_BehaviorTransition_Trigger')
				.isTransient
				.in('transition', CPS.transition)
					.filter( [
						val transition = 'transition'.fetch as Transition 
						transition.targetState !== null
						&&
						transition.action?.isSignal
					]).build()
				.out('out', DEP.behaviorTransition, 
					[ 
						val sendingTransition = 'transition'.fetch as Transition
						
						val waitingTransitions = 'waitingTransitions'.fetch as Map<String,List<Transition>> 
						val waitingTransitionsList = waitingTransitions.get(sendingTransition.action.signalId)
						
						// triggers have to be processed at the end
						// because we need to access generated behaviorTransitions 
						// (in case several behaviors were obtained from the same state machine)
						if (waitingTransitionsList!==null) {
							for (receivingTransition: waitingTransitionsList) {
								if (receivingTransition.belongsToApplicationType(sendingTransition.action.appTypeId)) {
								
									val sendingBTransitionList = transitionToBTransitionList.get(sendingTransition)
									val receivingBTransitionList = transitionToBTransitionList.get(receivingTransition)
									
									if (sendingBTransitionList!==null) {
										sendingBTransitionList.forEach[ senderBehaviorTransition |
			
											if (receivingBTransitionList !== null) {
												val reachableTransitionList = newArrayList
				
												for (receiverBehaviorTransition: receivingBTransitionList) {
													val senderDepApp = senderBehaviorTransition.eContainer.eContainer as DeploymentApplication
													val senderAppIntance = depAppToAppInstance.get(senderDepApp)
													
													val receiverDepApp = receiverBehaviorTransition.eContainer.eContainer as DeploymentApplication
													val receiverAppIntance = depAppToAppInstance.get(receiverDepApp)
													
													if (senderAppIntance.reaches(receiverAppIntance)) {
														reachableTransitionList.add(receiverBehaviorTransition)
													}
												}
				
												senderBehaviorTransition.trigger +=  reachableTransitionList
											}
										]
									}
								}
							}
						}		
					]
				).build()
				.build()
	
		))
		
		if (debug) println("constructor")
	}
	
	
	
		
	/** 
	 * HELPERS: fetching reachable application types
	 */
	@Accessors
	val Map<DeploymentApplication,ApplicationInstance> depAppToAppInstance = newHashMap
	def trackApplicationInstance(ApplicationInstance appInstance, DeploymentApplication depApp) {
		depAppToAppInstance.put(depApp, appInstance)
	}

	@Accessors
	// ApplicationType.id |-> < signalId |-> List<ReceivingTransition> >
	Map<String,Map<String,List<Transition>>> reachableWaitForTransitionsMap = newHashMap	 
	 
	 
	def reachableWaitForTransitions(ApplicationType from) {
		var map = reachableWaitForTransitionsMap.get(from.identifier)
		if (map === null) {
			map = newLinkedHashMap

			val reachableAppInstancesSet = newLinkedHashSet
			for (appInstance : from.instances) {
				if (appInstance.allocatedTo!==null)
					reachableAppInstancesSet.addAll(appInstance.allocatedTo.applications)
				if (appInstance.allocatedTo?.communicateWith !== null) {
					reachableAppInstancesSet += appInstance.allocatedTo?.communicateWith.flatMap[ hostInstance |
						hostInstance.applications
					]
				}
			}
			
			for (receivingAppInstance : reachableAppInstancesSet) {
				// communication to directly reachable sites
				if (receivingAppInstance.type.behavior !== null) {
					for (transition: receivingAppInstance.type.behavior.states.flatMap[it.outgoingTransitions]) {
						if (transition.action?.isWaitSignal) {
							val signalId = transition.action.waitTransitionSignalId
							val list = map.get(signalId)
							if (list === null) {
								map.put(transition.action.waitTransitionSignalId, newArrayList(transition))
							} else {
								list.add(transition)
							}
						}
					}
				}
			}

			reachableWaitForTransitionsMap.put(from.identifier, map)
			return map
		}
		map
	}
	
	def reaches(ApplicationInstance fromApp, ApplicationInstance toApp) {
		fromApp.allocatedTo !== null
		&& 
		(
			fromApp.allocatedTo == toApp.allocatedTo
			||
			fromApp.allocatedTo.communicateWith.contains(toApp.allocatedTo)
		)
	}
	
	
	def applicationType(Transition t) {
		// transition -> containing state -> state machine -> application type
		t.eContainer.eContainer.eContainer as ApplicationType
	}
	
	def belongsToApplicationType(Transition t, String appTypeId) {
		// transition -> containing state -> state machine -> application type
		val appType = t.eContainer.eContainer.eContainer as ApplicationType
		appType.identifier == appTypeId
	}


	def isSignal(String action) {
		action.startsWith('sendSignal')
	}
	def isWaitSignal(String action) {
		action.startsWith("waitForSignal")
	}
	def isWaitSignal(String action, String signalId) {
//			println('''isWaitSignal: visited action «action» against waitForSignal(«signalId»)''')
		val expectedAction = '''waitForSignal(«signalId»)'''
		action == expectedAction
	}
	def String getAppTypeId(String action) {
		val String[] contents = action.substring(action.indexOf('(')+1,action.lastIndexOf(')')).split(',') 
		contents.get(0).trim()
	}
	def String getSignalId(String action) {
		val String[] contents = action.substring(action.indexOf('(')+1,action.lastIndexOf(')')).split(',') 
		contents.get(1).trim()
	}
	def String getWaitTransitionSignalId(String action) {
		val String[] contents = action.substring(action.indexOf('(')+1,action.lastIndexOf(')')).split(',') 
		contents.get(0).trim()
	}

	def saveTraceModel(String traceModelPath) {
		saveModel(traceModelPath, #[mapping])
	}

	def getTraceModel() {
		mapping.fetchCPS2DepTraces
	}
	
	/**
	 * TRACEABILITY MODEL PERSISTENCE
	 */
	@Accessors
	val Map<Transition,Set<BehaviorTransition>> transitionToBTransitionList = newHashMap
	
	def trackTransition(Transition t, BehaviorTransition bt) {
		val list = transitionToBTransitionList.get(t)
		if (list===null) {
			transitionToBTransitionList.put(t, newLinkedHashSet(bt))
		} else {
			list.add(bt)
		}
	}
	
	@Accessors
	val Map<State,Set<BehaviorState>> stateToBStateList = newHashMap
	
	def trackState(State s, BehaviorState bs) {
		val list = stateToBStateList.get(s)
		if (list===null) {
			stateToBStateList.put(s, newLinkedHashSet(bs))
		} else {
			list.add(bs)
		}
	}

	@Accessors
	val Map<StateMachine,Set<DeploymentBehavior>> smToBehList = newHashMap
	
	def trackStateMachine(StateMachine sm, DeploymentBehavior db) {
		val list = smToBehList.get(sm)
		if (list===null) {
			smToBehList.put(sm, newLinkedHashSet(db))
		} else {
			list.add(db)
		}
	}
	
	def void fetchCPS2DepTraces(CPSToDeployment cps2dep) {
		val Set<String> visitedStateMachineIds = newHashSet
		val Set<String> visitedStateIds = newHashSet
		val Set<String> visitedTransitionIds = newHashSet
		
		for (redux : this.eventPool) {
			if (!CyberPhysicalSystem.isInstance(redux.defaultInObject)) {
				val sourceObject = redux.defaultInObject
				
				redux.targetMatch.match.forEach[outName, pair |
					switch (redux.rule.name) {
						case 'StateMachine_2_DeploymentBehavior': {
							val sm = sourceObject as StateMachine
							if (!visitedStateMachineIds.contains(sm.identifier)) {
								visitedStateMachineIds.add(sm.identifier)
								val bStateMachineList = smToBehList.get(sm)
								
								val trace = TraceabilityFactory.eINSTANCE.createCPS2DeploymentTrace
								trace.cpsElements.add(sourceObject as Identifiable)
								trace.deploymentElements.addAll(bStateMachineList)
								cps2dep.traces.add(trace)
							}
						}
						case 'State_2_BehaviorState': {
							val state = sourceObject as State
							if (!visitedStateIds.contains(state.identifier)) {
								visitedStateIds.add(state.identifier)
								val bStateList = stateToBStateList.get(state)
								
								val trace = TraceabilityFactory.eINSTANCE.createCPS2DeploymentTrace
								trace.cpsElements.add(sourceObject as Identifiable)
								trace.deploymentElements.addAll(bStateList)
								cps2dep.traces.add(trace)
							}
						}
						case 'Transition_2_BehaviorTransition': {
							val transition = sourceObject as Transition
							if (!visitedTransitionIds.contains(transition.identifier)) {
								visitedTransitionIds.add(transition.identifier)
								val bTransitionList = transitionToBTransitionList.get(transition)
								
								val trace = TraceabilityFactory.eINSTANCE.createCPS2DeploymentTrace
								trace.cpsElements.add(sourceObject as Identifiable)
								trace.deploymentElements.addAll(bTransitionList)
								cps2dep.traces.add(trace)
							}
						}
						case 'Transition_2_BehaviorTransition_Trigger': {}
						default: {
							val targetObject = pair.value
								
							val trace = TraceabilityFactory.eINSTANCE.createCPS2DeploymentTrace
							trace.cpsElements.add(sourceObject as Identifiable)
							trace.deploymentElements.addAll(targetObject as DeploymentElement)
							cps2dep.traces.add(trace)
						}
					}
					
					
				]
			}
		}
	}

}