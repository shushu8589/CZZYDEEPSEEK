from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', env_file_encoding='utf-8', case_sensitive=False)

    app_name: str = 'CZZY_WEB'
    app_env: str = 'development'
    secret_key: str = 'please-change-this-secret'

    sqlserver_host: str = '127.0.0.1'
    sqlserver_port: int = 1433
    sqlserver_user: str = 'sa'
    sqlserver_password: str = ''
    sqlserver_database_order: str = 'CZZYORDER'
    sqlserver_database_code: str = 'CZZYCODE'
    sqlserver_database_mold: str = 'CZZYMOLDCODE'
    sqlserver_database_key: str = 'CZZYKeyList'
    sqlserver_odbc_driver: str = 'ODBC Driver 18 for SQL Server'

    access_token_expire_minutes: int = 720
    algorithm: str = 'HS256'
    backend_cors_origins: list[str] = Field(default_factory=lambda: ['http://localhost:5173'])




@lru_cache
def get_settings() -> Settings:
    return Settings()
