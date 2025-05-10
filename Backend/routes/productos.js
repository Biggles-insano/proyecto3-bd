// Backend/routes/productos.js
const express = require('express');
const router = express.Router();

// Ruta de prueba
router.get('/', (req, res) => {
  res.json({ mensaje: 'Ruta de productos funcionando' });
});

module.exports = router; // ✅ Esta línea es crucial
