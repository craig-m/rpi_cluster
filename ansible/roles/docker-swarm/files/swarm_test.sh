#!/bin/bash

# https://github.com/alexellis/swarmmode-tests/tree/master/arm

docker node ls || exit 1;

docker network create --driver overlay --subnet 20.0.14.0/24 armnet
sleep 1s;

docker service create --name redis --replicas=2 --network=armnet alexellis2/redis-arm:v6
sleep 1s;

docker service create --name counter --replicas=2 --network=armnet --publish 3000:3000 alexellis2/arm_redis_counter
sleep 1s;

docker service ls

curl localhost:3000/incr

# docker service rm counter
# docker service rm redis
# docker network rm armnet
