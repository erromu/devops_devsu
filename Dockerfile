# Dockerfile reference
# https://gitlab.com/flectra-hq/docker/-/blob/master/3.0/Dockerfile

###############################################################

FROM python:3.12.3-slim-bookworm as PREP

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

ENV VERSION=master
ENV REPO=https://bitbucket.org/devsu/demo-devops-python.git


RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates git unzip ;

RUN git clone --depth=1 --progress --branch=${VERSION} ${REPO} /app \
    && cd /app \
    && git log --graph -n 20 ${VERSION} > /app/app-history.txt \
    && echo "APP ${VERSION} deployed at $(date -R)" > /app/app-version.txt ;

###############################################################

FROM python:3.12.3-slim-bookworm
LABEL author "Erick Romero <erick@gjrlabs.com>"

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

COPY --from=PREP /app /app

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
    && python -m pip install -r /app/requirements.txt  \
    && python /app/manage.py test ;

COPY ./app.sh /app.sh

RUN chmod +x /app.sh

EXPOSE 8000

CMD ["/app.sh"]
