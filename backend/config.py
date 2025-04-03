from pydantic_settings import BaseSettings, SettingsConfigDict
import os


class TortoiseSettings(BaseSettings):
    #db_connection: str = os.environ['DATABASE_URL']
    db_connection: str = "sqlite://db.sqlite3"

tortoise_settings = TortoiseSettings()
