#!/bin/sh
set -o nounset
set -o errexit

if [ -z "$SCIFIGHT_SECRET_KEY" ] ; then
    echo 2>&1 "You must set SCIFIGHT_SECRET_KEY on first run."
    echo 2>&1 "That's critical for Django security model."
    exit 1
fi

cd -- "$SCIFIGHT_PROJECT_DIR"
if [ ! -f .container_configuration_done ] ; then
    sudo -u "$SCIFIGHT_OWNER_USER" --preserve-env -- sh -c '
        set -o errexit
        envsubst </.attach/settings_secret.py \
                 >scifight_proj/settings_secret.py

        . ./.virtualenv/bin/activate
        ./manage.py check --deploy
        ./manage.py migrate
        deactivate'
    touch .container_configuration_done
fi
    
uwsgi --ini /etc/uwsgi/apps-enabled/scifight.ini
exec nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
