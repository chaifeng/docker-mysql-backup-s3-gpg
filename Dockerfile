FROM mariadb:10.1

ENV AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    AWS_DEFAULT_REGION="us-east-1" \
    AWS_ENDPOINT="" \
    BACKUP_SCHEDULE="0 0 * * *" \
    BACKUP_BUCKET="backup" \
    BACKUP_PREFIX="mysql/%Y/%m/%d/mysql-" \
    BACKUP_SUFFIX="-%Y%m%d-%H%M.sql.gz.gpg" \
    PGP_KEY="" \
    PGP_KEYSERVER="hkp://keys.gnupg.net"

#   MYSQL_HOST MYSQL_ROOT_PASSWORD MYSQL_USER MYSQL_PASSWORD MYSQL_DATABASE

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
           python3 python3-pip python3-setuptools python3-wheel \
           cron wget \
    && pip3 install awscli \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && echo "Done."

COPY *.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["cron"]
