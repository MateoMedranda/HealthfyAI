from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from database.mongodb import get_db
from services.AIService import chat_with_bot 

router = APIRouter(prefix="/medical-bot", tags=["Chat with Medical Bot"])

class ChatRequest(BaseModel):
    message: str

@router.post("/chat/{session_id}")
async def chat_endpoint(session_id: str, request: ChatRequest, db = Depends(get_db)):
    try:
        response_text = await chat_with_bot(message=request.message, session_id=session_id, db=db)
        return {"status": "success", "bot_response": response_text}
    except Exception as e:
        print(f"Error en chat: {e}")
        raise HTTPException(status_code=500, detail=str(e))