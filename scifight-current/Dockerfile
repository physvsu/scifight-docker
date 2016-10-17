FROM ubuntu:14.04
MAINTAINER Pavel Kretov <firegurafiku@gmail.com>

ADD run-container.sh    /.attach/
ADD settings_secret.py  /.attach/
ADD nginx.conf          /.attach/
ADD uwsgi.ini           /.attach/

# Where to take source code from. Only Git is supported, and it's hightly
# recommended to use the commit's full hash there.
ARG SCIFIGHT_GIT_REPO="https://github.com/physvsu/scifight.git"
ARG SCIFIGHT_GIT_COMMIT="dadc94baf1fb94cd04ea49fcda4b9dbf4a8ae7a6"
ARG SCIFIGHT_PROJECT_DIR="/srv/scifight"
ARG SCIFIGHT_STATIC_DIR="/srv/scifight-static"
ARG SCIFIGHT_OWNER_USER="www-data"
ARG SCIFIGHT_OWNER_GROUP="www-data"

# Set the following environment variables during container's first run to
# change the setings, or the defaults will be used. The only way to alter these
# settings after the first run is to recreate the container.
ENV SCIFIGHT_SECRET_KEY="secret_must_be_kept_secret"
ENV SCIFIGHT_DB_ENGINE="django.db.backends.mysql"
ENV SCIFIGHT_DB_HOST="127.0.0.1"
ENV SCIFIGHT_DB_PORT="3306"
ENV SCIFIGHT_DB_NAME="scifight"
ENV SCIFIGHT_DB_USER="scifight"
ENV SCIFIGHT_DB_PASS="<no-password-is-bad>"

# For Nginx to shine.
EXPOSE 80

USER root

# Install all the software needed for the image's build time and runtime. Some
# of this packages will be uninstalled right before the image is ready.
# Since Dockerfiles' syntax does not allow commenting individual lines in the
# below list, here is some explanation:
#  - 'git' is needed to fetch scifight source code from the GitHub,
#  - 'gcc' and 'libmysqlcliend-dev' are here for Django MySQL backend,
#  - 'gettext' contains 'envsubst' command used here as a simple templater.
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
        gettext \
        git \
        gcc \
        libmysqlclient-dev \
        nginx \
        python-virtualenv \
        python3-dev \
        python3-pip \
        uwsgi

# Prepare Nginx site configuration, and enable it.
RUN rm -rf /etc/nginx /etc/uwsgi \
        && envsubst </.attach/nginx.conf >/etc/nginx.conf \
        && envsubst </.attach/uwsgi.ini  >/etc/uwsgi.ini

# Create directories to put Django application's source code and gathered
# static files into.
RUN true \
        && mkdir -p -- "$SCIFIGHT_PROJECT_DIR" \
        && mkdir -p -- "$SCIFIGHT_STATIC_DIR" \
        && chown "$SCIFIGHT_OWNER_USER:$SCIFIGHT_OWNER_GROUP" \
                    -- "$SCIFIGHT_PROJECT_DIR" "$SCIFIGHT_STATIC_DIR"

# Fetch source code from Git and get the specified revision. There is no need
# to keep the whole history in the container, so delete it.
USER "$SCIFIGHT_OWNER_USER"
RUN cd -- "$SCIFIGHT_PROJECT_DIR" \
        && git clone -- "$SCIFIGHT_GIT_REPO" . \
        && git checkout "$SCIFIGHT_GIT_COMMIT"    \
        && rm -rf .git

# Create new virtual environment and install all prerequisites.
RUN cd -- "$SCIFIGHT_PROJECT_DIR" \
        && virtualenv -p python3 .virtualenv \
        && source ./.virtualenv/bin/activate \
        && pip install -r requirements.txt


USER root

# Some aggressive cleanup.
RUN apt-get remove -y git gcc \
        && apt-get autoremove -y \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cp /.attach/run-container.sh /run-container.sh
        && chmod +x /run-container.sh

CMD /run-container.sh
