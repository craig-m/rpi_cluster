"""
omega hugo website
"""

from invoke import task, run

@task
def hugo_build(c):
    """ build the web site """
    print("building")
    c.run('rm -rf -- public/*')
    c.run('hugo -v')

@task
def hugo_upload(c):
    """ upload public/* site code to omega """
    print("uploading")
    c.run('rsync -avr -- public/* pi@omega:/srv/nginx/hugo-site/')
