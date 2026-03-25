from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import auth, paquetes, entregas

app = FastAPI(title="Paquexpress API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["Autenticación"])
app.include_router(paquetes.router, prefix="/paquetes", tags=["Paquetes"])
app.include_router(entregas.router, prefix="/entregas", tags=["Entregas"])

@app.get("/")
def root():
    return {"mensaje": "API Paquexpress funcionando ✅"}