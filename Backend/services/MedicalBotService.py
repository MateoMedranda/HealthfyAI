from pymongo import DESCENDING
from models.MedicalBot import ClinicalRecord

async def save_clinical_record(session_id: str, record: ClinicalRecord, db):
    try:
        record_dict = record.model_dump()
        record_dict['session_id'] = session_id
        result = await db.clinical_records.insert_one(record_dict)
        return {"status": "success", "message": "Registro guardado exitosamente", "content": str(result.inserted_id)}
    except Exception as e:
        print(f"Error: {e}") 
        return {"status": "error", "message": "Error guardando el registro"}

async def get_patient_history(session_id: str, limit: int, db):
    try:
        cursor = db.clinical_records.find(
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

async def get_summary_for_bot(session_id: str, db):
    response = await get_patient_history(session_id, limit=3, db=db)
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

        sintomas_list = rec.detalles_medicos.sintomas[:3] if rec.detalles_medicos.sintomas else ["No especificados"]
        sintomas = ", ".join(sintomas_list)

        linea = (
            f"- [{fecha_str}] Dx: {dx} (Gravedad: {gravedad}). "
            f"Estado: {evolucion}. Síntomas: {sintomas}.\n"
        )
        summary += linea

    return {"status": "success", "message": "Resumen generado exitosamente", "content": summary}