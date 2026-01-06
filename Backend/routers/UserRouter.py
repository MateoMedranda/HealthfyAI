from fastapi import APIRouter
from database.mongodb import get_db
from models.User import User

router = APIRouter(prefix="/users", tags=["Usuarios"])

@router.post("/")
