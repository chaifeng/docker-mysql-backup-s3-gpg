#!/bin/bash
[[ -n "${DEBUG:-}" ]] && set -x
set -eu -o pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

source /etc/profile.d/s3.sh

AWS_CLI_OPTS=()
[[ -n "${AWS_ENDPOINT}" ]] && AWS_CLI_OPTS+=(--endpoint-url "$AWS_ENDPOINT")

MYSQLDUMP_OPTS=(-u"${MYSQL_USER}" -p"$MYSQL_PASSWORD")

[[ -n "${MYSQL_HOST:-}" ]] && MYSQLDUMP_OPTS+=(-h"$MYSQL_HOST")

if [[ -z "${MYSQL_DATABASE:-}" ]]; then
    MYSQLDUMP_OPTS+=(--all-databases)
    BACKUP_FILENAME=all-databases
else
    MYSQLDUMP_OPTS+=(--databases "$MYSQL_DATABASE")
    BACKUP_FILENAME="$MYSQL_DATABASE"
fi

S3_FILENAME="${BACKUP_BUCKET}/$(date "+${BACKUP_PREFIX}${BACKUP_FILENAME}${BACKUP_SUFFIX}")"

mysqldump "${MYSQLDUMP_OPTS[@]}" \
    | gpg --encrypt -r "${PGP_KEY}" --compress-algo zlib --quiet \
    | aws "${AWS_CLI_OPTS[@]}" s3 cp - \
          "s3://${S3_FILENAME}"

echo "$S3_FILENAME"
