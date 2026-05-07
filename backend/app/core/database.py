from collections.abc import Generator
from urllib.parse import quote_plus

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import get_settings

settings = get_settings()


def _build_connection_url(database: str) -> str:
    driver = quote_plus(settings.sqlserver_odbc_driver)
    password = quote_plus(settings.sqlserver_password)
    return (
        f"mssql+pyodbc://{settings.sqlserver_user}:{password}@{settings.sqlserver_host}:{settings.sqlserver_port}/{database}"
        f'?driver={driver}&TrustServerCertificate=yes'
    )


def _build_engine(database: str) -> Engine:
    return create_engine(_build_connection_url(database), pool_pre_ping=True, future=True)


engines: dict[str, Engine] = {
    'order': _build_engine(settings.sqlserver_database_order),
    'code': _build_engine(settings.sqlserver_database_code),
    'mold': _build_engine(settings.sqlserver_database_mold),
    'key': _build_engine(settings.sqlserver_database_key),
}

SessionLocalMap: dict[str, sessionmaker[Session]] = {
    name: sessionmaker(autocommit=False, autoflush=False, bind=engine)
    for name, engine in engines.items()
}


def get_db(db_name: str = 'order') -> Generator[Session, None, None]:
    db = SessionLocalMap[db_name]()
    try:
        yield db
    finally:
        db.close()


def check_db_connection(engine: Engine) -> bool:
    try:
        with engine.connect() as conn:
            conn.execute(text('SELECT 1'))
        return True
    except Exception:
        return False


def check_all_databases() -> dict[str, bool]:
    return {
        'order_db': check_db_connection(engines['order']),
        'code_db': check_db_connection(engines['code']),
        'mold_db': check_db_connection(engines['mold']),
        'key_db': check_db_connection(engines['key']),
    }


def get_key_db() -> Generator[Session, None, None]:
    yield from get_db('key')
