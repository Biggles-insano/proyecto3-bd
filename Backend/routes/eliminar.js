const express = require('express');
const router = express.Router();
const pool = require('../db');

// Endpoint para reducir stock de un producto (salida de inventario)
router.post('/', async (req, res) => {
  try {
    const { id_producto, cantidad_a_reducir } = req.body;

    // Verificar existencia del producto
    const producto = await pool.query('SELECT stock_disponible FROM Producto WHERE id_producto = $1', [id_producto]);

    if (producto.rows.length === 0) {
      return res.status(404).json({ error: "Producto no encontrado" });
    }

    const stock_actual = producto.rows[0].stock_disponible;

    if (stock_actual < cantidad_a_reducir) {
      return res.status(400).json({ error: "No hay suficiente stock para esta operación" });
    }

    // Reducir el stock en la tabla Producto
    const result = await pool.query(
      `UPDATE Producto SET stock_disponible = stock_disponible - $1 WHERE id_producto = $2 RETURNING *`,
      [cantidad_a_reducir, id_producto]
    );

    // Registrar el movimiento en la tabla Inventario
    await pool.query(
      `INSERT INTO Inventario (producto_id, cantidad, fecha_movimiento, tipo_movimiento)
       VALUES ($1, $2, CURRENT_DATE, 'salida')`,
      [id_producto, cantidad_a_reducir]
    );

    res.status(200).json({ message: "Stock reducido y movimiento registrado", producto: result.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Hubo un error al reducir el stock del producto" });
  }
});

module.exports = router;
