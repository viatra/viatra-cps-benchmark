#!/usr/bin/env python
"""
This script can be used for running performance tests on an exported Eclipse.

Put the script in the directory that contains the "eclipse" folder of
the exported application.

@author: Tamas Borbas
"""
import subprocess
import shutil
import json
from subprocess import TimeoutExpired
from subprocess import CalledProcessError

def flatten(lst):
    return sum(([x] if not isinstance(x, list) else flatten(x) for x in lst), [])


def runBenchmark(scenario, case, genType, trafoType, scale, runIndex, timeoutC):
    print("Clearing workspace")
    shutil.rmtree("workspace", ignore_errors=True)
    print("Running test SCENARIO: ", scenario, ", CASE: ", case, ", XFORM: ", trafoType, ", GENERATOR: ", genType, ", SCALE: ", str(scale), "TIMEOUT: ", str(timeoutC), ", RUN: ", str(runIndex))
    param = flatten(["-scenario", scenario, "-case", case, "-transformationType", trafoType, "-scale", str(scale), "-generatorType", genType, "-runIndex", str(runIndex)])
    print("Command: eclipse\eclipse.exe"," ".join(param))
    try:
        subprocess.call(flatten(["eclipse\eclipse.exe", param]), timeout=CONST_TIMEOUT)
    except TimeoutExpired:
        print(" >> Timed out after ", CONST_TIMEOUT, "s, continuing with the next transformation type.")
        return False
    except CalledProcessError as e:
        print(" >> Program exited with error, continuing with the next transformation type.")
        return False
    return True

def starteclipses(argv):
    print("Using benchmark config ", argv[0])
    with open('data.json', 'r') as f:
        data = json.load(f)

    for benchmark in data["benchmark"]:
        scenario = benchmark["scenario"]
        timeoutC = benchmark["timeout"]
        print("Running benchmark with scenario ", scenario)
        for case in benchmark["cases"]:
            print("-- Case: ", case)
            for genType in benchmark["generator_types"]:
                for trafoType in benchmark["transformation_types"]:
                    for scale in benchmark["scales"]:
                        success = True
                        for runIndex in range(1,benchmark["runs"]+1):
                            success = runBenchmark(scenario, case, genType, trafoType, scale, runIndex, timeoutC)
                            if not success:
                                break
                        if not success:
                            break

if __name__ == "__main__":
    starteclipses(sys.argv[1:])
