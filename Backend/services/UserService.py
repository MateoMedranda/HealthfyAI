from fastapi import Depends
from models.User import User
from database.mongodb import get_db

async def create_user(usuario: User, db=Depends(get_db)):
    user_dict = usuario.dict(by_alias=True, exclude_unset=True)
    result = await db.usuarios.insert_one(user_dict)
    user_dict["_id"] = str(result.inserted_id)
    return user_dict

async def get_user_by_email(email: str, db=Depends(get_db)):
    user_data = await db.usuarios.find_one({"email": email})
    if user_data:
        return User(**user_data)
    return None

async def update_user(email: str, usuario: User, db=Depends(get_db)):
    user_dict = usuario.dict(by_alias=True, exclude_unset=True)
    await db.usuarios.update_one({"email": email}, {"$set": user_dict})
    updated_user_data = await db.usuarios.find_one({"email": email})
    return User(**updated_user_data)

async def delete_user(email: str, db=Depends(get_db)):
    result = await db.usuarios.delete_one({"email": email})
    return result.deleted_count > 0

async def list_users(db=Depends(get_db)):
    users_cursor = db.usuarios.find()
    users = []
    async for user_data in users_cursor:
        users.append(User(**user_data))
    return users