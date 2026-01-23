import torch
import torch.nn as nn
import timm
import joblib
from PIL import Image
import torchvision.transforms as transforms
import io
from config import MODEL_PATH, LABEL_ENCODE_PATH
import os
from datetime import datetime
from database.mongodb import get_db

async def save_image_locally(file_bytes: bytes, filename: str, conversation_id: str) -> str:
    images_dir = os.path.join(os.getcwd(), "images", str(conversation_id))
    os.makedirs(images_dir, exist_ok=True)
    image_path = os.path.join(images_dir, filename)
    with open(image_path, "wb") as f:
        f.write(file_bytes)
    rel_path = os.path.relpath(image_path, os.getcwd())
    return rel_path

async def list_detections(user_id: str):
    db = get_db()
    cursor = db["clinical_records"].find(
        {"user_id": user_id, "origen_datos.cnn_usado": True}
    ).sort("fecha_registro", -1)
    
    detections = []
    async for d in cursor:
        detections.append({
            "image_url": d["origen_datos"]["imagen_id"],
            "detected_class": d["diagnostico"]["condicion_principal"],
            "confidence": d["origen_datos"]["cnn_confianza"],
            "date": d["fecha_registro"],
            "conversation_id": d.get("session_id", "")
        })
    return detections

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

_vision_model = None
_vision_transform = None
_vision_class_names = []

def load_vision_model():
    global _vision_model, _vision_transform, _vision_class_names

    print(f"👁️ Cargando Checkpoint (ConvNeXt Tiny) en {DEVICE}...")

    try:
        le = joblib.load(LABEL_ENCODE_PATH)
        _vision_class_names = list(le.classes_)
        num_classes = len(_vision_class_names)

        print(f"📂 Clases encontradas: {_vision_class_names}")

        model = timm.create_model(
            "convnext_tiny",
            pretrained=False,
            num_classes=num_classes
        )

        model.load_state_dict(
            torch.load(MODEL_PATH, map_location=DEVICE)
        )

        model.to(DEVICE)
        model.eval()

        transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(
                [0.485, 0.456, 0.406],
                [0.229, 0.224, 0.225]
            )
        ])

        _vision_model = model
        _vision_transform = transform

        print("✅ Modelo ConvNeXt cargado en memoria global.")

    except FileNotFoundError:
        print(f"❌ ERROR: No se encontró el modelo en {MODEL_PATH}")
    except Exception as e:
        print(f"❌ Error cargando el modelo de visión: {e}")

def predict_image_class(image_bytes):
    global _vision_model, _vision_transform, _vision_class_names

    if _vision_model is None:
        print("⚠️ Modelo no cargado. Inicializando...")
        load_vision_model()
        if _vision_model is None:
            raise Exception("El modelo de visión no se pudo cargar.")

    try:
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image_tensor = _vision_transform(image).unsqueeze(0).to(DEVICE)

        with torch.no_grad():
            outputs = _vision_model(image_tensor)
            probabilities = torch.nn.functional.softmax(outputs, dim=1)

        top_prob, top_class = torch.max(probabilities, 1)
        index = top_class.item()

        return {
            "class_name": _vision_class_names[index],
            "confidence": round(top_prob.item(), 4),
            "index": index
        }

    except Exception as e:
        print(f"❌ Error durante la predicción: {e}")
        raise e

    
'''
async def calcular_gravedad_con_ia(cnn_resultado: str, sintomas: list[str]) -> str:
    if not GROQ_API_KEY:
        return "Desconocida (Falta API Key)"
        
    llm = ChatGroq(api_key=GROQ_API_KEY, model="llama-3.3-70b-versatile", temperature=0.1)
    
    prompt = ChatPromptTemplate.from_template("""
        Eres un asistente médico experto. Analiza los siguientes datos:
        1. Diagnóstico visual (CNN): {cnn_result}
        2. Síntomas reportados por paciente: {sintomas}
        
        Tu tarea es determinar la GRAVEDAD del caso.
        Reglas:
        - Si es algo estético o leve (ej. acné simple), suele ser "Baja".
        - Si hay dolor intenso, infección visible o sospecha oncológica, es "Alta" o "Critica".
        
        Responde SOLAMENTE con una de estas palabras: Baja, Media, Alta, Critica.
    """)
    
    chain = prompt | llm
    resultado = await chain.ainvoke({
        "cnn_result": cnn_resultado,
        "sintomas": ", ".join(sintomas)
    })
    
    return resultado.content.strip() 
    
async def determinar_estado_evolutivo(user_id: str, zona_cuerpo: str, db) -> str:
    ultimo_registro = await db["clinical_records"].find_one(
        {"user_id": user_id, "detalles_medicos.zona_cuerpo": zona_cuerpo},
        sort=[("fecha_registro", -1)] 
    )
    
    if not ultimo_registro:
        return "Nuevo"
    
    return "Igual"
'''
# El codigo comentado falta definir, ya que primero se debe probar el modelo predictivo de imagenes