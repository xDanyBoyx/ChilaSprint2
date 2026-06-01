# ChilaQueen — Backend Local (demo full-stack)

Backend de demostración con Node.js + Express.
Cubre el punto de arquitectura full-stack con soporte HTTPS local y configuración CORS.

> **Firebase Firestore sigue siendo la base principal** de la app.
> Este backend es una capa local/demo que no reemplaza a Firebase.

---

## Instalación y arranque

```bash
cd backend
npm install
npm run dev
```

El servidor imprime la URL al iniciar:
- **Con certificados:** `https://localhost:3443`
- **Sin certificados (fallback):** `http://localhost:3001`

---

## Probar los endpoints

### GET /health
```bash
curl http://localhost:3001/health
```
Respuesta esperada:
```json
{ "status": "ok", "server": "ChilaQueen Backend", ... }
```

### GET /api/menu
```bash
curl http://localhost:3001/api/menu
```
Devuelve el menú de demo con 8 productos.

### POST /api/orders
```bash
curl -X POST http://localhost:3001/api/orders \
  -H "Content-Type: application/json" \
  -d '{"cliente":"Ana","items":[{"id":"1","nombre":"Chilaquiles Rojos","precio":85}],"total":85}'
```
Devuelve el ID de pedido generado localmente.

---

## Generar certificados HTTPS locales

Usa [mkcert](https://github.com/FiloSottile/mkcert) (recomendado):

```bash
# 1. Instalar mkcert
winget install mkcert          # Windows
brew install mkcert            # macOS

# 2. Instalar CA local
mkcert -install

# 3. Generar certificados para localhost
cd backend
mkdir certs
mkcert -key-file certs/localhost-key.pem -cert-file certs/localhost.pem localhost 127.0.0.1
```

Al volver a ejecutar `npm run dev` el servidor arrancará en HTTPS automáticamente.

La carpeta `certs/` está en `.gitignore` y nunca se sube al repositorio.

---

## ¿Qué es CORS?

**CORS (Cross-Origin Resource Sharing)** es el mecanismo del navegador que controla
qué dominios pueden hacer peticiones a este servidor.

Sin CORS configurado, una app en `http://localhost:5173` recibiría un error del
navegador al intentar llamar a `http://localhost:3001/api/menu`.

Este servidor permite explícitamente:
- `http://localhost:3000` (React / CRA)
- `http://localhost:5000` (Flask, etc.)
- `http://localhost:5173` (Vite)
- `http://localhost:8080` (Vue CLI / otros)
- Peticiones sin `Origin` (Postman, Flutter mobile, curl)

---

## Relación con Firebase

| Aspecto | Firebase Firestore | Este backend |
|---|---|---|
| Datos reales | Sí | No |
| Autenticación | Sí | No |
| Pedidos en producción | Sí | No |
| Propósito | Fuente principal | Demo / arquitectura |
| HTTPS automático | Sí (Google) | Manual con mkcert |
