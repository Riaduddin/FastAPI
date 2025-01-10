import os
from fastapi import FastAPI, HTTPException,Request
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    app_name: str= "MYFastAPI APP"
    admin_email: str
    database_url: str
    secret_key: str
    allowed_hosts: list[str]=["*"]
    debug: bool= False

    class Config:
        env_file=".env"

@lru_cache()
def get_settings():
    return Settings()

app=FastAPI()

@app.middleware("http")
async def validate_host(request: Request,call_next):
    settings=get_settings()
    host=request.headers.get("host","").split(":")[0]
    if settings.debug or host or settings.allowed_hosts:
        return await call_next(request)
    raise HTTPException(status_code=400, detail="Invalid host")


@app.get("/info")
async def info():
    settings=get_settings()
    return {
        "app_name": settings.app_name,
        "admin_email": settings.admin_email,
        "database_url": settings.database_url[:10]+"...."
    }

if __name__=="__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1",port=8080,reload=True)