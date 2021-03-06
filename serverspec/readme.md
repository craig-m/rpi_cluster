ServerSpec
----------

> RSpec tests for your servers configured by CFEngine, Puppet, Ansible, Itamae or anything else

https://serverspec.org/

Serverspec is a server testing framework that runs locally, or over SSH (using the standard ~/.ssh/config file - which is the case here). Used against servers setup by Ansible, Chef, Puppet, BASH etc etc

This is run from the Deployer R-Pi, and tests all of the cluster nodes (including the deployer). Run a complete test suite anytime to check the state of the cluster.

Some additional health checks have been wrapped in ServerSpec, example:

```
describe command('/usr/lib/nagios/plugins/check_procs -w 300 -c 400;') do
  its(:exit_status) { should eq 0 }
end
```


## install + use

use `install-serverspec.sh` to setup the deploy node, and `run.sh` to run tests on all nodes in the cluster.

You can use `run.sh alpha` to test a single node.

Needs refining, and integrating with ansible.

## tests

* tests: 178 - group: compute (x4)
* tests: 262 - group: lan service main (x2)
* tests: 223 - group: lan service misc (x1)
* tests: 240 - group: deployer node (x1)

The total ServerSpec cases performed after `run.sh` is getting up there :)

These tests can be run from cron, hourly or daily monitoring is nice.
