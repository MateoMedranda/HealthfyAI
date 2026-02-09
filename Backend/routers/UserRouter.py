from fastapi import APIRouter, Depends, status, Response
from pydantic import BaseModel
from database.mongodb import get_db
from services.UserService import UserService
from models.User import User

router = APIRouter(prefix="/api/users", tags=["Users"])

class LoginRequest(BaseModel):
    email: str
    password: str

class ForgotPasswordRequest(BaseModel):
    email: str

class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str

def get_user_service(db = Depends(get_db)):
    return UserService(db)

@router.post("/login")
async def login(login_data: LoginRequest, response: Response, service: UserService = Depends(get_user_service)):
    result = await service.login_user(login_data.email, login_data.password)
    if (result["status"] == "error"):
        response.status_code = status.HTTP_401_UNAUTHORIZED
        return result
    
    # Generar token JWT
    from utils.security import create_access_token
    from datetime import timedelta
    from config import ACCESS_TOKEN_EXPIRE_MINUTES
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": result["user_data"]["email"]}, expires_delta=access_token_expires
    )
    
    # Incluir token en la respuesta
    result["access_token"] = access_token
    result["token_type"] = "bearer"
    
    return result

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

@router.post("/forgot-password")
async def forgot_password(request: ForgotPasswordRequest, service: UserService = Depends(get_user_service)):
    return await service.forgot_password(request.email)

@router.post("/reset-password")
async def reset_password(request: ResetPasswordRequest, response: Response, service: UserService = Depends(get_user_service)):
    result = await service.reset_password(request.token, request.new_password)
    if result["status"] == "error":
        response.status_code = status.HTTP_400_BAD_REQUEST
    return result