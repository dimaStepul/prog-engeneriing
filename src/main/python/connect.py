# encoding: UTF-8

import argparse
import logging
from contextlib import contextmanager

# Драйвер PostgreSQL
# Находится в модуле psycopg2-binary, который можно установить командой
# pip install psycopg2-binary или её аналогом.
import psycopg2 as pg_driver
from playhouse.db_url import connect
from playhouse.pool import PooledPostgresqlDatabase, PooledSqliteDatabase
from psycopg2 import pool
from psycopg2.extras import LoggingConnection

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)


# Разбирает аргументы командной строки.
# Выплевывает структуру с полями, соответствующими каждому аргументу.
def parse_cmd_line():
    parser = argparse.ArgumentParser(
        description="Эта программа вычисляет 2+2 при помощи реляционной СУБД"
    )
    parser.add_argument("--pg-host", help="PostgreSQL host name", default="localhost")
    parser.add_argument("--pg-port", help="PostgreSQL port", default=5432)
    parser.add_argument("--pg-user", help="PostgreSQL user", default="postgres")
    parser.add_argument("--pg-password", help="PostgreSQL password", default="postgres")
    parser.add_argument("--pg-database", help="PostgreSQL database", default="postgres")
    parser.add_argument(
        "--use-pool",
        help="Shall we use the connection pool",
        dest="with_pool",
        action="store_true",
    )
    parser.add_argument(
        "--no-use-pool",
        help="Shall we use the connection pool",
        dest="with_pool",
        action="store_false",
    )
    parser.set_defaults(with_pool=True)
    return parser.parse_args()


class ConnectionFactory:
    def __init__(self, open_fxn, close_fxn, create_db_fxn):
        self.create_db_fxn = create_db_fxn
        self.open_fxn = open_fxn
        self.close_fxn = close_fxn

    def getconn(self):
        return self.open_fxn()

    def putconn(self, conn):
        return self.close_fxn(conn)

    def create_db(self):
        return self.create_db_fxn()


def create_connection_factory(args):
    # Создаёт подключение к постгресу в соответствии с аргументами командной строки.
    if args.with_pool:
        print("Connection pool is ON")

        def open_pg():
            return connect(
                f"postgres+pool://{args.pg_user}:{args.pg_password}@{args.pg_host}:{args.pg_port}/{args.pg_database}"
            )

        def close_pg(conn):
            conn.close()

        def create_db_pg():
            return LoggingDatabase(args)

        return ConnectionFactory(
            open_fxn=open_pg, close_fxn=close_pg, create_db_fxn=create_db_pg
        )
    else:
        print("Connection pool is OFF")
        count = 0

        def open_pg():
            nonlocal count
            count += 1
            return pg_driver.connect(
                user=args.pg_user,
                password=args.pg_password,
                host=args.pg_host,
                port=args.pg_port,
            )

        def close_pg(conn):
            conn.close()

        return ConnectionFactory(open_fxn=open_pg, close_fxn=close_pg)


class LoggingDatabase(PooledPostgresqlDatabase):
    def __init__(self, args):
        super(LoggingDatabase, self).__init__(
            database=args.pg_database,
            register_unicode=True,
            encoding=None,
            isolation_level=None,
            host=args.pg_host,
            user=args.pg_user,
            port=args.pg_port,
            password=args.pg_password,
            connection_factory=LoggingConnection,
        )

    def _connect(self):
        conn = super(LoggingDatabase, self)._connect()
        conn.initialize(logger)
        return conn


connection_factory = create_connection_factory(parse_cmd_line())
db = connection_factory.create_db()
