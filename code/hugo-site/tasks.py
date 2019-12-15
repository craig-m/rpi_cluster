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

