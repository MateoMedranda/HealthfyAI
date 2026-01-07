from typing import Union
from fastapi import FastAPI
from routers.UserRouter import router as user_router
from database.mongodb import connect_to_mongo, close_mongo_connection

app = FastAPI()

@app.on_event("startup")
async def startup_event():
    connect_to_mongo()

@app.on_event("shutdown")
async def shutdown_event():
    close_mongo_connection()

app.include_router(user_router)

