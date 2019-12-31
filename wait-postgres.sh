#!/bin/bash


#### Phoenix application tries to connect on psql before PSQL init process is complete
#### this script awaits until psql is ready for start up
#### to run phoenix db commands
set -e

host="$1"
shift
cmd="$@"

until PGPASSWORD=postgres psql -h "$host" -U "postgres" -c '\q'; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 1;
done

>&2 echo "Postgres is up - executing command"

echo "Creating database..."
mix ecto.create

echo "Migration database..."
mix ecto.migrate

echo "Running seeds..."
mix run priv/repo/seeds.exs

echo "Runnning yarn install..."
cd assets && yarn install && cd ..

exec $cmd
