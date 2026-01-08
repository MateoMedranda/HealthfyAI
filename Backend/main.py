from fastapi import FastAPI
from contextlib import asynccontextmanager
from routers.UserRouter import router as user_router
from routers.MedicalBotRouter import router as medical_bot_router
from database.mongodb import connect_to_mongo, close_mongo_connection
from services.AIService import initialize_chatbot
from fastapi.middleware.cors import CORSMiddleware

@asynccontextmanager
async def lifespan(app: FastAPI):
    connect_to_mongo() 
    print("🚀 Arrancando servidor y cargando modelos de IA...")
    initialize_chatbot() 
    
    yield
    
    print("🛑 Apagando servidor...")
    close_mongo_connection()

app = FastAPI(title="Healthfy API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(user_router)
app.include_router(medical_bot_router)

@app.get("/")
def read_root():
    return {"message": "Healthfy API is running 🤖"}

