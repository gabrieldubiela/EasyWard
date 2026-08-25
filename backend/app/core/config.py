from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    APP_ENV: str = "development"
    DATABASE_URL: str
    JWT_SECRET: str
    JWT_REFRESH_SECRET: str
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    JOB_SECRET: str
    CORS_ORIGINS: str = "http://localhost:5173"
    RESEND_API_KEY: str = ""
    RESEND_FROM_EMAIL: str = "noreply@easyward.app"
    FIREBASE_CREDENTIALS: str = ""
    SENTRY_DSN: str = ""
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        
    @property
    def cors_origins_list(self) -> list[str]:
        # divide a string CORS_ORIGINS por vírgula e retorna uma lista
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",")]

    @property
    def is_production(self) -> bool:
        # retorna True se APP_ENV for "production"
        return self.APP_ENV == "production"
    
@lru_cache
def get_settings() -> Settings:
    return Settings()

settings = get_settings()