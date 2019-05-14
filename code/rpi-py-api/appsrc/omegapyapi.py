
# omgegapyapi

import flask
import logging
import os
import socket
from flask import Flask, request
from flask import Flask, render_template
from redis import Redis, RedisError
from logging.handlers import RotatingFileHandler

# app vars
LISTENIP = "127.0.0.1"
LISTENPORT = 8382
DEBUG = False

# Connect to Redis DB
redis = Redis(host= "redis", port=6379, socket_connect_timeout=2, socket_timeout=2)

class ReverseProxied(object):
    '''
    so flask will work behind a reverse proxy
    http://flask.pocoo.org/snippets/35/
    '''
    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
        script_name = environ.get('HTTP_X_SCRIPT_NAME', '')
        if script_name:
            environ['SCRIPT_NAME'] = script_name
            path_info = environ['PATH_INFO']
            if path_info.startswith(script_name):
                environ['PATH_INFO'] = path_info[len(script_name):]

        scheme = environ.get('HTTP_X_SCHEME', '')
        if scheme:
            environ['wsgi.url_scheme'] = scheme
        return self.app(environ, start_response)


app = flask.Flask(__name__, static_url_path='/static')

app.wsgi_app = ReverseProxied(app.wsgi_app)

def root_dir():
    return os.path.abspath(os.path.dirname(__file__))

# routes -----------------------------------------------------------------------

@app.route("/")
def index():
    html = "<p><b>My hostname: </b> {hostname} </p>"
    return html.format(hostname=socket.gethostname())

@app.route("/pages/about/")
def about():
    return render_template('about.html')

@app.route("/counter")
def hitcount():
    try:
        visits = redis.incr("/hits/rpiadmin/counter")
    except RedisError:
        visits = "<i>error connecting to redis</i>"
    html = "<span><b>requests:</b> {visits} </span>"
    return html.format(visits=visits)

@app.route('/ip', methods=['GET'])
def name():
    return request.environ.get('HTTP_X_REAL_IP', request.remote_addr)

@app.route('/hello/')
@app.route('/hello/<name>')
def hello(name=None):
    return render_template('hello.html', name=name)

# main -------------------------------------------------------------------------

if not app.debug:
    import logging
    from logging.handlers import RotatingFileHandler
    file_handler = RotatingFileHandler('microblog.log', 'a', 1 * 1024 * 1024, 10)
    file_handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'))
    app.logger.addHandler(file_handler)
    app.logger.info('microblog startup')

if __name__ == '__main__':
	app.run(host=LISTENIP, port=LISTENPORT, debug=DEBUG)

# EOF
