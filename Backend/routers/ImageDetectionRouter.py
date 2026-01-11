from fastapi import APIRouter, UploadFile, File, HTTPException
from pydantic import BaseModel
from services.ImageDetection import predict_image_class

router = APIRouter(prefix="/image-prediction", tags=["Image Prediction"])

class ChatRequest(BaseModel):
    message: str

@router.post("/")
async def predict_image(file: UploadFile = File(...)):
    try:
        image_bytes = await file.read()
        result = predict_image_class(image_bytes)
        return {"status": "success", "prediction": result}
    except Exception as e:
        print(f"Error en chat: {e}")
        raise HTTPException(status_code=500, detail=str(e))

