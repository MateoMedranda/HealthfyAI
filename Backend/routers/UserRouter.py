from fastapi import APIRouter, Depends
from database.mongodb import get_db
from services.UserService import create_user, get_user_by_email, update_user, delete_user, list_users
from models.User import User

router = APIRouter(prefix="/api/users", tags=["Users"])

@router.post("/")
async def create(usuario: User, db=Depends(get_db)):
    return await create_user(usuario, db)

@router.get("/")
async def list(db=Depends(get_db)):
    return await list_users(db)

@router.get("/{email}")
async def get_by_id(email: str, db=Depends(get_db)):
    return await get_user_by_email(email, db)

@router.put("/{email}")
async def update(email: str, usuario: User, db=Depends(get_db)):
    return await update_user(email, usuario, db)

@router.delete("/{email}")
async def delete(email: str, db=Depends(get_db)):
    return await delete_user(email, db)
