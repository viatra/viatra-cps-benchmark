#!/usr/bin/env python
"""
This script can be used for running performance tests on an exported Eclipse.

Put the script in the directory that contains the "eclipse" folder of
the exported application.

@author: Tamas Borbas
"""
import subprocess
import shutil
from subprocess import TimeoutExpired
from subprocess import CalledProcessError


"""
TIMEOUT is in seconds
"""
CONST_TIMEOUT=1000

"""
RUNS determines how many times the same test is run
"""
CONST_RUNS=5

"""
Valid values for TRANSFORMATOR_TYPES:
    "BATCH_SIMPLE",
    "BATCH_OPTIMIZED",
    "BATCH_INCQUERY",
    "BATCH_VIATRA",
    "INCR_QUERY_RESULT_TRACEABILITY",
    "INCR_EXPLICIT_TRACEABILITY",
    "INCR_AGGREGATED",
    "INCR_VIATRA"
"""
TRANSFORMATOR_TYPES=[
    "BATCH_SIMPLE",
    "BATCH_OPTIMIZED",
    "BATCH_INCQUERY",
    "BATCH_VIATRA",
    "INCR_QUERY_RESULT_TRACEABILITY",
    "INCR_EXPLICIT_TRACEABILITY",
    "INCR_AGGREGATED",
    "INCR_VIATRA"
    ]


"""
SCALES are integers
"""
SCALES=[1,2,4,8,16,32,64,128,256,512]


"""
Valid values for GENERATOR_TYPES:
    "TEMPLATE",
    "JDT"
"""
GENERATOR_TYPES=["TEMPLATE","JDT"]


def flatten(lst):
    return sum(([x] if not isinstance(x, list) else flatten(x) for x in lst), [])


def starteclipses():
    for genType in GENERATOR_TYPES:
        for trafoType in TRANSFORMATOR_TYPES:
            for scale in SCALES:
                timeoutOrError = False
                for runIndex in range(1,CONST_RUNS+1):
                    print("Clearing workspace")
                    shutil.rmtree("workspace", ignore_errors=True)
                    print("Running test XFORM: ", trafoType, ", GENERATOR: ", genType, ", SCALE: ", str(scale), ", RUN: ", str(runIndex))
                    try:
                        subprocess.call(flatten(["eclipse\eclipse.exe", trafoType, str(scale), genType, str(runIndex)]), timeout=CONST_TIMEOUT)
                    except TimeoutExpired:
                        print(" >> Timed out after ", CONST_TIMEOUT, "s, continuing with the next transformation type.")
                        timeoutOrError = True
                        break
                    except CalledProcessError as e:
                        print(" >> Program exited with error, continuing with the next transformation type.")
                        timeoutOrError = True
                        break
                if timeoutOrError:
                    break

if __name__ == "__main__":
    starteclipses()
