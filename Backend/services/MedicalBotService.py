import os
from langchain_groq import ChatGroq
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma
from langchain_community.document_loaders import TextLoader, DirectoryLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_classic.chains import create_history_aware_retriever, create_retrieval_chain
from langchain_classic.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_mongodb.chat_message_histories import MongoDBChatMessageHistory
from datetime import datetime
from pymongo import DESCENDING
from models.MedicalBot import ClinicalRecord
import json
from bson import ObjectId
from config import GROQ_API_KEY, MONGO_URI, MONGO_DB

# configuración para obtener la base de datos vectorial y los datos del bot que son archivos de texto
# OJO: los datos del bot son opcionales, el bot puede funcionar sin ellos pero se recomienda el uso de textos médicos
PERSIST_DIRECTORY = "./chroma_db"
DATA_PATH = "./ChatbotData"

# Variable global para crear el RAG conversasional
conversational_rag_chain = None


def get_session_history(session_id: str):
    # Automaticamente lagchain usa esta función para obtener el historial de mensajes
    return MongoDBChatMessageHistory(
        connection_string=MONGO_URI,
        session_id=session_id,
        database_name=MONGO_DB,
        collection_name="chat_histories"
    )


def initialize_chatbot():
    global conversational_rag_chain
    print("🔄 Inicializando Medical Bot (Groq + RAG)...")
    api_key = GROQ_API_KEY
    if not api_key:
        print("⚠️ ADVERTENCIA: GROQ_API_KEY no encontrada.")
        return

    # ======= configuración del chat de groq, embeddings y base de datos vectorial ======
    # Crear el LLM de Groq, modificar temperatura para regular creatividad, alternar modelos si es necesario
    llm = ChatGroq(api_key=api_key,
                   model="llama-3.3-70b-versatile", temperature=0.3)
    embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")

    # Cargar o crear la base de datos vectorial con Chroma
    if os.path.exists(PERSIST_DIRECTORY) and os.listdir(PERSIST_DIRECTORY):
        print("📂 Cargando base de datos vectorial existente...")
        vectorstore = Chroma(
            persist_directory=PERSIST_DIRECTORY, embedding_function=embeddings)
    else:
        print("📚 Procesando documentos médicos...")
        if not os.path.exists(DATA_PATH):
            os.makedirs(DATA_PATH)
        loader = DirectoryLoader(
            DATA_PATH, glob="*.txt", loader_cls=TextLoader, loader_kwargs={'encoding': 'utf-8'})
        docs = loader.load()
        if not docs:
            print(
                "⚠️ No hay documentos en ChatbotData. El bot funcionará sin conocimiento médico específico.")
            vectorstore = Chroma(embedding_function=embeddings,
                                 persist_directory=PERSIST_DIRECTORY)
        else:
            text_splitter = RecursiveCharacterTextSplitter(
                chunk_size=1000, chunk_overlap=200)
            splits = text_splitter.split_documents(docs)
            vectorstore = Chroma.from_documents(
                documents=splits, embedding=embeddings, persist_directory=PERSIST_DIRECTORY)
            print("✅ Documentos procesados.")

    retriever = vectorstore.as_retriever()

    # ======= configuración de prompts y cadenas de RAG ======
    contextualize_q_system_prompt = (
        "Given a chat history and the latest user question "
        "which might reference context in the chat history, "
        "formulate a standalone question which can be understood "
        "without the chat history. Do NOT answer the question, "
        "just reformulate it if needed and otherwise return it as is."
    )

    # recuperación del contexto permitiendo tener memoria de chat
    contextualize_q_prompt = ChatPromptTemplate.from_messages(
        [
            ("system", contextualize_q_system_prompt),
            MessagesPlaceholder("chat_history"),
            ("human", "{input}"),
        ]
    )

    # prompt principal del bot con historial del paciente y contexto médico
    system_prompt = (
        "El nombre del paciente es {user_name}. Siempre responde solo con el nombre no con el apellido"
        "Eres un asistente médico experto y empático. "
        "Tu objetivo es ayudar al paciente basándote en su historial clínico y en el conocimiento médico que se encuentra en los recursos médicos."
        "\n\n"
        "--- Análisis preliminar (Historial clínico del paciente) ---\n"
        "{patient_history}\n"
        "----------------------------------------------------\n\n"
        "Con los resultados obtenidos del historial clínico, debes preguntar por los síntomas, y cuando te describa, contrasta con los recursos médicos"
        "Además, no redactes respuestas tan largas, solo responde con lo que sea necesario"
        "Utiliza los siguientes fragmentos de contexto médico recuperado (RAG) "
        "para responder a la pregunta. Si no sabes, dilo, no inventes nada y que no haya redundancia, se claro con las respuestas"
        "Comportate como un médico experto pero si no sabes la respuesta no inventes"
        "\n\n"
        "{context}"
    )

    # prompt de preguntas y respuestas con contexto
    qa_prompt = ChatPromptTemplate.from_messages(
        [
            ("system", system_prompt),
            MessagesPlaceholder("chat_history"),
            ("human", "{input}"),
        ]
    )

    history_aware_retriever = create_history_aware_retriever(
        llm, retriever, contextualize_q_prompt)
    question_answer_chain = create_stuff_documents_chain(llm, qa_prompt)
    rag_chain = create_retrieval_chain(
        history_aware_retriever, question_answer_chain)
    conversational_rag_chain = RunnableWithMessageHistory(
        rag_chain,
        get_session_history,
        input_messages_key="input",
        history_messages_key="chat_history",
        output_messages_key="answer",
    )
    print("🤖 Medical Bot listo.")


class MedicalBotService:

    def __init__(self, db):
        self.db = db

    async def create_conversation(self, session_id: str, user_id: str, title: str):
        current_time = datetime.utcnow()
        new_conversation = {
            "session_id": session_id,
            "user_id": user_id,
            "title": title,
            "created_at": current_time,
            "updated_at": current_time
        }
        await self.db["conversations"].insert_one(new_conversation)

    async def update_conversation_timestamp(self, session_id: str):
        current_time = datetime.utcnow()
        await self.db["conversations"].update_one(
            {"session_id": session_id},
            {"$set": {"updated_at": current_time}}
        )

    async def delete_conversation(self, session_id: str):
        delete_conversation = await self.db["conversations"].delete_one({"session_id": session_id})
        if delete_conversation.deleted_count == 0:
            return {"status": "error", "message": "Conversación no encontrada"}
        return {"status": "success", "message": "Conversación eliminada"}

    async def get_all_conversations(self, user_id: str):
        conversations = []
        cursor = self.db["conversations"].find(
            {"user_id": user_id}).sort("updated_at", -1)
        async for convo in cursor:
            conversations.append({
                "session_id": convo["session_id"],
                "title": convo.get("title", "Conversación sin título"),
                "date": convo.get("updated_at") or convo.get("created_at")
            })
        return {"status": "success", "conversations": conversations}

    async def get_chat_messages(self, session_id: str):
        messages = []
        cursor = self.db["chat_histories"].find({"SessionId": session_id}).sort("_id", 1)
        async for doc in cursor:
            try:
                if "History" in doc:
                    msg_content = json.loads(doc["History"])

                    messages.append({
                        "type": msg_content["type"],
                        "content": msg_content["data"]["content"]
                    })
            except Exception as e:
                print(f"Error parseando mensaje: {e}")
                continue
        if not messages:
            return []
        return messages

    async def get_user_name(self, user_id: str):
        user = await self.db.usuarios.find_one({"_id": ObjectId(user_id)})
        return user["nombre"]

    async def chat_with_bot(self, message: str, session_id: str, user_id: str):
        global conversational_rag_chain
        if conversational_rag_chain is None:
            initialize_chatbot()
        conversation_ref = await self.db["conversations"].find_one({"session_id": session_id})
        if not conversation_ref:
            title = message[:40] + "..." if len(message) > 40 else message
            await self.create_conversation(session_id, user_id, title)
        else:
            await self.update_conversation_timestamp(session_id)
        summary_response = await self.get_summary_for_bot(session_id)
        patient_history_txt = summary_response.get(
            "content", "Sin historial previo.")
        user_name = await self.get_user_name(user_id)

        response = conversational_rag_chain.invoke(
            {
                "input": message,
                "patient_history": patient_history_txt,
                "user_name": user_name
            },
            config={"configurable": {"session_id": session_id}},
        )
        return {"content": response["answer"]}

    async def save_clinical_record(self, session_id: str, record: ClinicalRecord):
        try:
            record_dict = record.model_dump()
            record_dict['session_id'] = session_id
            result = await self.db.clinical_records.insert_one(record_dict)
            return {"status": "success", "message": "Registro guardado exitosamente", "content": str(result.inserted_id)}
        except Exception as e:
            print(f"Error: {e}")
            return {"status": "error", "message": "Error guardando el registro"}

    async def get_patient_history(self, session_id: str, limit: int):
        try:
            cursor = self.db.clinical_records.find(
                {"session_id": session_id}
            ).sort("fecha_registro", DESCENDING).limit(limit)
            history = []
            async for doc in cursor:
                doc.pop('_id', None)
                doc.pop('session_id', None)
                try:
                    record = ClinicalRecord(**doc)
                    history.append(record)
                except Exception as e:
                    print(f"Error parsing: {e}")
                    continue
            return {"status": "success", "message": "Historial obtenido exitosamente", "content": history}
        except Exception as e:
            return {"status": "error", "message": f"Error base de datos"}

    async def get_summary_for_bot(self, session_id: str):
        response = await self.get_patient_history(session_id, limit=3)
        if response["status"] == "error":
            return response
        records = response["content"]
        if not records:
            return {"status": "success", "message": "No hay registros", "content": "No hay registros clínicos previos. Es un paciente nuevo."}
        summary = "HISTORIAL EVOLUTIVO (Más reciente primero):\n"
        for rec in records:
            fecha_str = rec.fecha_registro.strftime("%Y-%m-%d")
            dx = rec.diagnostico.condicion_principal
            gravedad = rec.diagnostico.gravedad
            evolucion = rec.diagnostico.estado_evolutivo
            sintomas_list = rec.detalles_medicos.sintomas[:3] if rec.detalles_medicos.sintomas else [
                "No especificados"]
            sintomas = ", ".join(sintomas_list)
            linea = (
                f"- [{fecha_str}] Dx: {dx} (Gravedad: {gravedad}). "
                f"Estado: {evolucion}. Síntomas: {sintomas}.\n"
            )
            summary += linea
        return {"status": "success", "message": "Resumen generado exitosamente", "content": summary}
