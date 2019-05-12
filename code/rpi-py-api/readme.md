Python Flask API
----------------
http://flask.pocoo.org/

A simple Flask app, with redis db, that runs in Docker.


On the R-Pi nodes:

```
/opt/cluster/docker/scripts/install_compose.sh
source /opt/cluster/docker/compose/venv/bin/activate
```


Build and run:

```
docker-compose build && docker-compose up -d
```



test:

```
pi@omega:~ $ curl -X GET --unix-socket omegapyapi_socket http/hello/curltest
<!DOCTYPE html>
<html>
<head>
  <title>Hello from flask</title>
  <link rel="stylesheet" type="text/css" href="/static/style.css">
</head>
<body>
  <h1>Hello curltest!</h1>
</body>
</html>
```
