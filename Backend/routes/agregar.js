const express = require('express');
const router = express.Router();
const pool = require('../db');  // Conexión a la base de datos

// Endpoint para añadir producto al inventario
router.post('/', async (req, res) => {
  try {
    const { nombre, descripcion, precio, stock_disponible, categoria_id, marca_id, proveedor_id } = req.body;

    const result = await pool.query(
      `INSERT INTO Producto (nombre, descripcion, precio, stock_disponible, categoria_id, marca_id, proveedor_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [nombre, descripcion, precio, stock_disponible, categoria_id, marca_id, proveedor_id]
    );

    res.status(200).json({ message: "Producto añadido al inventario", producto: result.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Hubo un error al añadir el producto al inventario" });
  }
});

module.exports = router;
