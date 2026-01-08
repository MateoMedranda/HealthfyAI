# 🩺 HealthfyAI Backend

¡Bienvenido a **HealthfyAI**! Este proyecto es el backend de una innovadora plataforma de salud que combina inteligencia artificial, procesamiento de lenguaje natural y visión computacional para brindar asistencia médica personalizada, diagnósticos preliminares y recomendaciones inteligentes.

---

## 🚀 ¿Qué es HealthfyAI?
HealthfyAI es una API desarrollada en **FastAPI** que permite:
- Gestionar usuarios y sus historiales médicos.
- Chatear con un bot médico inteligente (RAG + LLM) que responde preguntas, analiza síntomas y genera recomendaciones.
- Registrar y consultar diagnósticos clínicos, incluyendo análisis dermatológicos, nutricionales y generales.
- Integrar modelos de visión para análisis de imágenes médicas (en desarrollo).

---

## 🧠 Tecnologías principales
- **FastAPI**: Framework web asíncrono y ultrarrápido para Python.
- **MongoDB**: Base de datos NoSQL para almacenar usuarios, historiales y chats.
- **LangChain + Groq**: Orquestación de modelos LLM y RAG para el chatbot médico.
- **HuggingFace Embeddings**: Para procesamiento semántico de textos médicos.
- **ChromaDB**: Vector store para recuperación eficiente de información.
- **Vision AI**: (Próximamente) Análisis de imágenes médicas.

---

## 📦 Estructura del Backend
```
Backend/
├── main.py                # Punto de entrada FastAPI
├── config.py              # Configuración y variables de entorno
├── requeriments.txt       # Dependencias Python
├── database/              # Conexión y utilidades MongoDB
├── models/                # Modelos Pydantic (Usuario, Bot, Imagen, etc.)
├── routers/               # Endpoints REST (usuarios, bot, imágenes)
├── services/              # Lógica de negocio y AI
├── utils/                 # Utilidades (hashing, etc.)
├── ChatbotData/           # Datos y corpus para el bot
└── chroma_db/             # Base de datos vectorial
```

---

## 🔥 Características destacadas
- **Chat Médico Inteligente**: Basado en LLMs y recuperación de contexto clínico.
- **Historial Evolutivo**: Guarda y resume la evolución del paciente.
- **Gestión de Usuarios**: Registro seguro, actualización y consulta.
- **Preparado para IA de Imágenes**: Estructura lista para análisis dermatológico y más.
- **API moderna y documentada**: Swagger UI disponible por defecto.

---

## ⚡ Instalación y uso rápido
1. Clona el repositorio y entra al directorio Backend:
   ```bash
   git clone https://github.com/tuusuario/HealthfyAI.git
   cd HealthfyAI/Backend
   ```
2. Instala las dependencias:
   ```bash
   pip install -r requeriments.txt
   ```
3. Configura tus variables de entorno en un archivo `.env`:
   ```env
   MONGO_URI=...
   MONGO_DB=...
   GROQ_API_KEY=...
   LANGCHAIN_API_KEY=...
   ...
   ```
4. Ejecuta el servidor:
   ```bash
   uvicorn main:app --reload
   ```
5. Accede a la documentación interactiva en: [http://localhost:8000/docs](http://localhost:8000/docs)

---

## 🛡️ Seguridad
- Contraseñas hasheadas con bcrypt.
- CORS habilitado para desarrollo.
- Validaciones estrictas en modelos y endpoints.

---

## 🤖 Endpoints principales
- `/api/users/` — Gestión de usuarios (CRUD)
- `/medical-bot/chat/{session_id}` — Chat con el bot médico
- (Próximamente) `/image-detection/` — Análisis de imágenes

---

## 📚 Créditos y agradecimientos
- [FastAPI](https://fastapi.tiangolo.com/)
- [LangChain](https://www.langchain.com/)
- [MongoDB](https://www.mongodb.com/)
- [Groq](https://groq.com/)
- [HuggingFace](https://huggingface.co/)

---

## 💡 Contribuciones
¡Las contribuciones son bienvenidas! Abre un issue o pull request para sugerir mejoras o reportar bugs.

---

## 🏥 HealthfyAI — ¡Tu salud, potenciada por IA!
