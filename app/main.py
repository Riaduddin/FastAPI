from fastapi import FastAPI
from fastapi.responses import JSONResponse
app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello, World! Do you know Kibra is a AD. He hates Devops. Unfortunately he is now Additional devops"}

@app.get("/health")
async def health_check():
    return JSONResponse(
        status_code=200,
        content={"status": "healthy"}
    )