#!/usr/bin/env python3
"""
This script can be used for running performance tests on an exported Eclipse.

Put the script in the directory that contains the "eclipse" folder of
the exported application.

@author: Tamas Borbas
"""
import subprocess
import shutil
import os
import signal
import psutil
from subprocess import TimeoutExpired
from subprocess import CalledProcessError

"""
TIMEOUT is in seconds
"""
CONST_TIMEOUT=1000

"""
RUNS determines how many times the same test is run
"""
CONST_RUNS=1

"""
Valid values for TRANSFORMATOR_TYPES:
    "BATCH_SIMPLE",
    "BATCH_OPTIMIZED",
    "BATCH_VIATRA_QUERY_RETE",
    "BATCH_VIATRA_QUERY_LOCAL_SEARCH",
    "BATCH_VIATRA_TRANSFORMATION",
    "INCR_VIATRA_QUERY_RESULT_TRACEABILITY",
    "INCR_VIATRA_EXPLICIT_TRACEABILITY",
    "INCR_VIATRA_AGGREGATED",
    "INCR_VIATRA_TRANSFORMATION"
"""
ALL_TRANSFORMATOR_TYPES=[
    "BATCH_SIMPLE",
    "BATCH_OPTIMIZED",
    "BATCH_VIATRA_QUERY_RETE",
    "BATCH_VIATRA_QUERY_LOCAL_SEARCH",
    "BATCH_VIATRA_TRANSFORMATION",
    "INCR_VIATRA_QUERY_RESULT_TRACEABILITY",
    "INCR_VIATRA_EXPLICIT_TRACEABILITY",
    "INCR_VIATRA_AGGREGATED",
    "INCR_VIATRA_TRANSFORMATION",
]

GENERATOR_TRANSFORMATOR_TYPES=[
    "BATCH_VIATRA_TRANSFORMATION",
    "INCR_VIATRA_AGGREGATED",
    "INCR_VIATRA_TRANSFORMATION",
]

"""
SCALES are integers
"""
#SCALES=[1,2,4,8,16,32,64]
SCALES=[1,2]


"""
Valid values for GENERATOR_TYPES:
    "TEMPLATE",
    "JDT"
"""
ALL_GENERATOR_TYPES=[
    "TEMPLATE",
    "JDT"
]

DEFAULT_GENERATOR_TYPES=[
    "TEMPLATE"
]

def flatten(lst):
    return sum(([x] if not isinstance(x, list) else flatten(x) for x in lst), [])

def kill_children(pid):
    print("Looking for children of", pid)
    for proc in psutil.process_iter():
        parent = proc.ppid()
        if parent == pid:
            print("Found children of ", pid, ": terminating!")
            proc.kill()

def runBenchmark(genType, trafoType, scale, runIndex):
    print("Clearing workspace")
    shutil.rmtree("workspace", ignore_errors=True)
    print("Running test XFORM: ", trafoType, ", GENERATOR: ", genType, ", SCALE: ", str(scale), ", RUN: ", str(runIndex))
    param = flatten([trafoType, str(scale), genType, str(runIndex)])
    p = subprocess.Popen(flatten(["eclipse/eclipse", param]))
    pid = p.pid
    try:
        p.wait(timeout=CONST_TIMEOUT)
    except TimeoutExpired:
        print(" >> Timed out after ", CONST_TIMEOUT, "s, continuing with the next transformation type.")
        kill_children(pid)
        return False
    return True
            
def starteclipses():
    for genType in DEFAULT_GENERATOR_TYPES:
        for trafoType in ALL_TRANSFORMATOR_TYPES:
            for scale in SCALES:
                success = True
                for runIndex in range(1,CONST_RUNS+1):
                    success = runBenchmark(genType, trafoType, scale, runIndex)
                    if not success:
                        break
                if not success:
                    break
                    
    for genType in ALL_GENERATOR_TYPES:
        if genType in DEFAULT_GENERATOR_TYPES:
            continue
        for trafoType in GENERATOR_TRANSFORMATOR_TYPES:
            for scale in SCALES:
                success = True
                for runIndex in range(1,CONST_RUNS+1):
                    success = runBenchmark(genType, trafoType, scale, runIndex)
                    if not success:
                        break
                if not success:
                    break

if __name__ == "__main__":
    starteclipses()
