package m2m.batch.cps2dep.yamtl.tests;

import java.util.Collections;
import m2m.batch.cps2dep.yamtl.Cps2DepYAMTL;
import org.apache.log4j.Logger;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.viatra.examples.cps.traceability.CPSToDeployment;
import org.eclipse.viatra.examples.cps.xform.m2m.launcher.CPSTransformationWrapper;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Pure;

@SuppressWarnings("all")
public class BatchYAMTL extends CPSTransformationWrapper {
  @Extension
  protected Logger logger = Logger.getLogger("Cps2DepTestDriver_YAMTL");
  
  @Accessors
  private Cps2DepYAMTL xform;
  
  @Override
  public void initializeTransformation(final CPSToDeployment cps2dep) {
    if (((cps2dep.getCps() == null) || (cps2dep.getDeployment() == null))) {
      throw new IllegalArgumentException();
    }
    Cps2DepYAMTL _cps2DepYAMTL = new Cps2DepYAMTL();
    this.xform = _cps2DepYAMTL;
    this.xform.fromRoots = false;
    this.xform.setMapping(cps2dep);
    final Resource cpsRes = this.xform.getMapping().getCps().eResource();
    Pair<String, Resource> _mappedTo = Pair.<String, Resource>of("cps", cpsRes);
    this.xform.loadInputResources(Collections.<String, Resource>unmodifiableMap(CollectionLiterals.<String, Resource>newHashMap(_mappedTo)));
  }
  
  @Override
  public void executeTransformation() {
    this.xform.getMapping().getTraces().clear();
    this.xform.getTransitionToBTransitionList().clear();
    this.xform.getStateToBStateList().clear();
    this.xform.getSmToBehList().clear();
    this.xform.getReachableWaitForTransitionsMap().clear();
    this.xform.getDepAppToAppInstance().clear();
    this.xform.reset();
    this.xform.execute();
  }
  
  @Override
  public void cleanupTransformation() {
    if ((this.xform != null)) {
      this.xform = null;
    }
  }
  
  @Override
  public boolean isIncremental() {
    return false;
  }
  
  @Pure
  public Cps2DepYAMTL getXform() {
    return this.xform;
  }
  
  public void setXform(final Cps2DepYAMTL xform) {
    this.xform = xform;
  }
}
