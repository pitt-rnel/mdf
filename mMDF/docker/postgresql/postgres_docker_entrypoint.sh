#!/usr/bin/env bash
set -e

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

if [ "${1:0:1}" = '-' ]; then
	set -- postgres "$@"
fi

if [ "$1" = 'postgres' ]; then
  # check if postgres data folder exists, if not creates it
  echo "Postgres data folder : ${PGDATA}"

  if [ -e "$PGDATA" ]; then
    echo "Postgres data folder does not exists. Creating it..."
    mkdir -p "$PGDATA"
  fi
  echo "Changing ownership and permissions on data folder"
  chown -R "$(id -u)" "$PGDATA" 2>/dev/null || :
  chmod 700 "$PGDATA" 2>/dev/null || :

  # look specifically for PG_VERSION, as it is expected in the DB dir
  if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Data folder empty. Initializing database files..."
    # no PG_VERSION, this container is started for the first time
    # initialize database folder and files
    file_env 'POSTGRES_INITDB_ARGS'
    if [ "$POSTGRES_INITDB_WALDIR" ]; then
      export POSTGRES_INITDB_ARGS="$POSTGRES_INITDB_ARGS --waldir $POSTGRES_INITDB_WALDIR"
    fi
    echo "Running : initdb --username=postgres $POSTGRES_INITDB_ARGS" 
    eval "initdb --username=postgres $POSTGRES_INITDB_ARGS"

    # check password first so we can output the warning before postgres
    # messes it up
    file_env 'POSTGRES_PASSWORD'
    if [ "$POSTGRES_PASSWORD" ]; then
      pass="PASSWORD '$POSTGRES_PASSWORD'"
      authMethod=md5
    else
      # The - option suppresses leading tabs but *not* spaces. :)
      cat >&2 <<-'EOWARN'
      ****************************************************
      WARNING: No password has been set for the database.
               This will allow anyone with access to the
               Postgres port to access your database. In
               Docker's default configuration, this is
               effectively any other container on the same
               system.

               Use "-e POSTGRES_PASSWORD=password" to set
               it in "docker run".
      ****************************************************
      EOWARN

      pass=
      authMethod=trust
    fi

    echo "Updating pg_hba.conf"
    {
      echo
      echo "host all all all $authMethod"
    } >> "$PGDATA/pg_hba.conf"

    # internal start of server in order to allow set-up using psql-client
    # does not listen on external TCP/IP and waits until start finishes
    #
    echo "Starting database in local mode..."
    PGUSER="${PGUSER:-postgres}" \
      pg_ctl -D "$PGDATA" \
        -o "-c listen_addresses='localhost'" \
        -w start

    file_env 'POSTGRES_USER' 'postgres'
    file_env 'POSTGRES_DB' "$POSTGRES_USER"

    psql=( psql -v ON_ERROR_STOP=1 )


    echo "Adding admin user..."
    if [ "$POSTGRES_DB" != 'postgres' ]; then
      "${psql[@]}" --username postgres <<-EOSQL
        CREATE DATABASE "$POSTGRES_DB" ;
      EOSQL
      echo
    fi

    if [ "$POSTGRES_USER" = 'postgres' ]; then
      op='ALTER'
    else
      op='CREATE'
    fi
    "${psql[@]}" --username postgres <<-EOSQL
      $op USER "$POSTGRES_USER" WITH SUPERUSER $pass ;
    EOSQL
    echo

    psql+=( --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" )

    echo

    echo "Stopping database..."
    PGUSER="${PGUSER:-postgres}" \
      pg_ctl -D "$PGDATA" -m fast -w stop

    echo
    echo 'PostgreSQL init process complete; ready for start up.'
    echo
  fi
fi

exec "$@"

