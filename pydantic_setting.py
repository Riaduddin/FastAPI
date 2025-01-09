import os
from fastapi import FastAPI
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str= "MYFastAPI APP"
    admin_email: str
    database_url: str
    secret_key: str

    class Config:
        env_file=".env"

settings=Settings()
app=FastAPI()

@app.get("/info")
async def info():
    return {
        "app_name": settings.app_name,
        "admin_email": settings.admin_email,
        "database_url": settings.database_url[:10]+"...."
    }
