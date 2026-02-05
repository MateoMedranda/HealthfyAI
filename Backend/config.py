import os
from dotenv import load_dotenv
import cloudinary
import cloudinary.uploader

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
MONGO_DB = os.getenv("MONGO_DB")
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
LANGCHAIN_TRACING_V2 = os.getenv("LANGCHAIN_TRACING_V2")
LANGCHAIN_ENDPOINT = os.getenv("LANGCHAIN_ENDPOINT")
LANGCHAIN_API_KEY = os.getenv("LANGCHAIN_API_KEY")
LANGCHAIN_PROJECT = os.getenv("LANGCHAIN_PROJECT")
HF_REPO_ID = "MateoMedranda/healthfyai-convnext"
HF_MODEL_FILENAME = "convnext_finetuned.pth"
HF_TOKEN = os.getenv("HUGGING_FACE_TOKEN")
LABEL_ENCODE_PATH = os.getenv("LABEL_ENCODE_PATH")

cloudinary.config(
    cloud_name=os.getenv("CLOUD_NAME"),
    api_key=os.getenv("CLOUDINARY_API_KEY"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET"),
    secure=True
)