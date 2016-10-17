#!/bin/bash
set -o nounser
set -o errexit

if [ -z "$SCIFIGHT_SECRET_KEY" ] ; then
    echo 2>&1 "You must set at least SCIFIGHT_SECRET_KEY on first run."
    echo 2>&1 "That's critical for Django security model."
    exit 1
fi

cd -- "$SCIFIGHT_PROJECT_DIR"
if [ ! -f scifight_proj/settings_secret.py ] ; then
    # That's the first run, so let's create the configuration file.
    envsubst </.attach/settings_secret.py \
             >scifight_proj/settings_secret.py
    chown -- "$SCIFIGHT_OWNER_USER:$SCIFIGHT_OWNER_GROUP" \
	      scifight_proj/settings_secret.py

    source ./.virtualenv/bin/activate
    ./manage.py collectstatic
    ./manage.py check --deploy
    ./manage.py migrate
    deactivate
fi
    
uwsgi --ini /etc/uwsgi.ini &
exec nginx -c /etc/nginx.conf
