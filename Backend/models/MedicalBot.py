from datetime import datetime
from typing import List, Optional, Literal
from pydantic import BaseModel, Field

class OrigenDatos(BaseModel):
    cnn_usado: bool = Field(default=False, description="Si se usó modelo de visión")
    cnn_confianza: Optional[float] = Field(description="Probabilidad del modelo (0.0 a 1.0)")
    imagen_id: Optional[str] = Field(description="Nombre del archivo de imagen si existe")

class DiagnosticoDetalle(BaseModel):
    condicion_principal: str = Field(description="Nombre de la enfermedad o condición detectada")
    gravedad: Literal["Baja", "Media", "Alta", "Critica"] = Field(description="Nivel de severidad")
    estado_evolutivo: Literal["Nuevo", "Mejorando", "Igual", "Empeorando"] = Field(
        description="Comparación con el estado anterior del paciente"
    )

class DetallesMedicos(BaseModel):
    sintomas: List[str] = Field(description="Lista de síntomas reportados")
    zona_cuerpo: Optional[str] = Field(default=None, description="Parte del cuerpo afectada")
    deficiencias_nutricionales: Optional[List[str]] = Field(default=None, description="Posibles faltas de vitaminas/minerales")

class ClinicalRecord(BaseModel):
    tipo_analisis: Literal["Dermatológico", "Nutricional", "General"]
    origen_datos: OrigenDatos
    diagnostico: DiagnosticoDetalle
    detalles_medicos: DetallesMedicos
    recomendacion_bot: str = Field(description="Resumen de la acción recomendada")
    user_id: str = Field(description="ID del usuario")
    fecha_registro: datetime = Field(default_factory=datetime.now, description="Fecha y hora del registro")