#!/usr/bin/python

import sys
import os

includeos_src = os.environ.get('INCLUDEOS_SRC',
                               os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__))).split('/test')[0])
print 'includeos_src: {0}'.format(includeos_src)
sys.path.insert(0,includeos_src + "/test")
from subprocess import call

# Setup disk
call(["./make_disk.sh"], shell=True)

import vmrunner
vm = vmrunner.vms[0]

vm.cmake()

num_outputs = 0

def cleanup():
  vm.clean()

def increment(line):
  global num_outputs
  num_outputs += 1
  print "num_outputs after increment: ", num_outputs

def check_num_outputs(line):
  assert(num_outputs == 1)
  vmrunner.vms[0].exit(0, "SUCCESS")

vm.on_output("All \d+ selected tests passed", increment)

vm.on_output("All done!", check_num_outputs)

vm.on_exit(cleanup)

# Boot the VM, taking a timeout as parameter
vm.boot(20)
