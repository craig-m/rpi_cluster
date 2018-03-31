#
# VagrantVM testinfra
#

def test_apache_running_and_enabled(host):
    nginx = host.service("apache2")
    assert apache2.is_running
    assert apache2.is_enabled

def test_redis_running_and_enabled(host):
    nginx = host.service("redis")
    assert redis.is_running
    assert redis.is_enabled
