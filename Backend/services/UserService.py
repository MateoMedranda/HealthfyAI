from models.User import User
from utils.hashing import hash_password, verify_password

#### Servicio para la gestión de usuarios

class UserService:
    def __init__(self, db):
        self.db = db

    async def login_user(self, email: str, password: str):
        """Verifica las credenciales del usuario"""
        try:
            user_data = await self.db.usuarios.find_one({"email": email})
            if not user_data:
                return {"status": "error", "message": "Usuario no encontrado"}
            
            # Verificar contraseña
            if not verify_password(password, user_data["password"]):
                return {"status": "error", "message": "Contraseña incorrecta"}
            
            # Convertir ObjectId a string
            user_data["_id"] = str(user_data["_id"])
            # Retornar dict, no modelo Pydantic
            return {"status": "success", "message": "Login exitoso", "user_data": user_data}
        except Exception as e:
            return {"status": "error", "message": f"Error en servidor: {str(e)}"}

    async def create_user(self, usuario: User):
        # Carga de datos del usuario para crear cuenta
        try:
            user_dict = usuario.model_dump(exclude_none=True)

            print(f"📝 Registrando usuario: {user_dict.get('email')}")
            print(f"📋 Datos recibidos: {user_dict}")

            # 1. Verificar que el email no exista ya en la base de datos
            existing_user = await self.db.usuarios.find_one({"email": user_dict["email"]})
            if existing_user:
                print(f"❌ Email duplicado: {user_dict['email']}")
                return {"status": "error","message": "El correo ya se encuentra registrado"}
                
            # 2. Validar que todos los campos requeridos están presentes
            if not all([user_dict.get("nombre"), user_dict.get("email"), 
                       user_dict.get("password"), user_dict.get("birthdate"), 
                       user_dict.get("gender")]):
                return {"status": "error", "message": "Faltan campos requeridos"}

            # 3. Validar que el password tenga al menos 6 caracteres, un numero y un caracter especial
            pwd = user_dict.get("password", "")
            if len(pwd) < 6:
                return {"status": "error", "message": "La contraseña debe tener al menos 6 caracteres"}
            if not any(char.isdigit() for char in pwd):
                return {"status": "error", "message": "La contraseña debe contener al menos un número"}
            if not any(not char.isalnum() for char in pwd):
                return {"status": "error", "message": "La contraseña debe contener al menos un carácter especial"}

            # Hash de la contraseña antes de guardar
            user_dict["password"] = hash_password(user_dict["password"])
            result = await self.db.usuarios.insert_one(user_dict)
            user_dict["_id"] = str(result.inserted_id)

            print(f"✅ Usuario creado exitosamente: {user_dict['email']}")

            return {"status": "success", "message": "Usuario creado exitosamente", "user_data": user_dict}
        except Exception as e:
            return {"status": "error", "message": f"Error en servidor: {str(e)}"}

    async def get_user_by_email(self, email: str):
        try:
            user_data = await self.db.usuarios.find_one({"email": email})
            if user_data:
                # Convertir ObjectId a string
                user_data["_id"] = str(user_data["_id"])
                return {"status": "success", "message": "Usuario encontrado", "user_data": user_data}
            return {"status": "error", "message": "Usuario no encontrado"}
        except Exception as e:
            return {"status": "error", "message": f"Error en servidor: {str(e)}"}

    async def update_user(self, email: str, usuario: User):
        # Carga de datos del usuario para actualizar cuenta
        try:
            user_dict = usuario.model_dump(exclude_none=True)

            print(f"🔄 Actualizando usuario: {email}")
            print(f"📋 Datos a actualizar: {user_dict}")

            # 1. Verificar que el email no exista ya en la base de datos (excepto el usuario actual)
            if user_dict.get("email") and user_dict.get("email") != email:
                existing_user = await self.db.usuarios.find_one({"email": user_dict.get("email")})
                if existing_user:
                    print(f"❌ Email duplicado: {user_dict['email']}")
                    return {"status": "error","message": "El correo ya se encuentra registrado"}

            # 2. Si la contraseña se está actualizando, validarla y hashearla
            if user_dict.get("password"):
                pwd = user_dict.get("password", "")
                if len(pwd) < 6:
                    return {"status": "error", "message": "La contraseña debe tener al menos 6 caracteres"}
                if not any(char.isdigit() for char in pwd):
                    return {"status": "error", "message": "La contraseña debe contener al menos un número"}
                if not any(not char.isalnum() for char in pwd):
                    return {"status": "error", "message": "La contraseña debe contener al menos un carácter especial"}
                user_dict["password"] = hash_password(user_dict["password"])

            await self.db.usuarios.update_one({"email": email}, {"$set": user_dict})
            updated_user_data = await self.db.usuarios.find_one({"email": email})
            # Convertir ObjectId a string
            updated_user_data["_id"] = str(updated_user_data["_id"])
            
            print(f"✅ Usuario actualizado exitosamente: {email}")
            return {"status": "success", "message": "Usuario actualizado exitosamente", "user_data": updated_user_data}
        except Exception as e:
            return {"status": "error", "message": f"Error en servidor: {str(e)}"}

    async def delete_user(self, email: str):
        result = await self.db.usuarios.delete_one({"email": email})
        return result.deleted_count > 0

    async def list_users(self):
        users_cursor = self.db.usuarios.find()
        users = []
        async for user_data in users_cursor:
            # Convertir ObjectId a string
            user_data["_id"] = str(user_data["_id"])
            users.append(User(**user_data))
        return users

        return users

    async def forgot_password(self, email: str):
        try:
            user_data = await self.db.usuarios.find_one({"email": email})
            if not user_data:
                # Por seguridad, no revelar si el email existe o no
                return {"status": "success", "message": "Si el correo está registrado, recibirás un enlace."}
            
            from datetime import timedelta
            from utils.security import create_access_token
            from utils.email_utils import send_password_reset_email
            
            # Token válido por 15 minutos
            reset_token = create_access_token(
                data={"sub": email, "type": "reset"},
                expires_delta=timedelta(minutes=15)
            )
            
            # Enviar correo
            send_password_reset_email(email, reset_token)
            
            return {"status": "success", "message": "Si el correo está registrado, recibirás un enlace."}
        except Exception as e:
            print(f"Error en forgot_password: {e}")
            return {"status": "error", "message": f"Error en servidor: {str(e)}"}

    async def reset_password(self, token: str, new_password: str):
        try:
            from utils.security import verify_token_payload
            
            payload = verify_token_payload(token)
            if not payload or payload.get("type") != "reset":
                 return {"status": "error", "message": "Token inválido o expirado"}
            
            email = payload.get("sub")
            
            # Validar nueva contraseña
            pwd = new_password
            if len(pwd) < 6:
                return {"status": "error", "message": "La contraseña debe tener al menos 6 caracteres"}
            if not any(char.isdigit() for char in pwd):
                return {"status": "error", "message": "La contraseña debe contener al menos un número"}
            if not any(not char.isalnum() for char in pwd):
                return {"status": "error", "message": "La contraseña debe contener al menos un carácter especial"}
                
            hashed_pwd = hash_password(new_password)
            
            await self.db.usuarios.update_one({"email": email}, {"$set": {"password": hashed_pwd}})
            
            return {"status": "success", "message": "Contraseña actualizada exitosamente"}
        except Exception as e:
             return {"status": "error", "message": f"Error en servidor: {str(e)}"}
