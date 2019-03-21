ServerSpec
----------

> RSpec tests for your servers configured by CFEngine, Puppet, Ansible, Itamae or anything else

https://serverspec.org/

Serverspec is a server testing framework that runs locally, or over SSH (using the standard ~/.ssh/config file). It is run against servers setup by Ansible, Chef, Puppet, BASH etc etc

This is run from the Deployer R-Pi, and tests all of the cluster nodes (including the deployer). Run a complete test suite anytime to check state of the cluster.

## tests

* tests: 147 - group: compute (x4)
* tests: 211 - group: lan service main (x2)
* tests: 187 - group: lan service misc (x1)
* tests: 168 - group: deployer node (x1)

total ServerSpec tests: 1365

## use

```
source ~/.rvm/scripts/rvm
rvm gemset use serverspec
rake --list
rake serverspec:omega
```
