# from typing import List
from prometheus_fastapi_instrumentator import Instrumentator
from fastapi import FastAPI

from app import services
from app.schema import UserIn, BaseResponse, UserListOut

app = FastAPI()

Instrumentator().instrument(app).expose(app, endpoint="/metrics")


@app.get("/")
async def index():
    """
    Index route for our application
    """
    return {"message": "Hello from FastAPI -@kiranrakh155@gmail.com ;)"}


@app.get("/health")
async def health_check():
    """
    Health check endpoint for monitoring and CI/CD
    """
    return {"status": "healthy", "service": "fusionpact-backend", "version": "1.0.0"}


@app.post("/users", response_model=BaseResponse)
async def user_create(user: UserIn):
    """
    Add user data to json file
    """
    try:
        services.add_userdata(user.dict())
    except:
        return {"success": False}
    return {"success": True}


@app.get("/users", response_model=UserListOut)
async def get_users():
    """
    Read user data from json file
    """
    return services.read_usersdata()
