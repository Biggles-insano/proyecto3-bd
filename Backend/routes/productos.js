// // Backend/routes/productos.js
// const express = require('express');
// const router = express.Router();

// // Ruta de prueba
// router.get('/', (req, res) => {
//   res.json({ mensaje: 'Ruta de productos funcionando' });
// });

// module.exports = router; // ✅ Esta línea es crucial

const express = require('express');
const router = express.Router();
const pool = require('../db'); // Asegúrate de tener configurado el pool de PostgreSQL

// GET /productos - Listar todos los productos
router.get('/', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        p.id_producto,
        p.nombre,
        p.descripcion,
        p.precio,
        p.stock_disponible,
        m.nombre_marca,
        c.nombre_categoria,
        pr.nombre AS proveedor
      FROM Producto p
      JOIN Marca m ON p.marca_id = m.id_marca
      JOIN Categoria_Producto c ON p.categoria_id = c.id_categoria
      JOIN Proveedor pr ON p.proveedor_id = pr.id_proveedor
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /productos/:id - Ver detalles de un producto
router.get('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(`
      SELECT 
        p.id_producto,
        p.nombre,
        p.descripcion,
        p.precio,
        p.stock_disponible,
        m.nombre_marca,
        c.nombre_categoria,
        pr.nombre AS proveedor,
        pr.email AS proveedor_email,
        pr.telefono AS proveedor_telefono
      FROM Producto p
      JOIN Marca m ON p.marca_id = m.id_marca
      JOIN Categoria_Producto c ON p.categoria_id = c.id_categoria
      JOIN Proveedor pr ON p.proveedor_id = pr.id_proveedor
      WHERE p.id_producto = $1
    `, [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /productos/:id/disponibilidad - Ver disponibilidad del producto
router.get('/:id/disponibilidad', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(`
      SELECT stock_disponible FROM Producto WHERE id_producto = $1
    `, [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }
    const disponible = result.rows[0].stock_disponible > 0;
    res.json({ disponible, stock: result.rows[0].stock_disponible });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

