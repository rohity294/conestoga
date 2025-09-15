#!/usr/bin/env bash
set -e

echo "Updating package list..."
sudo apt-get update -y

echo "Installing PostgreSQL..."
sudo apt-get install -y postgresql postgresql-contrib

echo "Starting PostgreSQL service..."
sudo service postgresql start

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
