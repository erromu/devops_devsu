# Dockerfile reference
# https://gitlab.com/flectra-hq/docker/-/blob/master/3.0/Dockerfile

FROM python:3.12.3-slim-bookworm
LABEL author "Erick Romero <erick@gjrlabs.com>"

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

RUN mkdir -p /app

COPY ./requirements.txt /app

WORKDIR /app

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Install pip requirements
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    ###############################################################
    # cleaning up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* ;

RUN mkdir -p /data \
    && python -m pip install -r /app/requirements.txt ;

COPY api /app/api
COPY demo /app/demo
COPY manage.py /app
COPY .env /app
COPY app.sh /app.sh

RUN chmod +x /app.sh

EXPOSE 8000

CMD ["/app.sh"]
