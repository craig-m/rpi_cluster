# Dockerfile

FROM python

ENV DEBIAN_FRONTEND noninteractive

RUN groupadd -r omegapyapi && \
    useradd -r -g omegapyapi -d /app -s /sbin/nologin -c "omegapyapi" omegapyapi

ENV HOME=/app

COPY appsrc /app

WORKDIR /app

RUN chown -R omegapyapi:omegapyapi /app/

RUN pip install -r /app/requirements.txt

USER omegapyapi

CMD ["bash", "/app/start.sh"]

EXPOSE 8382
