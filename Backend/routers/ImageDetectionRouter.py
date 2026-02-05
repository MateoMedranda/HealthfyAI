import os
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from services.ImageDetection import predict_image_class, list_detections, upload_image_to_cloudinary
from uuid import uuid4
from pydantic import BaseModel
from database.mongodb import get_db
from services.MedicalBotService import MedicalBotService
from models.MedicalBot import ClinicalRecord, OrigenDatos, DiagnosticoDetalle, DetallesMedicos

router = APIRouter(prefix="/image-prediction", tags=["Image Prediction"])


class ChatRequest(BaseModel):
    message: str


def get_medicalbot_service(db=Depends(get_db)):
    return MedicalBotService(db)


@router.post("/detect-image")
async def detect_image(file: UploadFile = File(...), user_id: str = '', conversation_id: str = '', service: MedicalBotService = Depends(get_medicalbot_service)):
    try:
        image_bytes = await file.read()
        result = predict_image_class(image_bytes)
        _, ext = os.path.splitext(file.filename)
        filename = f"{uuid4()}{ext}"
        cloudinary_data = await upload_image_to_cloudinary(
            file_bytes=image_bytes,
            filename=filename,
            conversation_id=conversation_id
        )

        image_url = cloudinary_data["url"]

        clinical_record = ClinicalRecord(
            tipo_analisis="Dermatológico",
            origen_datos=OrigenDatos(
                cnn_usado=True,
                cnn_confianza=result["confidence"],
                imagen_id=image_url
            ),
            diagnostico=DiagnosticoDetalle(
                condicion_principal=result["class_name"],
                gravedad="Media",
                estado_evolutivo="Nuevo"
            ),
            detalles_medicos=DetallesMedicos(
                sintomas=["Detectado por análisis de imagen"],
                zona_cuerpo="No especificada"
            ),
            recomendacion_bot="Se recomienda iniciar una conversación con el asistente médico para obtener más detalles y recomendaciones personalizadas.",
            user_id=user_id
        )

        await service.save_clinical_record(session_id=conversation_id, record=clinical_record)

        return {
            "class_name": result["class_name"],
            "confidence": result["confidence"],
            "image_url": image_url,
            "message": "Registro clínico creado exitosamente"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/detections")
async def get_detections(user_id: str):
    try:
        detections = await list_detections(user_id)
        return detections
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
