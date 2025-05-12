// const express = require('express');
// const router = express.Router();

// // Ruta de prueba
// router.get('/', (req, res) => {
//   res.json({ mensaje: 'Ventas OK' });
// });

// module.exports = router;

const express = require('express');
const router = express.Router();
const pool = require('../db');

// POST /api/ventas
router.post('/', async (req, res) => {
  const client = await pool.connect();

  try {
    const {
      nombre,
      direccion,
      telefono,
      email,
      nit,
      producto_id,
      cantidad,
      metodo_pago
    } = req.body;

    await client.query('BEGIN');

    // 1. Insertar cliente (fecha_registro con CURRENT_DATE)
    const insertCliente = `
      INSERT INTO Cliente (nombre, direccion, telefono, email, fecha_registro)
      VALUES ($1, $2, $3, $4, CURRENT_DATE)
      RETURNING id_cliente
    `;
    const clienteResult = await client.query(insertCliente, [nombre, direccion, telefono, email]);
    const cliente_id = clienteResult.rows[0].id_cliente;

    // 2. Obtener datos del producto
    const productoResult = await client.query('SELECT * FROM Producto WHERE id_producto = $1', [producto_id]);
    if (productoResult.rowCount === 0) {
      throw new Error('Producto no encontrado');
    }
    const producto = productoResult.rows[0];

    if (producto.stock_disponible < cantidad) {
      throw new Error('No hay suficiente stock para realizar la compra');
    }

    const total = parseFloat(producto.precio) * cantidad;

    // 3. Insertar factura
    const numero_factura = `FAC-${Date.now()}`; // solo simulado
    const insertFactura = `
      INSERT INTO Factura_Maestro (numero_factura, cliente_id, fecha_factura, nit_cliente, total, estado_factura, metodo_pago)
      VALUES ($1, $2, CURRENT_DATE, $3, $4, 'pagada', $5)
      RETURNING id_factura_maestro
    `;
    const facturaResult = await client.query(insertFactura, [
      numero_factura,
      cliente_id,
      nit,
      total,
      metodo_pago
    ]);
    const factura_id = facturaResult.rows[0].id_factura_maestro;

    // 4. Insertar detalle de factura
    const insertDetalle = `
      INSERT INTO Factura_Detalle (factura_maestro_id, producto_id, cantidad, precio_unitario, total_producto)
      VALUES ($1, $2, $3, $4, $5)
    `;
    await client.query(insertDetalle, [
      factura_id,
      producto_id,
      cantidad,
      producto.precio,
      total
    ]);

    // Si tienes triggers para actualizar inventario y validar stock, se ejecutarán automáticamente aquí

    await client.query('COMMIT');

    res.status(201).json({
      mensaje: 'Compra realizada con éxito',
      factura: {
        numero_factura,
        cliente: { nombre, direccion },
        producto: producto.nombre,
        cantidad,
        total: total.toFixed(2)
      }
    });

  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Error en /api/ventas:', err.message);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

module.exports = router;
