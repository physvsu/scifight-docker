Docker images for Scifight website
==================================

Here is a brief example how to use these images:

    sudo docker network create scifight-network
    sudo docker run \
        -e MYSQL_DATABASE=scifight \
        -e MYSQL_USER=scifight \
        -e MYSQL_PASSWORD=scifight \
        -e MYSQL_ROOT_PASSWORD=scifight \
        --net=scifight-network \
        --net-alias=mariadb-host \
        --name scifight-mariadb \
        --detach \
	    mariadb

    sudo docker run \
        --net=scifight-network \
        --env SCIFIGHT_HOSTNAME='scifight.organization.com' \
        --env SCIFIGHT_SECRET_KEY='secret' \
        --env SCIFIGHT_DB_ENGINE='django.db.backends.mysql' \
        --env SCIFIGHT_DB_HOST=mariadb-host \
        --env SCIFIGHT_DB_PORT=3306 \
        --env SCIFIGHT_DB_NAME=scifight \
        --env SCIFIGHT_DB_USER=scifight \
        --env SCIFIGHT_DB_PASS=scifight \
		--publish 80:80 \
		--name scifight-app \
        -ti scifight/scifight-devel
