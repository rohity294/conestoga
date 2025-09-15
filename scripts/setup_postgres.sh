#!/usr/bin/env bash
set -e

# If not root, re-run as root
if [ "$EUID" -ne 0 ]; then
  exec sudo bash "$0" "$@"
fi

echo "Updating package list..."
apt-get update -y

echo "Installing PostgreSQL..."
apt-get install -y postgresql postgresql-contrib

echo "Starting PostgreSQL service..."
service postgresql start

echo "Creating database user and database..."
sudo -u postgres psql <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_roles WHERE rolname = 'labuser'
   ) THEN
      CREATE ROLE labuser LOGIN PASSWORD 'labpass';
   END IF;
END
\$\$;

CREATE DATABASE labdb OWNER labuser;
GRANT ALL PRIVILEGES ON DATABASE labdb TO labuser;
EOF

echo "PostgreSQL is set up and ready to use!"
echo "Connect using: psql -h localhost -U labuser -d labdb"
