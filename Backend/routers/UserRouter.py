from fastapi import APIRouter, Depends, status, Response
from database.mongodb import get_db
from services.UserService import create_user, get_user_by_email, update_user, delete_user, list_users
from models.User import User

router = APIRouter(prefix="/api/users", tags=["Users"])

@router.post("/")
async def create(usuario: User, response: Response, db=Depends(get_db)):
    result = await create_user(usuario, db)
    if (result["status"] == "error"):
        response.status_code = status.HTTP_400_BAD_REQUEST
    return result

@router.get("/")
async def list(db=Depends(get_db)):
    return await list_users(db)

@router.get("/{email}")
async def email(email: str, response: Response, db=Depends(get_db)):
    result = await get_user_by_email(email, db)
    if (result["status"] == "error"):
        response.status_code = status.HTTP_404_NOT_FOUND
    return result

@router.put("/{email}")
async def update(email: str, usuario: User, response: Response, db=Depends(get_db)):
    result = await update_user(email, usuario, db)
    if(result["status"] == "error"):
        response.status_code = status.HTTP_400_BAD_REQUEST
    return result

@router.delete("/{email}")
async def delete(email: str, db=Depends(get_db)):
    return await delete_user(email, db)
