# ----------------------------- #
# --- rpi-py-api Dockerfile --- #
# ----------------------------- #

FROM python

ENV DEBIAN_FRONTEND noninteractive

# create the user "omegapyapi" for the app to run as
RUN groupadd -r omegapyapi && \
    useradd -r -g omegapyapi -d /app -s /sbin/nologin -c "omegapyapi" omegapyapi

ENV HOME=/app

# Copy the appsrc directory contents into the container at /app
COPY appsrc /app

# Set the working directory to /app
WORKDIR /app

RUN chown -R omegapyapi:omegapyapi /app/

RUN pip install -r /app/requirements.txt

USER omegapyapi

# entry point
CMD ["bash", "/app/start.sh"]

EXPOSE 8382
