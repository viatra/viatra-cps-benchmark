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
package testproject.hosts;

import org.eclipse.viatra.examples.cps.m2t.proto.distributed.general.applications.Application;
import org.eclipse.viatra.examples.cps.m2t.proto.distributed.general.communicationlayer.CommunicationNetwork;
import org.eclipse.viatra.examples.cps.m2t.proto.distributed.general.hosts.BaseHost;
import com.google.common.collect.Lists;
import testproject.applications.Simplecpsappfirstappclass0inst0Application;

public class HostSimplecpshostfirsthostclass0inst0 extends BaseHost {

	public HostSimplecpshostfirsthostclass0inst0(CommunicationNetwork network) {
		super(network);
		// Add Applications of Host
		applications = Lists.<Application>newArrayList(
		new Simplecpsappfirstappclass0inst0Application(this)
		);
	}
}
