from models.User import User
from utils.hashing import hash_password

#### Servicio para la gestión de usuarios

class UserService:
    def __init__(self, db):
        self.db = db

    async def create_user(self,usuario: User):
        # Carga de datos del usuario para crear cuenta
        user_dict = usuario.model_dump(by_alias=True, exclude_unset=True, exclude_none=True)

        # 1. Verificar que el email no exista ya en la base de datos
        existing_user = await self.db.usuarios.find_one({"email": user_dict["email"]})
        if existing_user:
            return {"status": "error","message": "El correo ya se encuentra registrado"}
            
        # 2. Validar que el password, nombre, correo, fecha nacimiento y genero no estén vacíos
        if(user_dict["password"] == "" or user_dict["nombre"] == "" or user_dict["email"] == "" or user_dict["birthdate"] == "" or user_dict["gender"] == ""):
            return {"status": "error", "message": "No pueden quedar vacios los campos nombre, correo, contraseña, fecha de nacimiento y género"}

        # 3. Validar que el password tenga al menos 6 caracteres, un numero y un caracter especial
        if(len(user_dict["password"]) < 6 or not any(char.isdigit() for char in user_dict["password"]) or not any(not char.isalnum() for char in user_dict["password"])):
            return {"status": "error", "message": "La contraseña debe tener al menos 6 caracteres, un número y un caracter especial"}

        # Hash de la contraseña antes de guardar
        user_dict["password"] = hash_password(user_dict["password"])
        result = await self.db.usuarios.insert_one(user_dict)
        user_dict["_id"] = str(result.inserted_id)

        return {"status": "success", "message": "Usuario creado exitosamente", "user_data": user_dict}

    async def get_user_by_email(self, email: str):
        user_data = await self.db.usuarios.find_one({"email": email})
        if user_data:
            return {"status": "success", "message": "Usuario encontrado", "user_data": User(**user_data)}
        return {"status": "error", "message": "Usuario no encontrado"}

    async def update_user(self, email: str, usuario: User):
        # Carga de datos del usuario para actualizar cuenta
        user_dict = usuario.model_dump(by_alias=True, exclude_unset=True, exclude_none=True)

        # 1. Verificar que el email no exista ya en la base de datos
        existing_user = await self.db.usuarios.find_one({"email": user_dict["email"]})
        if existing_user:
            return {"status": "error","message": "El correo ya se encuentra registrado"}

        await self.db.usuarios.update_one({"email": email}, {"$set": user_dict})
        updated_user_data = await self.db.usuarios.find_one({"email": email})
        return {"status": "success", "message": "Usuario actualizado exitosamente", "user_data": User(**updated_user_data)}

    async def delete_user(self, email: str):
        result = await self.db.usuarios.delete_one({"email": email})
        return result.deleted_count > 0

    async def list_users(self):
        users_cursor = self.db.usuarios.find()
        users = []
        async for user_data in users_cursor:
            users.append(User(**user_data))
        return users

