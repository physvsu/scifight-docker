#!/bin/sh
set -o nounset
set -o errexit

if [ -z "$SCIFIGHT_SECRET_KEY" ] ; then
    echo 2>&1 "You must set SCIFIGHT_SECRET_KEY on first run."
    echo 2>&1 "That's critical for Django security model."
    exit 1
fi

cd -- "$SCIFIGHT_PROJECT_DIR"
if [ ! -f /.container_configuration_done ] ; then
    envsubst </.attach/nginx.conf \
             >/etc/nginx/nginx.conf
    envsubst </.attach/nginx-scifight.conf \
             >/etc/nginx/sites-available/scifight.conf
    envsubst </.attach/uwsgi-scifight.ini \
             >/etc/uwsgi/apps-available/scifight.ini
    ln -s /etc/nginx/sites-available/scifight.conf \
          /etc/nginx/sites-enabled/
    ln -s /etc/uwsgi/apps-available/scifight.ini \
          /etc/uwsgi/apps-enabled/

    rm /etc/nginx/sites-enabled/default

    sudo -u "$SCIFIGHT_OWNER_USER" --preserve-env -- sh -c '
        set -o errexit
        envsubst </.attach/settings_secret.py \
                 >scifight_proj/settings_secret.py

        . ./.virtualenv/bin/activate
        ./manage.py check --deploy
        ./manage.py migrate
        deactivate'

    touch /.container_configuration_done
fi
    
uwsgi --ini /etc/uwsgi/apps-enabled/scifight.ini
exec nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
