import torch
import timm
import joblib
from PIL import Image
import torchvision.transforms as transforms
import io
import config  # Importar PRIMERO para que cloudinary esté configurado
from config import LABEL_ENCODE_PATH, HF_REPO_ID, HF_MODEL_FILENAME, HF_TOKEN
from huggingface_hub import hf_hub_download
from datetime import datetime
from database.mongodb import get_db
import cloudinary.uploader

async def upload_image_to_cloudinary(file_bytes: bytes, filename: str, conversation_id: str):
    result = cloudinary.uploader.upload(
        file_bytes,
        folder=f"clinical/{conversation_id}",
        public_id=f"{datetime.utcnow().timestamp()}_{filename}",
        resource_type="image"
    )

    return {
        "url": result["secure_url"],
        "public_id": result["public_id"]
    }

async def list_detections(user_id: str):
    db = get_db()
    cursor = db["clinical_records"].find(
        {"user_id": user_id, "origen_datos.cnn_usado": True}
    ).sort("fecha_registro", -1)
    
    detections = []
    async for d in cursor:
        detections.append({
            "image_url": d["origen_datos"]["imagen_id"],
            "class_name": d["diagnostico"]["condicion_principal"],
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

        print(f"📥 Descargando modelo desde Hugging Face: {HF_REPO_ID}...")
        model_path = hf_hub_download(
            repo_id=HF_REPO_ID,
            filename=HF_MODEL_FILENAME,
            token=HF_TOKEN
        )
        print(f"✅ Modelo descargado en: {model_path}")

        model.load_state_dict(
            torch.load(model_path, map_location=DEVICE)
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
        print(f"❌ ERROR: No se encontró el modelo en {HF_REPO_ID}")
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

    
