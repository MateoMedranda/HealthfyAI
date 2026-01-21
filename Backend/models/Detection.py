from pydantic import BaseModel
from datetime import datetime

class Detection(BaseModel):
    image_url: str
    detected_class: str
    confidence: float
    date: datetime
    user_id: str
    conversation_id: str