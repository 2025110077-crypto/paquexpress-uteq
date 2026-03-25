from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from database import get_connection
from passlib.context import CryptContext

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class LoginData(BaseModel):
    email: str
    password: str

@router.post("/login")
def login(data: LoginData):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM agentes WHERE email = %s AND activo = 1", (data.email,))
    agente = cursor.fetchone()
    conn.close()

    if not agente or not pwd_context.verify(data.password, agente["password_hash"]):
        raise HTTPException(status_code=401, detail="Credenciales inválidas")

    return {
        "mensaje": "Login exitoso",
        "agente_id": agente["id"],
        "nombre": agente["nombre"]
    }