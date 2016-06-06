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
package testproject.applications;
	
import org.eclipse.viatra.examples.cps.m2t.proto.distributed.general.applications.BaseApplication;
import org.eclipse.viatra.examples.cps.m2t.proto.distributed.general.hosts.Host;

import testproject.hosts.statemachines.BehaviorSimplecpsappfirstappclass0inst0;


public class Simplecpsappfirstappclass0inst0Application extends BaseApplication<BehaviorSimplecpsappfirstappclass0inst0> {

	// Set ApplicationID
	protected static final String APP_ID = "simple.cps.app.FirstAppClass0.inst0";

	public Simplecpsappfirstappclass0inst0Application(Host host) {
		super(host);
		
		// Set initial State
		currentState = BehaviorSimplecpsappfirstappclass0inst0.Simplecpsappfirstappclass0sm0s0;
	}
	
	@Override
	public String getAppID() {
		return APP_ID;
	}
	
}
