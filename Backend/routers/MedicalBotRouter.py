from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from database.mongodb import get_db
from services.MedicalBotService import MedicalBotService
from pydantic import BaseModel

router = APIRouter(prefix="/medical-bot", tags=["Chat with Medical Bot"])

class ChatRequest(BaseModel):
    message: str

def get_medicalbot_service(db = Depends(get_db)):
    return MedicalBotService(db)

@router.post("/chat/{session_id}")
async def chat_endpoint(session_id: str, request: ChatRequest, user_id: str, service: MedicalBotService = Depends(get_medicalbot_service)):
    try:
        response_text = await service.chat_with_bot(message=request.message, session_id=session_id, user_id=user_id)
        return {"status": "success", "bot_response": response_text}
    except Exception as e:
        print(f"Error en chat: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/chat-messages/{session_id}")
async def get_chat_messages_endpoint(session_id: str, service: MedicalBotService = Depends(get_medicalbot_service)):
    try:
        messages_response = await service.get_chat_messages(session_id=session_id)
        return {"status": "success", "messages": messages_response}
    except Exception as e:
        print(f"Error obteniendo mensajes: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
@router.get("/conversations/{user_id}")
async def get_user_conversations(user_id: str, service: MedicalBotService = Depends(get_medicalbot_service)):
    try:
        conversations = await service.get_all_conversations(user_id=user_id)
        return conversations
    except Exception as e:
        print(f"Error obteniendo conversaciones: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/clinical-summary/{session_id}")
async def get_clinical_summary_endpoint(session_id: str, service: MedicalBotService = Depends(get_medicalbot_service)):
    try:
        summary_response = await service.get_clinical_summary(session_id=session_id)
        return summary_response
    except Exception as e:
        print(f"Error obteniendo resumen clínico: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
@router.get("/clinical-records/{session_id}")
async def get_clinical_records_endpoint(session_id: str, limit: int = 5, service: MedicalBotService = Depends(get_medicalbot_service)):
    try:

        records_response = await service.get_patient_history(session_id=session_id, limit=limit)
        return records_response
    except Exception as e:
        print(f"Error obteniendo registros clínicos: {e}")
        raise HTTPException(status_code=500, detail=str(e))