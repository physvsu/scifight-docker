# SECURITY WARNING: keep the secret key used in production secret!
# You can generate secret key on this site:
# http://www.miniwebtool.com/django-secret-key-generator/
SECRET_KEY = '$SCIFIGHT_SECRET_KEY'

DATABASES = {
    'default': {
        'ENGINE':   '$SCIFIGHT_DB_ENGINE',
        'NAME':     '$SCIFIGHT_DB_NAME',
        'USER':     '$SCIFIGHT_DB_USER',
        'PASSWORD': '$SCIFIGHT_DB_PASS',
        'HOST':     '$SCIFIGHT_DB_HOST',
        'PORT':      $SCIFIGHT_DB_PORT
    }
}

DEBUG = False
STATIC_ROOT = "$SCIFIGHT_STATIC_DIR"
ALLOWED_HOSTS = ["$SCIFIGHT_HOST_FQN"]
