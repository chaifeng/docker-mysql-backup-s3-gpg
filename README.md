# Backup MySQL Data to S3/Minio

This docker image backup and encrypt MySQL databases to S3/Minio periodically.

## Usage

### Backup to S3

    docker run -d --restart unless-stopped \
           --name mysql_backup \
           -e AWS_ACCESS_KEY_ID="your-access-key" \
           -e AWS_SECRET_ACCESS_KEY="your-secret-access-keys" \
           -e PGP_KEY=YOUR_PGP_PUBLIC_KEY \
           -e BACKUP_SCHEDULE="0 * * * *" \
           -e MYSQL_DATABASE=your-dbname \
           -e MYSQL_HOST=your-mysql-container \
           -e MYSQL_USER=your-mysql-username \
           -e MYSQL_PASSWORD="your-mysql-password" \
           --network your-network \
           chaifeng/mysql-backup

### Backup to your own Mino server

    docker run -d --restart unless-stopped \
           --name mysql_backup \
           -e AWS_ENDPOINT="https://your.minio.server.example.com" \
           -e AWS_ACCESS_KEY_ID="your-access-key" \
           -e AWS_SECRET_ACCESS_KEY="your-secret-access-keys" \
           -e PGP_KEY=YOUR_PGP_PUBLIC_KEY \
           -e BACKUP_SCHEDULE="0 * * * *" \
           -e MYSQL_DATABASE=your-dbname \
           -e MYSQL_HOST=your-mysql-container \
           -e MYSQL_USER=root \
           -e MYSQL_PASSWORD="your-mysql-password" \
           --network your-network \
           chaifeng/mysql-backup

## Variables

- `AWS_ACCESS_KEY_ID`
  Access Key
- `AWS_SECRET_ACCESS_KEY`
  Securet Access Key
- `PGP_KEY`
  Your PGP public key ID, used to encrypt your backups
- `MYSQL_HOST`
  the host/ip of your mysql database
- `MYSQL_USER`
  the username of your mysql database
- `MYSQL_PASSWORD`
  the password of your mysql database
- `MYSQL_ROOT_PASSWORD`
  the root's password of your mysql database

### Optional variables
- `AWS_ENDPOINT`
  Customize this variable if you are using Minio, the url of your Minio server
- `PGP_KEYSERVER`
  the PGP key server used to retrieve you PGP public key
- `BACKUP_SCHEDULE`
  the interval of cron job to run mysqldump. `0 0 * * *` by default
- `BACKUP_BUCKET`
  the bucket of your S3/Minio
- `BACKUP_PREFIX`
  the default value is `mysql/%Y/%m/%d/mysql-`, please see the strftime(3) manual page
- `BACKUP_SUFFIX`
  the default value is `-%Y%m%d-%H%M.sql.gz.gpg`, please see the strftime(3) manual page
- `MYSQL_DATABASE`
  the database name to dump. Default is to backup all databases
