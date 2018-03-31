Python Flask API
----------------
http://flask.pocoo.org/

Install:

```
pi@omega:/srv/python/omegapyapi $ chmod 755 install.sh
pi@omega:/srv/python/omegapyapi $ ./install.sh
```

Run:

```
pi@omega:/srv/python/omegapyapi $ sudo systemctl start omegapyapi.service
```

test:

```
pi@omega:~ $ curl -X GET --unix-socket /opt/omegapyapi/omegapyapi.socket http/hello/curltest
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
