from pydantic import BaseModel, Field
from typing import Optional

class User(BaseModel):
    id: Optional[str] = Field(None, alias="_id")
    
    # Datos de la cuenta
    nombre: str
    email: str
    password: str

    # Datos como paciente Opcionales, se pueden agregar después
    #age: int
    #weight: float
    #height: float
    #medical_conditions: str
    #medications: str
    #allergies: str

