const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const HTTP_PORT = 3001;
const HTTPS_PORT = 3443;

// ==================== CORS ====================
// Permite peticiones desde los orígenes de desarrollo local más comunes
// y también desde clientes sin Origin (Postman, Flutter mobile, curl).
const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:5000',
  'http://localhost:5173',
  'http://localhost:8080',
];

app.use(cors({
  origin: (origin, callback) => {
    // Sin origin = Postman / Flutter mobile / curl → permitir
    if (!origin) return callback(null, true);
    if (allowedOrigins.includes(origin)) return callback(null, true);
    callback(new Error(`CORS: origen no permitido: ${origin}`));
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
}));

app.use(express.json());

// ==================== RUTAS ====================

// GET /health — verificación de vida del servidor
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    server: 'ChilaQueen Backend',
    timestamp: new Date().toISOString(),
    mode: 'demo',
  });
});

// GET /api/menu — menú de demo (en producción vendría de Firebase)
app.get('/api/menu', (req, res) => {
  const menu = [
    { id: '1', nombre: 'Chilaquiles Rojos',    categoria: 'chilaquiles',  precio: 85,  disponible: true },
    { id: '2', nombre: 'Chilaquiles Verdes',   categoria: 'chilaquiles',  precio: 85,  disponible: true },
    { id: '3', nombre: 'Chilaquiles Divorciados', categoria: 'chilaquiles', precio: 90, disponible: true },
    { id: '4', nombre: 'Torta de Chilaquiles Rojos',  categoria: 'tortas', precio: 95,  disponible: true },
    { id: '5', nombre: 'Torta de Chilaquiles Verdes', categoria: 'tortas', precio: 95,  disponible: true },
    { id: '6', nombre: 'Molletes Queen',  categoria: 'especialidades', precio: 90,  disponible: true },
    { id: '7', nombre: 'Café Americano', categoria: 'bebidas', precio: 35, disponible: true },
    { id: '8', nombre: 'Jugo de Naranja', categoria: 'bebidas', precio: 40, disponible: true },
  ];
  res.json({ ok: true, data: menu });
});

// POST /api/orders — recibe un pedido de demo
app.post('/api/orders', (req, res) => {
  const { cliente, items, total } = req.body;

  if (!cliente || !items || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ ok: false, error: 'Faltan campos: cliente, items[]' });
  }

  const orderId = `ORD-${Date.now()}`;
  console.log(`[PEDIDO] ${orderId} | Cliente: ${cliente} | Total: $${total} | Items: ${items.length}`);

  res.status(201).json({
    ok: true,
    orderId,
    mensaje: 'Pedido recibido (demo local). Firebase es la fuente real de datos.',
    cliente,
    total,
    items,
    timestamp: new Date().toISOString(),
  });
});

// ==================== ARRANCAR SERVIDOR ====================
const certKey  = path.join(__dirname, 'certs', 'localhost-key.pem');
const certFile = path.join(__dirname, 'certs', 'localhost.pem');

if (fs.existsSync(certKey) && fs.existsSync(certFile)) {
  // HTTPS si existen los certificados locales
  const https = require('https');
  const sslOptions = {
    key:  fs.readFileSync(certKey),
    cert: fs.readFileSync(certFile),
  };
  https.createServer(sslOptions, app).listen(HTTPS_PORT, () => {
    console.log(`ChilaQueen Backend (HTTPS) → https://localhost:${HTTPS_PORT}`);
    console.log('  GET  /health');
    console.log('  GET  /api/menu');
    console.log('  POST /api/orders');
  });
} else {
  // Fallback HTTP si no hay certificados
  app.listen(HTTP_PORT, () => {
    console.log(`ChilaQueen Backend (HTTP)  → http://localhost:${HTTP_PORT}`);
    console.log('  GET  /health');
    console.log('  GET  /api/menu');
    console.log('  POST /api/orders');
    console.log('');
    console.log('Para HTTPS: genera certificados en backend/certs/ (ver README.md)');
  });
}
