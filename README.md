# Paquexpres S.A. de C.V. - App de Entregas 📦

Aplicación móvil desarrollada para los agentes de entrega en campo de Paquexpres, enfocada en mejorar la trazabilidad y seguridad en el proceso de entrega de paquetes.

## 🛠️ Tecnologías Utilizadas
* **Aplicación Móvil:** Flutter
* **Backend / API:** FastAPI (Python)
* **Base de Datos:** MySQL

## ✨ Características Principales
* Inicio de sesión seguro con contraseñas encriptadas.
* Visualización de paquetes asignados por ID y destino.
* Mapa interactivo para visualizar la dirección de entrega.
* Captura de fotografía como evidencia de entrega.
* Obtención de ubicación GPS en tiempo real.

## ⚙️ Instrucciones de Instalación

### 1. Base de Datos (MySQL)
1. Iniciar los servicios de Apache y MySQL (ej. usando XAMPP).
2. Crear una base de datos llamada `paquexpress`.
3. Importar el archivo `paquexpress.sql` (ubicado en la carpeta `db`) para generar las tablas y registros iniciales.

### 2. API (FastAPI)
1. Navegar a la carpeta `api`.
2. Instalar las dependencias necesarias:
   `pip install -r requirements.txt`
3. Ejecutar el servidor:
   `uvicorn main:app --reload`
   *(La API correrá por defecto en http://127.0.0.1:8000)*

### 3. Aplicación Móvil (Flutter)
1. Navegar a la carpeta `app`.
2. Descargar las dependencias de Flutter:
   `flutter pub get`
3. Ejecutar la aplicación en un emulador o dispositivo físico:
   `flutter run`

## 🚀 Instrucciones de Uso
1. Iniciar sesión en la aplicación con las credenciales de agente (el hash de la contraseña está configurado en la BD).
2. Seleccionar un paquete de la lista de entregas pendientes.
3. Utilizar el mapa para navegar hacia el destino.
4. Al llegar, tomar la fotografía de evidencia y el sistema capturará automáticamente las coordenadas GPS.
5. Presionar el botón "Paquete entregado" para sincronizar la información con la base de datos.
