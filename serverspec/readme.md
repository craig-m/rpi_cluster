ServerSpec
----------

> RSpec tests for your servers configured by CFEngine, Puppet, Ansible, Itamae or anything else

https://serverspec.org/

Serverspec is a server testing framework that runs locally, or over SSH (using the standard ~/.ssh/config file). It is run against servers setup by Ansible, Chef, Puppet, BASH etc etc

This is run from Deployer R-Pi, and tests all of the cluster nodes (including the deployer). Run this anytime to check the cluster state.
