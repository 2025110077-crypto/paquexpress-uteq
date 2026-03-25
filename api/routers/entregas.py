from fastapi import APIRouter, UploadFile, File, Form
from database import get_connection
import os, shutil

router = APIRouter()
UPLOAD_DIR = "fotos"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/registrar")
async def registrar_entrega(
    paquete_id: int = Form(...),
    agente_id: int = Form(...),
    latitud: float = Form(...),
    longitud: float = Form(...),
    foto: UploadFile = File(...)
):
    foto_path = f"{UPLOAD_DIR}/{paquete_id}_{foto.filename}"
    with open(foto_path, "wb") as f:
        shutil.copyfileobj(foto.file, f)

    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO entregas (paquete_id, agente_id, foto_path, latitud, longitud) VALUES (%s, %s, %s, %s, %s)",
        (paquete_id, agente_id, foto_path, latitud, longitud)
    )
    cursor.execute(
        "UPDATE paquetes SET estado = 'entregado' WHERE id = %s",
        (paquete_id,)
    )
    conn.commit()
    conn.close()

    return {"mensaje": "Entrega registrada exitosamente ✅"}