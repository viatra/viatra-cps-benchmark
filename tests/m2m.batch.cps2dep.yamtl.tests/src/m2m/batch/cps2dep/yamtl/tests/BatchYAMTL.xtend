package m2m.batch.cps2dep.yamtl.tests

import m2m.batch.cps2dep.yamtl.Cps2DepYAMTL
import org.apache.log4j.Logger
import org.eclipse.viatra.examples.cps.traceability.CPSToDeployment
import org.eclipse.viatra.examples.cps.xform.m2m.launcher.CPSTransformationWrapper
import org.eclipse.xtend.lib.annotations.Accessors

class BatchYAMTL extends CPSTransformationWrapper {
	protected extension Logger logger = Logger.getLogger("Cps2DepTestDriver_YAMTL")
	
	@Accessors
	var Cps2DepYAMTL xform 
	
	override initializeTransformation(CPSToDeployment cps2dep) {
		if ((cps2dep.cps === null) || (cps2dep.deployment === null)) 
			throw new IllegalArgumentException()
		
		xform = new Cps2DepYAMTL
		xform.fromRoots = false
		xform.mapping = cps2dep
		val cpsRes = xform.mapping.cps.eResource
		xform.loadInputResources(#{'cps' -> cpsRes})
	}
	
	override executeTransformation() {
		// reset
		xform.mapping.traces.clear
		xform.transitionToBTransitionList.clear
		xform.stateToBStateList.clear
		xform.smToBehList.clear
		xform.reachableWaitForTransitionsMap.clear
		xform.depAppToAppInstance.clear
		xform.reset()
		
		xform.execute()
	}
    
    override cleanupTransformation() {
        if (xform !== null) {
            xform = null
        }
    }
    
    override isIncremental() {
        return false
    }
	

}
