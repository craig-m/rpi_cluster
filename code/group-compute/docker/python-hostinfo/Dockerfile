# Dockerfile for R-pi hostinfo.

FROM resin/rpi-raspbian

# packages for app
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y python-pip python-dev libpython-all-dev

# user for app to run under
RUN groupadd -r pyapp && \
    useradd -r -g pyapp -d /app -s /sbin/nologin -c "pyapp" pyapp

ENV HOME=/app

# Copy the appsrc directory contents into the container at /app
ADD appsrc /app

# Set the working directory to /app
WORKDIR /app

RUN chown -R pyapp:pyapp /app/

RUN pip install -r /app/requirements.txt

# Change to the app user.
USER pyapp

# Define environment variable
ENV NAME rpi-cluster-user

# Run app.py when the container launches
CMD ["python", "app.py"]

EXPOSE 4000
