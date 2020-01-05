# rpi-py-api

A small Python Flask app, with redis database backend, and nginx webserver frontend.

All setup with Docker-Compose.


Build and run (anywhere that has docker-compose + docker):

```
docker-compose build && docker-compose up -d
```

Attach to the app container and test:

```
docker exec -it $(docker ps | grep "rpi-py-api_app" | awk '{print $1}') /bin/bash 
curl -X GET --unix-socket /app/rpyapi.socket http/hello/curltest
```
