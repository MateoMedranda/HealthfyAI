import io
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from services.ImageDetection import predict_image_class, save_detection, list_detections
from uuid import uuid4
from pydantic import BaseModel

router = APIRouter(prefix="/image-prediction", tags=["Image Prediction"])

class ChatRequest(BaseModel):
    message: str

@router.post("/detect-image")
async def detect_image(file: UploadFile = File(...), user_id: str = '', conversation_id: str = ''):
    try:
        image_bytes = await file.read()
        result = predict_image_class(image_bytes)
        filename = f"{str(uuid4())}_{file.filename}"
        detection = await save_detection(
            file_bytes=image_bytes,
            filename=filename,
            detected_class=result["class_name"],
            confidence=result["confidence"],
            user_id=user_id,
            conversation_id=conversation_id
        )
        return detection.dict()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/detections")
async def get_detections(user_id: str):
    try:
        detections = await list_detections(user_id)
        return detections
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

