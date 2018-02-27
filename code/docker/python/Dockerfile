# docker build -t python_app .
# docker run -p 4000:8080 python_app

FROM armhf/debian:stretch

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y python-pip python-dev libpython-all-dev

RUN groupadd -r pyapp && \
    useradd -r -g pyapp -d /app -s /sbin/nologin -c "pyapp" pyapp

ENV HOME=/app

# Copy the appsrc directory contents into the container at /app
ADD appsrc /app

# Set the working directory to /app
WORKDIR /app

RUN chown -R pyapp:pyapp /app/

# Change to the app user.
USER pyapp

RUN pip install -r /app/requirements.txt

# Define environment variable
ENV NAME cluster-user

# Run app.py when the container launches
CMD ["python", "app.py"]

EXPOSE 8182
