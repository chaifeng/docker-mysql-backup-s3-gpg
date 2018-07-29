#!/bin/bash
[[ -n "${DEBUG:-}" ]] && set -x
set -eu -o pipefail

BACKUP_SCRIPT="${BASH_SOURCE%/*}/mysql-backup.sh"

if [[ -z "${PGP_KEY:-}" ]]; then
    printf 'Fatal: environment variable PGP_KEY is empty.\nNeed your PGP key to encrypt files.\nExit in 10 seconds.\n'
    sleep 10
    exit 1
fi

if [[ -n "${MYSQL_ROOT_PASSWORD:-}" ]]; then
    MYSQL_USER=root
    MYSQL_PASSWORD="$MYSQL_ROOT_PASSWORD"
fi

echo "MySQL host: ${MYSQL_HOST:-localhost}, user: ${MYSQL_USER:=root}"

export MYSQL_USER MYSQL_PASSWORD

if grep '^\(http\|https\|ftp\)://' <<< "$PGP_KEY" &>/dev/null; then
  echo "Download PGP key from $PGP_KEY ..." >&2
  wget --no-check-certificate -O /pgp-key.txt "$PGP_KEY"
  PGP_KEY=/pgp-key.txt
fi

if [[ -f "${PGP_KEY}" ]]; then
  echo "Import PGP key from local file $PGP_KEY ..." >&2
  PGP_KEY="$(gpg --import "$PGP_KEY" |& grep -o '[0-9A-F]\{16,\}')"
  export PGP_KEY
fi

while ! gpg --list-key "${PGP_KEY}"; do
    gpg --keyserver "${PGP_KEYSERVER}" --recv-keys "${PGP_KEY}" && break;
    echo "Error in retriving PGP key ${PGP_KEY}, retry in 5 seconds ..."
    sleep 5
done

gpg --update-trustdb --trusted-key "${PGP_KEY}"

export -p | grep '\(AWS\|BACKUP\|PGP\|MYSQL\|DEBUG\|TZ\)' > /etc/profile.d/s3.sh

echo "${BACKUP_SCHEDULE} root $BACKUP_SCRIPT >/dev/null" | /usr/bin/tee /etc/cron.d/backup

case "$1" in
    cron)
        echo "Backing up ${MYSQL_DATABASE:-all databases} at '${BACKUP_SCHEDULE}' ..."
        exec /usr/sbin/cron -f -L 15
        ;;
    backup)
        exec "$BACKUP_SCRIPT"
        ;;
    *)
        exec "$@"
        ;;
esac
