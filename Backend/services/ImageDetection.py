import torch
import torch.nn as nn
from torchvision import models, transforms
from PIL import Image
import io
from config import MODEL_PATH 

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

_vision_model = None
_vision_transform = None
_vision_class_names = []

def load_vision_model():
    global _vision_model, _vision_transform, _vision_class_names

    print(f"👁️ Cargando Checkpoint (ResNet50) en {DEVICE}...")
    try:
        # 1. CARGAR CHECKPOINT
        checkpoint = torch.load(MODEL_PATH, map_location=DEVICE, weights_only=False)
        
        # 2. RECUPERAR METADATOS
        _vision_class_names = checkpoint['class_names']
        num_classes = checkpoint['num_classes']
        print(f"📂 Clases encontradas: {_vision_class_names}")

        # 3. DEFINIR ARQUITECTURA
        model = models.resnet50(weights=None) 
        model.fc = nn.Linear(model.fc.in_features, num_classes)
        
        # 4. CARGAR LOS PESOS
        model.load_state_dict(checkpoint['model_state_dict'])
        model.to(DEVICE)
        model.eval()
        
        # 5. DEFINIR TRANSFORMACIONES
        transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])

        _vision_model = model
        _vision_transform = transform
        print("✅ Modelo ResNet50 cargado en memoria global.")

    except FileNotFoundError:
        print(f"❌ ERROR CRÍTICO: No se encontró el archivo en {MODEL_PATH}")
    except Exception as e:
        print(f"❌ Error cargando el modelo de visión: {e}")

def convert_class_names(abreviacion: str):
    clases = {
        "akiec": "Queratosis actínica y carcinoma intraepitelial / enfermedad de Bowen",
        "bcc": "Carcinoma basocelular",
        "bkl": "Lesiones tipo queratosis benigna (lentigos solares / queratosis seborreicas / LPLK)",
        "df": "Dermatofibroma",
        "mel": "Melanoma",
        "nv": "Nevos melanocíticos",
        "vasc": "Lesiones vasculares (angiomas, angiokeratomas, granulomas piógenos, hemorragias)"
    }
    
    return clases.get(abreviacion.lower(), "Abreviación no válida")

def predict_image_class(image_bytes):
    """
    Función que usa el modelo global para predecir.
    No instancia nada, solo usa lo que ya está en memoria.
    """
    global _vision_model, _vision_transform, _vision_class_names

    if _vision_model is None:
        print("⚠️ Modelo de visión no estaba listo. Intentando cargar...")
        load_vision_model()
        if _vision_model is None:
            raise Exception("El modelo de visión no se pudo cargar.")

    try:
        # 1. Preprocesar imagen
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image_tensor = _vision_transform(image).unsqueeze(0).to(DEVICE)

        # 2. Inferencia (Sin calcular gradientes para ahorrar memoria)
        with torch.no_grad(): 
            outputs = _vision_model(image_tensor)
            probabilities = torch.nn.functional.softmax(outputs, dim=1)
        
        # 3. Interpretar resultados
        top_prob, top_class = torch.max(probabilities, 1)
        index = top_class.item()

        return {
            "class_name": convert_class_names(_vision_class_names[index]), 
            "confidence": round(top_prob.item(), 4),
            "index": index
        }
    except Exception as e:
        print(f"Error durante la predicción: {e}")
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