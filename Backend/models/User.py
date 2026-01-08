from pydantic import BaseModel, Field
from typing import Optional

class User(BaseModel):
    id: Optional[str] = Field(None, alias="_id")
    
    # Datos de la cuenta
    nombre: str
    email: str
    password: str
    birthdate: str
    gender: str

    # Datos como paciente Opcionales, se pueden agregar después
    weight: Optional[float] = None
    height: Optional[float] = None
    medical_conditions: Optional[str] = None
    medications: Optional[str] = None
    allergies: Optional[str] = None