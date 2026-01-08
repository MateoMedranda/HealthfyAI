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
from services.MedicalBotService import get_summary_for_bot
from config import GROQ_API_KEY, MONGO_URI, MONGO_DB

PERSIST_DIRECTORY = "./chroma_db"
DATA_PATH = "./ChatbotData"

conversational_rag_chain = None

def get_session_history(session_id: str):

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
        
    llm = ChatGroq(api_key=api_key, model="llama-3.3-70b-versatile", temperature=0.3)

    embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")

    if os.path.exists(PERSIST_DIRECTORY) and os.listdir(PERSIST_DIRECTORY):
        print("📂 Cargando base de datos vectorial existente...")
        vectorstore = Chroma(persist_directory=PERSIST_DIRECTORY, embedding_function=embeddings)
    else:
        print("📚 Procesando documentos médicos...")
        if not os.path.exists(DATA_PATH):
            os.makedirs(DATA_PATH)
            
        loader = DirectoryLoader(DATA_PATH, glob="*.txt", loader_cls=TextLoader, loader_kwargs={'encoding': 'utf-8'})
        docs = loader.load()
        
        if not docs:
            print("⚠️ No hay documentos en ChatbotData. El bot funcionará sin conocimiento médico específico.")
            vectorstore = Chroma(embedding_function=embeddings, persist_directory=PERSIST_DIRECTORY)
        else:
            text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
            splits = text_splitter.split_documents(docs)
            vectorstore = Chroma.from_documents(documents=splits, embedding=embeddings, persist_directory=PERSIST_DIRECTORY)
            print("✅ Documentos procesados.")

    retriever = vectorstore.as_retriever()

    contextualize_q_system_prompt = (
        "Given a chat history and the latest user question "
        "which might reference context in the chat history, "
        "formulate a standalone question which can be understood "
        "without the chat history. Do NOT answer the question, "
        "just reformulate it if needed and otherwise return it as is."
    )
    
    contextualize_q_prompt = ChatPromptTemplate.from_messages(
        [
            ("system", contextualize_q_system_prompt),
            MessagesPlaceholder("chat_history"),
            ("human", "{input}"),
        ]
    )

    system_prompt = (
        "Eres un asistente médico experto y empático. "
        "Tu objetivo es ayudar al paciente basándote en su historial clínico y en tu conocimiento médico."
        "\n\n"
        "--- HISTORIAL DEL PACIENTE (Desde Base de Datos) ---\n"
        "{patient_history}\n"
        "----------------------------------------------------\n\n"
        "Utiliza los siguientes fragmentos de contexto médico recuperado (RAG) "
        "para responder a la pregunta. Si no sabes, dilo, no inventes nada"
        "\n\n"
        "{context}"

    )
    
    qa_prompt = ChatPromptTemplate.from_messages(
        [
            ("system", system_prompt),
            MessagesPlaceholder("chat_history"),
            ("human", "{input}"),
        ]
    )

    history_aware_retriever = create_history_aware_retriever(llm, retriever, contextualize_q_prompt)
    question_answer_chain = create_stuff_documents_chain(llm, qa_prompt)
    rag_chain = create_retrieval_chain(history_aware_retriever, question_answer_chain)

    conversational_rag_chain = RunnableWithMessageHistory(
        rag_chain,
        get_session_history,
        input_messages_key="input",
        history_messages_key="chat_history",
        output_messages_key="answer",
    )
    print("🤖 Medical Bot listo.")

async def chat_with_bot(message: str, session_id: str, db):
    if conversational_rag_chain is None:
        initialize_chatbot()
        
    summary_response = await get_summary_for_bot(session_id, db)
    patient_history_txt = summary_response.get("content", "Sin historial previo.")

    response = conversational_rag_chain.invoke(
        {
            "input": message, 
            "patient_history": patient_history_txt
        },
        config={"configurable": {"session_id": session_id}},
    )
    
    return response["answer"]