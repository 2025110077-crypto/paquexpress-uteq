from fastapi import APIRouter
from database import get_connection

router = APIRouter()

@router.get("/")
def listar_paquetes():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM paquetes WHERE estado = 'pendiente'")
    paquetes = cursor.fetchall()
    conn.close()
    return paquetes

@router.get("/{agente_id}")
def paquetes_por_agente(agente_id: int):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM paquetes WHERE agente_id = %s AND estado = 'pendiente'", (agente_id,))
    paquetes = cursor.fetchall()
    conn.close()
    return paquetes