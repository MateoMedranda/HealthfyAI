import os
from dotenv import load_dotenv
from langchain_groq import ChatGroq
from langchain_huggingface import HuggingFaceEmbeddings 
from langchain_chroma import Chroma
from langchain_community.document_loaders import TextLoader, DirectoryLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_classic.chains import create_history_aware_retriever, create_retrieval_chain
from langchain_classic.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_community.chat_message_histories import SQLChatMessageHistory

load_dotenv()

PERSIST_DIRECTORY = "./chroma_db"  
DATA_PATH = "./ChatbotData"              

conversational_rag_chain = None

def get_session_history(session_id: str):
    """
    Crea o recupera el historial desde una base de datos SQLite local.
    El archivo se creará automáticamente como 'chat_history.db'.
    """
    return SQLChatMessageHistory(
        session_id=session_id,
        connection="sqlite:///chat_history.db" 
    )

def initialize_chatbot():
    """
    Esta función se ejecuta AL INICIAR el servidor.
    Carga documentos, crea embeddings y prepara la cadena.
    """
    global conversational_rag_chain
    
    print("🔄 Inicializando Chatbot de Estrés...")

    # 1. Configurar LLM
    api_key = os.getenv("GROQ_API_KEY")
    if not api_key:
        raise ValueError("GROQ_API_KEY no encontrada en .env")
        
    llm = ChatGroq(api_key=api_key, model="llama-3.3-70b-versatile")

    # 2. Embeddings (son los traductores de texto a números)
    embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")

    # 3. Cargar o Crear Base de Datos Vectorial
    if os.path.exists(PERSIST_DIRECTORY) and os.listdir(PERSIST_DIRECTORY):
        print("📂 Cargando base de datos vectorial existente...")
        vectorstore = Chroma(persist_directory=PERSIST_DIRECTORY, embedding_function=embeddings)
    else:
        print("📚 Procesando libros por primera vez (esto puede tardar)...")
        # Carga todos los .txt de la carpeta data
        loader = DirectoryLoader(DATA_PATH, glob="*.txt", loader_cls=TextLoader, loader_kwargs={'encoding': 'utf-8'})
        docs = loader.load()
        
        if not docs:
            print("⚠️ No se encontraron documentos en /data. El bot no sabrá nada específico.")
            return

        text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
        splits = text_splitter.split_documents(docs)
        
        vectorstore = Chroma.from_documents(
            documents=splits, 
            embedding=embeddings, 
            persist_directory=PERSIST_DIRECTORY
        )
        print("✅ Libros procesados y guardados.")

    retriever = vectorstore.as_retriever()

    # 4. Prompts Personalizados para Estrés
    
    # Contextualizar pregunta (para que entienda referencias al pasado)
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

    # Prompt del Sistema (Personalidad del Bot)
    system_prompt = (
        "Eres un asistente empático y experto en gestión del estrés llamado 'StressGuard AI'. "
        "Utiliza los siguientes fragmentos de contexto recuperado (libros sobre estrés) "
        "para responder a la pregunta del usuario. "
        "Si no sabes la respuesta basándote en el contexto, di que no lo sabes, no inventes. "
        "Da consejos prácticos, cálidos y accionables. Mantén la respuesta concisa (máximo 4 oraciones)."
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

    # 5. Construir Cadenas
    history_aware_retriever = create_history_aware_retriever(llm, retriever, contextualize_q_prompt)
    question_answer_chain = create_stuff_documents_chain(llm, qa_prompt)
    rag_chain = create_retrieval_chain(history_aware_retriever, question_answer_chain)

    # 6. Cadena final con memoria
    conversational_rag_chain = RunnableWithMessageHistory(
        rag_chain,
        get_session_history,
        input_messages_key="input",
        history_messages_key="chat_history",
        output_messages_key="answer",
    )
    print("🤖 Chatbot listo y cargado.")

def chat_with_bot(message: str, session_id: str):
    """Función que llama el endpoint"""
    if conversational_rag_chain is None:
        raise ValueError("El chatbot no ha sido inicializado.")
        
    response = conversational_rag_chain.invoke(
        {"input": message},
        config={"configurable": {"session_id": session_id}},
    )
    return response["answer"]