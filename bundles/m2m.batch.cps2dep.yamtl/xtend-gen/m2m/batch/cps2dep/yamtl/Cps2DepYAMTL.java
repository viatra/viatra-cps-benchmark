package m2m.batch.cps2dep.yamtl;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.ApplicationInstance;
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.ApplicationType;
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.CyberPhysicalSystem;
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.CyberPhysicalSystemPackage;
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.HostInstance;
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.HostType;
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.Identifiable;
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.State;
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.StateMachine;
import org.eclipse.viatra.examples.cps.cyberPhysicalSystem.Transition;
import org.eclipse.viatra.examples.cps.deployment.BehaviorState;
import org.eclipse.viatra.examples.cps.deployment.BehaviorTransition;
import org.eclipse.viatra.examples.cps.deployment.Deployment;
import org.eclipse.viatra.examples.cps.deployment.DeploymentApplication;
import org.eclipse.viatra.examples.cps.deployment.DeploymentBehavior;
import org.eclipse.viatra.examples.cps.deployment.DeploymentElement;
import org.eclipse.viatra.examples.cps.deployment.DeploymentHost;
import org.eclipse.viatra.examples.cps.deployment.DeploymentPackage;
import org.eclipse.viatra.examples.cps.traceability.CPS2DeploymentTrace;
import org.eclipse.viatra.examples.cps.traceability.CPSToDeployment;
import org.eclipse.viatra.examples.cps.traceability.TraceabilityFactory;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.CollectionExtensions;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Pure;
import yamtl.core.MatchMap;
import yamtl.core.OutputElement;
import yamtl.core.YAMTLHelper;
import yamtl.core.YAMTLModule;
import yamtl.core.YAMTLRule;
import yamtl.dsl.Helper;
import yamtl.dsl.Rule;

@SuppressWarnings("all")
public class Cps2DepYAMTL extends YAMTLModule {
  @Accessors
  private CPSToDeployment mapping;
  
  private final CyberPhysicalSystemPackage CPS = CyberPhysicalSystemPackage.eINSTANCE;
  
  private final DeploymentPackage DEP = DeploymentPackage.eINSTANCE;
  
  /**
   * Creates a new transformation instance. The input cyber physical system model is given in the mapping
   * @param mapping the traceability model root
   */
  public Cps2DepYAMTL() {
    this.header().in("cps", this.CPS).out("dep", this.DEP);
    final Function0<Object> _function = () -> {
      Map<String, List<Transition>> _xblockexpression = null;
      {
        final Map<String, List<Transition>> reachableWaitForTransitionsMap = CollectionLiterals.<String, List<Transition>>newHashMap();
        final Consumer<EObject> _function_1 = (EObject transition) -> {
          final Transition targetTransition = ((Transition) transition);
          String _action = targetTransition.getAction();
          boolean _isWaitSignal = false;
          if (_action!=null) {
            _isWaitSignal=this.isWaitSignal(_action);
          }
          if (_isWaitSignal) {
            final String signalId = this.getWaitTransitionSignalId(targetTransition.getAction());
            final List<Transition> list = reachableWaitForTransitionsMap.get(signalId);
            if ((list == null)) {
              reachableWaitForTransitionsMap.put(this.getWaitTransitionSignalId(targetTransition.getAction()), CollectionLiterals.<Transition>newArrayList(targetTransition));
            } else {
              list.add(targetTransition);
            }
          }
        };
        this.locationUtil.allInstances(this.CPS.getTransition()).forEach(_function_1);
        _xblockexpression = reachableWaitForTransitionsMap;
      }
      return _xblockexpression;
    };
    this.helperStore(CollectionLiterals.<YAMTLHelper>newArrayList(
      new Helper("waitingTransitions", _function).build()));
    final Procedure0 _function_1 = () -> {
      Object _fetch = this.fetchUtil.fetch("cps");
      final CyberPhysicalSystem cps = ((CyberPhysicalSystem) _fetch);
      Object _fetch_1 = this.fetchUtil.fetch("out");
      final Deployment out = ((Deployment) _fetch_1);
      final Function1<HostType, EList<HostInstance>> _function_2 = (HostType it) -> {
        return it.getInstances();
      };
      Object _fetch_2 = this.fetchUtil.fetch(Iterables.<HostInstance>concat(ListExtensions.<HostType, EList<HostInstance>>map(cps.getHostTypes(), _function_2)));
      final List<DeploymentHost> deploymentHosts = ((List<DeploymentHost>) _fetch_2);
      EList<DeploymentHost> _hosts = out.getHosts();
      Iterables.<DeploymentHost>addAll(_hosts, deploymentHosts);
    };
    final Procedure0 _function_2 = () -> {
      Object _fetch = this.fetchUtil.fetch("hostInstance");
      final HostInstance hostInstance = ((HostInstance) _fetch);
      Object _fetch_1 = this.fetchUtil.fetch("out");
      final DeploymentHost out = ((DeploymentHost) _fetch_1);
      out.setIp(hostInstance.getNodeIp());
      Object _fetch_2 = this.fetchUtil.fetch(hostInstance.getApplications());
      final List<DeploymentApplication> deploymentApps = ((List<DeploymentApplication>) _fetch_2);
      EList<DeploymentApplication> _applications = out.getApplications();
      Iterables.<DeploymentApplication>addAll(_applications, deploymentApps);
    };
    final Function0<Boolean> _function_3 = () -> {
      boolean _xblockexpression = false;
      {
        Object _fetch = this.fetchUtil.fetch("appInstance");
        final ApplicationInstance appInstance = ((ApplicationInstance) _fetch);
        HostInstance _allocatedTo = appInstance.getAllocatedTo();
        _xblockexpression = (_allocatedTo != null);
      }
      return Boolean.valueOf(_xblockexpression);
    };
    final Procedure0 _function_4 = () -> {
      Object _fetch = this.fetchUtil.fetch("appInstance");
      final ApplicationInstance appInstance = ((ApplicationInstance) _fetch);
      Object _fetch_1 = this.fetchUtil.fetch("out");
      final DeploymentApplication out = ((DeploymentApplication) _fetch_1);
      out.setId(appInstance.getIdentifier());
      Object _fetch_2 = this.fetchUtil.fetch(appInstance.getType().getBehavior(), "StateMachine_2_DeploymentBehavior");
      final DeploymentBehavior behavior = ((DeploymentBehavior) _fetch_2);
      out.setBehavior(behavior);
      this.trackApplicationInstance(appInstance, out);
    };
    final Procedure0 _function_5 = () -> {
      Object _fetch = this.fetchUtil.fetch("stateMachine");
      final StateMachine stateMachine = ((StateMachine) _fetch);
      Object _fetch_1 = this.fetchUtil.fetch("out");
      final DeploymentBehavior out = ((DeploymentBehavior) _fetch_1);
      out.setDescription(stateMachine.getIdentifier());
      Object _fetch_2 = this.fetchUtil.fetch(stateMachine.getStates(), "State_2_BehaviorState");
      final List<BehaviorState> behaviorStates = ((List<BehaviorState>) _fetch_2);
      EList<BehaviorState> _states = out.getStates();
      Iterables.<BehaviorState>addAll(_states, behaviorStates);
      ArrayList<BehaviorTransition> behaviorTransitions = new ArrayList<BehaviorTransition>();
      EList<State> _states_1 = stateMachine.getStates();
      for (final State state : _states_1) {
        Object _fetch_3 = this.fetchUtil.fetch(state.getOutgoingTransitions(), "Transition_2_BehaviorTransition");
        Iterables.<BehaviorTransition>addAll(behaviorTransitions, 
          ((List<BehaviorTransition>) _fetch_3));
      }
      EList<BehaviorTransition> _transitions = out.getTransitions();
      Iterables.<BehaviorTransition>addAll(_transitions, behaviorTransitions);
      final Function1<State, Boolean> _function_6 = (State it) -> {
        State _initial = stateMachine.getInitial();
        return Boolean.valueOf(Objects.equal(_initial, it));
      };
      final State initial = IterableExtensions.<State>findFirst(stateMachine.getStates(), _function_6);
      Object _fetch_4 = this.fetchUtil.fetch(initial, "State_2_BehaviorState");
      final BehaviorState initialBehaviorState = ((BehaviorState) _fetch_4);
      out.setCurrent(initialBehaviorState);
      this.trackStateMachine(stateMachine, out);
    };
    final Procedure0 _function_6 = () -> {
      Object _fetch = this.fetchUtil.fetch("state");
      final State state = ((State) _fetch);
      Object _fetch_1 = this.fetchUtil.fetch("out");
      final BehaviorState out = ((BehaviorState) _fetch_1);
      out.setDescription(state.getIdentifier());
      EList<BehaviorTransition> _outgoing = out.getOutgoing();
      Object _fetch_2 = this.fetchUtil.fetch(state.getOutgoingTransitions(), "Transition_2_BehaviorTransition");
      Iterables.<BehaviorTransition>addAll(_outgoing, ((List<BehaviorTransition>) _fetch_2));
      this.trackState(state, out);
    };
    final Function0<Boolean> _function_7 = () -> {
      boolean _xblockexpression = false;
      {
        Object _fetch = this.fetchUtil.fetch("transition");
        final Transition transition = ((Transition) _fetch);
        State _targetState = transition.getTargetState();
        _xblockexpression = (_targetState != null);
      }
      return Boolean.valueOf(_xblockexpression);
    };
    final Procedure0 _function_8 = () -> {
      Object _fetch = this.fetchUtil.fetch("transition");
      final Transition transition = ((Transition) _fetch);
      Object _fetch_1 = this.fetchUtil.fetch("out");
      final BehaviorTransition out = ((BehaviorTransition) _fetch_1);
      out.setDescription(transition.getIdentifier());
      Object _fetch_2 = this.fetchUtil.fetch(transition.getTargetState(), "State_2_BehaviorState");
      final BehaviorState targetBehaviorState = ((BehaviorState) _fetch_2);
      out.setTo(targetBehaviorState);
      this.trackTransition(transition, out);
    };
    final Function0<Boolean> _function_9 = () -> {
      boolean _xblockexpression = false;
      {
        Object _fetch = this.fetchUtil.fetch("transition");
        final Transition transition = ((Transition) _fetch);
        boolean _and = false;
        State _targetState = transition.getTargetState();
        boolean _tripleNotEquals = (_targetState != null);
        if (!_tripleNotEquals) {
          _and = false;
        } else {
          String _action = transition.getAction();
          boolean _isSignal = false;
          if (_action!=null) {
            _isSignal=this.isSignal(_action);
          }
          _and = _isSignal;
        }
        _xblockexpression = _and;
      }
      return Boolean.valueOf(_xblockexpression);
    };
    final Procedure0 _function_10 = () -> {
      Object _fetch = this.fetchUtil.fetch("transition");
      final Transition sendingTransition = ((Transition) _fetch);
      Object _fetch_1 = this.fetchUtil.fetch("waitingTransitions");
      final Map<String, List<Transition>> waitingTransitions = ((Map<String, List<Transition>>) _fetch_1);
      final List<Transition> waitingTransitionsList = waitingTransitions.get(this.getSignalId(sendingTransition.getAction()));
      if ((waitingTransitionsList != null)) {
        for (final Transition receivingTransition : waitingTransitionsList) {
          boolean _belongsToApplicationType = this.belongsToApplicationType(receivingTransition, this.getAppTypeId(sendingTransition.getAction()));
          if (_belongsToApplicationType) {
            final Set<BehaviorTransition> sendingBTransitionList = this.transitionToBTransitionList.get(sendingTransition);
            final Set<BehaviorTransition> receivingBTransitionList = this.transitionToBTransitionList.get(receivingTransition);
            if ((sendingBTransitionList != null)) {
              final Consumer<BehaviorTransition> _function_11 = (BehaviorTransition senderBehaviorTransition) -> {
                if ((receivingBTransitionList != null)) {
                  final ArrayList<BehaviorTransition> reachableTransitionList = CollectionLiterals.<BehaviorTransition>newArrayList();
                  for (final BehaviorTransition receiverBehaviorTransition : receivingBTransitionList) {
                    {
                      EObject _eContainer = senderBehaviorTransition.eContainer().eContainer();
                      final DeploymentApplication senderDepApp = ((DeploymentApplication) _eContainer);
                      final ApplicationInstance senderAppIntance = this.depAppToAppInstance.get(senderDepApp);
                      EObject _eContainer_1 = receiverBehaviorTransition.eContainer().eContainer();
                      final DeploymentApplication receiverDepApp = ((DeploymentApplication) _eContainer_1);
                      final ApplicationInstance receiverAppIntance = this.depAppToAppInstance.get(receiverDepApp);
                      boolean _reaches = this.reaches(senderAppIntance, receiverAppIntance);
                      if (_reaches) {
                        reachableTransitionList.add(receiverBehaviorTransition);
                      }
                    }
                  }
                  EList<BehaviorTransition> _trigger = senderBehaviorTransition.getTrigger();
                  Iterables.<BehaviorTransition>addAll(_trigger, reachableTransitionList);
                }
              };
              sendingBTransitionList.forEach(_function_11);
            }
          }
        }
      }
    };
    this.ruleStore(CollectionLiterals.<YAMTLRule>newArrayList(
      new Rule("CyberPhysicalSystem_2_Deployment").priority(0).in("cps", this.CPS.getCyberPhysicalSystem()).build().out("out", this.DEP.getDeployment(), _function_1).build().build(), 
      new Rule("HostInstance_2_DeploymentHost").priority(0).in("hostInstance", this.CPS.getHostInstance()).build().out("out", this.DEP.getDeploymentHost(), _function_2).build().build(), 
      new Rule("ApplicationInstance_2_DeploymentApplication").priority(0).in("appInstance", this.CPS.getApplicationInstance()).filter(_function_3).build().out("out", this.DEP.getDeploymentApplication(), _function_4).build().build(), 
      new Rule("StateMachine_2_DeploymentBehavior").isLazy().in("stateMachine", this.CPS.getStateMachine()).build().out("out", this.DEP.getDeploymentBehavior(), _function_5).build().build(), 
      new Rule("State_2_BehaviorState").isUniqueLazy().in("state", this.CPS.getState()).build().out("out", this.DEP.getBehaviorState(), _function_6).build().build(), 
      new Rule("Transition_2_BehaviorTransition").isUniqueLazy().in("transition", this.CPS.getTransition()).filter(_function_7).build().out("out", this.DEP.getBehaviorTransition(), _function_8).build().build(), 
      new Rule("Transition_2_BehaviorTransition_Trigger").isTransient().in("transition", this.CPS.getTransition()).filter(_function_9).build().out("out", this.DEP.getBehaviorTransition(), _function_10).build().build()));
    if (this.debug) {
      InputOutput.<String>println("constructor");
    }
  }
  
  /**
   * HELPERS: fetching reachable application types
   */
  @Accessors
  private final Map<DeploymentApplication, ApplicationInstance> depAppToAppInstance = CollectionLiterals.<DeploymentApplication, ApplicationInstance>newHashMap();
  
  public ApplicationInstance trackApplicationInstance(final ApplicationInstance appInstance, final DeploymentApplication depApp) {
    return this.depAppToAppInstance.put(depApp, appInstance);
  }
  
  @Accessors
  private Map<String, Map<String, List<Transition>>> reachableWaitForTransitionsMap = CollectionLiterals.<String, Map<String, List<Transition>>>newHashMap();
  
  public Map<String, List<Transition>> reachableWaitForTransitions(final ApplicationType from) {
    Map<String, List<Transition>> _xblockexpression = null;
    {
      Map<String, List<Transition>> map = this.reachableWaitForTransitionsMap.get(from.getIdentifier());
      if ((map == null)) {
        map = CollectionLiterals.<String, List<Transition>>newLinkedHashMap();
        final LinkedHashSet<ApplicationInstance> reachableAppInstancesSet = CollectionLiterals.<ApplicationInstance>newLinkedHashSet();
        EList<ApplicationInstance> _instances = from.getInstances();
        for (final ApplicationInstance appInstance : _instances) {
          {
            HostInstance _allocatedTo = appInstance.getAllocatedTo();
            boolean _tripleNotEquals = (_allocatedTo != null);
            if (_tripleNotEquals) {
              reachableAppInstancesSet.addAll(appInstance.getAllocatedTo().getApplications());
            }
            HostInstance _allocatedTo_1 = appInstance.getAllocatedTo();
            EList<HostInstance> _communicateWith = null;
            if (_allocatedTo_1!=null) {
              _communicateWith=_allocatedTo_1.getCommunicateWith();
            }
            boolean _tripleNotEquals_1 = (_communicateWith != null);
            if (_tripleNotEquals_1) {
              HostInstance _allocatedTo_2 = appInstance.getAllocatedTo();
              EList<HostInstance> _communicateWith_1 = null;
              if (_allocatedTo_2!=null) {
                _communicateWith_1=_allocatedTo_2.getCommunicateWith();
              }
              final Function1<HostInstance, EList<ApplicationInstance>> _function = (HostInstance hostInstance) -> {
                return hostInstance.getApplications();
              };
              Iterable<ApplicationInstance> _flatMap = IterableExtensions.<HostInstance, ApplicationInstance>flatMap(_communicateWith_1, _function);
              Iterables.<ApplicationInstance>addAll(reachableAppInstancesSet, _flatMap);
            }
          }
        }
        for (final ApplicationInstance receivingAppInstance : reachableAppInstancesSet) {
          StateMachine _behavior = receivingAppInstance.getType().getBehavior();
          boolean _tripleNotEquals = (_behavior != null);
          if (_tripleNotEquals) {
            final Function1<State, EList<Transition>> _function = (State it) -> {
              return it.getOutgoingTransitions();
            };
            Iterable<Transition> _flatMap = IterableExtensions.<State, Transition>flatMap(receivingAppInstance.getType().getBehavior().getStates(), _function);
            for (final Transition transition : _flatMap) {
              String _action = transition.getAction();
              boolean _isWaitSignal = false;
              if (_action!=null) {
                _isWaitSignal=this.isWaitSignal(_action);
              }
              if (_isWaitSignal) {
                final String signalId = this.getWaitTransitionSignalId(transition.getAction());
                final List<Transition> list = map.get(signalId);
                if ((list == null)) {
                  map.put(this.getWaitTransitionSignalId(transition.getAction()), CollectionLiterals.<Transition>newArrayList(transition));
                } else {
                  list.add(transition);
                }
              }
            }
          }
        }
        this.reachableWaitForTransitionsMap.put(from.getIdentifier(), map);
        return map;
      }
      _xblockexpression = map;
    }
    return _xblockexpression;
  }
  
  public boolean reaches(final ApplicationInstance fromApp, final ApplicationInstance toApp) {
    return ((fromApp.getAllocatedTo() != null) && 
      (Objects.equal(fromApp.getAllocatedTo(), toApp.getAllocatedTo()) || 
        fromApp.getAllocatedTo().getCommunicateWith().contains(toApp.getAllocatedTo())));
  }
  
  public ApplicationType applicationType(final Transition t) {
    EObject _eContainer = t.eContainer().eContainer().eContainer();
    return ((ApplicationType) _eContainer);
  }
  
  public boolean belongsToApplicationType(final Transition t, final String appTypeId) {
    boolean _xblockexpression = false;
    {
      EObject _eContainer = t.eContainer().eContainer().eContainer();
      final ApplicationType appType = ((ApplicationType) _eContainer);
      String _identifier = appType.getIdentifier();
      _xblockexpression = Objects.equal(_identifier, appTypeId);
    }
    return _xblockexpression;
  }
  
  public boolean isSignal(final String action) {
    return action.startsWith("sendSignal");
  }
  
  public boolean isWaitSignal(final String action) {
    return action.startsWith("waitForSignal");
  }
  
  public boolean isWaitSignal(final String action, final String signalId) {
    boolean _xblockexpression = false;
    {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("waitForSignal(");
      _builder.append(signalId);
      _builder.append(")");
      final String expectedAction = _builder.toString();
      _xblockexpression = Objects.equal(action, expectedAction);
    }
    return _xblockexpression;
  }
  
  public String getAppTypeId(final String action) {
    String _xblockexpression = null;
    {
      int _indexOf = action.indexOf("(");
      int _plus = (_indexOf + 1);
      final String[] contents = action.substring(_plus, action.lastIndexOf(")")).split(",");
      _xblockexpression = contents[0].trim();
    }
    return _xblockexpression;
  }
  
  public String getSignalId(final String action) {
    String _xblockexpression = null;
    {
      int _indexOf = action.indexOf("(");
      int _plus = (_indexOf + 1);
      final String[] contents = action.substring(_plus, action.lastIndexOf(")")).split(",");
      _xblockexpression = contents[1].trim();
    }
    return _xblockexpression;
  }
  
  public String getWaitTransitionSignalId(final String action) {
    String _xblockexpression = null;
    {
      int _indexOf = action.indexOf("(");
      int _plus = (_indexOf + 1);
      final String[] contents = action.substring(_plus, action.lastIndexOf(")")).split(",");
      _xblockexpression = contents[0].trim();
    }
    return _xblockexpression;
  }
  
  public void saveTraceModel(final String traceModelPath) {
    this.saveModel(traceModelPath, Collections.<EObject>unmodifiableList(CollectionLiterals.<EObject>newArrayList(this.mapping)));
  }
  
  public void getTraceModel() {
    this.fetchCPS2DepTraces(this.mapping);
  }
  
  /**
   * TRACEABILITY MODEL PERSISTENCE
   */
  @Accessors
  private final Map<Transition, Set<BehaviorTransition>> transitionToBTransitionList = CollectionLiterals.<Transition, Set<BehaviorTransition>>newHashMap();
  
  public Object trackTransition(final Transition t, final BehaviorTransition bt) {
    Object _xblockexpression = null;
    {
      final Set<BehaviorTransition> list = this.transitionToBTransitionList.get(t);
      Object _xifexpression = null;
      if ((list == null)) {
        _xifexpression = this.transitionToBTransitionList.put(t, CollectionLiterals.<BehaviorTransition>newLinkedHashSet(bt));
      } else {
        _xifexpression = Boolean.valueOf(list.add(bt));
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  @Accessors
  private final Map<State, Set<BehaviorState>> stateToBStateList = CollectionLiterals.<State, Set<BehaviorState>>newHashMap();
  
  public Object trackState(final State s, final BehaviorState bs) {
    Object _xblockexpression = null;
    {
      final Set<BehaviorState> list = this.stateToBStateList.get(s);
      Object _xifexpression = null;
      if ((list == null)) {
        _xifexpression = this.stateToBStateList.put(s, CollectionLiterals.<BehaviorState>newLinkedHashSet(bs));
      } else {
        _xifexpression = Boolean.valueOf(list.add(bs));
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  @Accessors
  private final Map<StateMachine, Set<DeploymentBehavior>> smToBehList = CollectionLiterals.<StateMachine, Set<DeploymentBehavior>>newHashMap();
  
  public Object trackStateMachine(final StateMachine sm, final DeploymentBehavior db) {
    Object _xblockexpression = null;
    {
      final Set<DeploymentBehavior> list = this.smToBehList.get(sm);
      Object _xifexpression = null;
      if ((list == null)) {
        _xifexpression = this.smToBehList.put(sm, CollectionLiterals.<DeploymentBehavior>newLinkedHashSet(db));
      } else {
        _xifexpression = Boolean.valueOf(list.add(db));
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  public void fetchCPS2DepTraces(final CPSToDeployment cps2dep) {
    final Set<String> visitedStateMachineIds = CollectionLiterals.<String>newHashSet();
    final Set<String> visitedStateIds = CollectionLiterals.<String>newHashSet();
    final Set<String> visitedTransitionIds = CollectionLiterals.<String>newHashSet();
    List<MatchMap> _eventPool = this.getEventPool();
    for (final MatchMap redux : _eventPool) {
      boolean _isInstance = CyberPhysicalSystem.class.isInstance(redux.defaultInObject());
      boolean _not = (!_isInstance);
      if (_not) {
        final EObject sourceObject = redux.defaultInObject();
        final BiConsumer<String, Pair<OutputElement, EObject>> _function = (String outName, Pair<OutputElement, EObject> pair) -> {
          String _name = redux.getRule().getName();
          if (_name != null) {
            switch (_name) {
              case "StateMachine_2_DeploymentBehavior":
                final StateMachine sm = ((StateMachine) sourceObject);
                boolean _contains = visitedStateMachineIds.contains(sm.getIdentifier());
                boolean _not_1 = (!_contains);
                if (_not_1) {
                  visitedStateMachineIds.add(sm.getIdentifier());
                  final Set<DeploymentBehavior> bStateMachineList = this.smToBehList.get(sm);
                  final CPS2DeploymentTrace trace = TraceabilityFactory.eINSTANCE.createCPS2DeploymentTrace();
                  trace.getCpsElements().add(((Identifiable) sourceObject));
                  trace.getDeploymentElements().addAll(bStateMachineList);
                  cps2dep.getTraces().add(trace);
                }
                break;
              case "State_2_BehaviorState":
                final State state = ((State) sourceObject);
                boolean _contains_1 = visitedStateIds.contains(state.getIdentifier());
                boolean _not_2 = (!_contains_1);
                if (_not_2) {
                  visitedStateIds.add(state.getIdentifier());
                  final Set<BehaviorState> bStateList = this.stateToBStateList.get(state);
                  final CPS2DeploymentTrace trace_1 = TraceabilityFactory.eINSTANCE.createCPS2DeploymentTrace();
                  trace_1.getCpsElements().add(((Identifiable) sourceObject));
                  trace_1.getDeploymentElements().addAll(bStateList);
                  cps2dep.getTraces().add(trace_1);
                }
                break;
              case "Transition_2_BehaviorTransition":
                final Transition transition = ((Transition) sourceObject);
                boolean _contains_2 = visitedTransitionIds.contains(transition.getIdentifier());
                boolean _not_3 = (!_contains_2);
                if (_not_3) {
                  visitedTransitionIds.add(transition.getIdentifier());
                  final Set<BehaviorTransition> bTransitionList = this.transitionToBTransitionList.get(transition);
                  final CPS2DeploymentTrace trace_2 = TraceabilityFactory.eINSTANCE.createCPS2DeploymentTrace();
                  trace_2.getCpsElements().add(((Identifiable) sourceObject));
                  trace_2.getDeploymentElements().addAll(bTransitionList);
                  cps2dep.getTraces().add(trace_2);
                }
                break;
              case "Transition_2_BehaviorTransition_Trigger":
                break;
              default:
                {
                  final EObject targetObject = pair.getValue();
                  final CPS2DeploymentTrace trace_3 = TraceabilityFactory.eINSTANCE.createCPS2DeploymentTrace();
                  trace_3.getCpsElements().add(((Identifiable) sourceObject));
                  CollectionExtensions.<DeploymentElement>addAll(trace_3.getDeploymentElements(), ((DeploymentElement) targetObject));
                  cps2dep.getTraces().add(trace_3);
                }
                break;
            }
          } else {
            {
              final EObject targetObject = pair.getValue();
              final CPS2DeploymentTrace trace_3 = TraceabilityFactory.eINSTANCE.createCPS2DeploymentTrace();
              trace_3.getCpsElements().add(((Identifiable) sourceObject));
              CollectionExtensions.<DeploymentElement>addAll(trace_3.getDeploymentElements(), ((DeploymentElement) targetObject));
              cps2dep.getTraces().add(trace_3);
            }
          }
        };
        redux.targetMatch.getMatch().forEach(_function);
      }
    }
  }
  
  @Pure
  public CPSToDeployment getMapping() {
    return this.mapping;
  }
  
  public void setMapping(final CPSToDeployment mapping) {
    this.mapping = mapping;
  }
  
  @Pure
  public Map<DeploymentApplication, ApplicationInstance> getDepAppToAppInstance() {
    return this.depAppToAppInstance;
  }
  
  @Pure
  public Map<String, Map<String, List<Transition>>> getReachableWaitForTransitionsMap() {
    return this.reachableWaitForTransitionsMap;
  }
  
  public void setReachableWaitForTransitionsMap(final Map<String, Map<String, List<Transition>>> reachableWaitForTransitionsMap) {
    this.reachableWaitForTransitionsMap = reachableWaitForTransitionsMap;
  }
  
  @Pure
  public Map<Transition, Set<BehaviorTransition>> getTransitionToBTransitionList() {
    return this.transitionToBTransitionList;
  }
  
  @Pure
  public Map<State, Set<BehaviorState>> getStateToBStateList() {
    return this.stateToBStateList;
  }
  
  @Pure
  public Map<StateMachine, Set<DeploymentBehavior>> getSmToBehList() {
    return this.smToBehList;
  }
}
