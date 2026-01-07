from models.User import User
from utils.hashing import hash_password

async def create_user(usuario: User, db):
    # Carga de datos del usuario para crear cuenta
    user_dict = usuario.model_dump(by_alias=True, exclude_unset=True)

    # Validaciones exhaustivas
    # 1. Verificar que el email no exista ya en la base de datos
    existing_user = await db.usuarios.find_one({"email": user_dict["email"]})
    if existing_user:
        return {"status": "error","message": "El correo ya se encuentra registrado"}
        
    # 2. Validar que el password, nombre y correo no estén vacíos
    if(user_dict["password"] == "" or user_dict["nombre"] == "" or user_dict["email"] == ""):
        return {"status": "error", "message": "No pueden quedar vacios los campos nombre, correo, contraseña"}
    
    # 3. Validar que el password tenga al menos 6 caracteres, un numero y un caracter especial
    if(len(user_dict["password"]) < 6 or not any(char.isdigit() for char in user_dict["password"]) or not any(not char.isalnum() for char in user_dict["password"])):
        return {"status": "error", "message": "La contraseña debe tener al menos 6 caracteres, un número y un caracter especial"}

    user_dict["password"] = hash_password(user_dict["password"])
    result = await db.usuarios.insert_one(user_dict)
    user_dict["_id"] = str(result.inserted_id)

    return {"status": "success", "message": "Usuario creado exitosamente", "user_data": user_dict}

async def get_user_by_email(email: str, db):
    user_data = await db.usuarios.find_one({"email": email})
    if user_data:
        return User(**user_data)
    return None

async def update_user(email: str, usuario: User, db):
    user_dict = usuario.model_dump(by_alias=True, exclude_unset=True)
    await db.usuarios.update_one({"email": email}, {"$set": user_dict})
    updated_user_data = await db.usuarios.find_one({"email": email})
    return User(**updated_user_data)

async def delete_user(email: str, db):
    result = await db.usuarios.delete_one({"email": email})
    return result.deleted_count > 0

async def list_users(db):
    users_cursor = db.usuarios.find()
    users = []
    async for user_data in users_cursor:
        users.append(User(**user_data))
    return users

