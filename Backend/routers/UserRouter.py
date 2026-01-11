from fastapi import APIRouter, Depends, status, Response
from database.mongodb import get_db
from services.UserService import UserService
from models.User import User

router = APIRouter(prefix="/api/users", tags=["Users"])

def get_user_service(db = Depends(get_db)):
    return UserService(db)

@router.post("/")
async def create(usuario: User, response: Response, service: UserService = Depends(get_user_service)):
    result = await service.create_user(usuario)
    if (result["status"] == "error"):
        response.status_code = status.HTTP_400_BAD_REQUEST
    return result

@router.get("/")
async def list(service: UserService = Depends(get_user_service)):
    return await service.list_users()

@router.get("/{email}")
async def email(email: str, response: Response, service: UserService = Depends(get_user_service)):
    result = await service.get_user_by_email(email)
    if (result["status"] == "error"):
        response.status_code = status.HTTP_404_NOT_FOUND
    return result

@router.put("/{email}")
async def update(email: str, usuario: User, response: Response, service: UserService = Depends(get_user_service)):
    result = await service.update_user(email, usuario)
    if(result["status"] == "error"):
        response.status_code = status.HTTP_400_BAD_REQUEST
    return result

@router.delete("/{email}")
async def delete(email: str, service: UserService = Depends(get_user_service)):
    return await service.delete_user(email)