from flask import Flask, request
import os
import socket

app = Flask(__name__)

@app.route("/")
def hello():
    html = "<h3>hostinfo</h3>" \
           "<p><b>Hello: </b> {name} </p>" \
           "<p><b>My hostname: </b> {hostname} </p>"
    return html.format(name=os.getenv("NAME", "user"), hostname=socket.gethostname())

@app.route('/ip', methods=['GET'])
def name():
    return request.environ.get('HTTP_X_REAL_IP', request.remote_addr)

if __name__ == "__main__":
	app.run(host='0.0.0.0', port=4000)
