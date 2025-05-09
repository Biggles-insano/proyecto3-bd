const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Conexión a MySQL
const db = mysql.createConnection({
  host: 'localhost',
  user: 'tu_usuario',
  password: 'tu_contraseña',
  database: 'nombre_base_de_datos'
});

// GET /productos – Lista de productos
app.get('/productos', (req, res) => {
  const sql = `
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
    JOIN Proveedor pr ON p.proveedor_id = pr.id_proveedor;
  `;

  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// GET /productos/:id – Detalles de un producto
app.get('/productos/:id', (req, res) => {
  const { id } = req.params;
  const sql = `
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
    WHERE p.id_producto = ?;
  `;

  db.query(sql, [id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0) return res.status(404).json({ message: "Producto no encontrado" });
    res.json(results[0]);
  });
});

// GET /productos/:id/disponibilidad – Ver disponibilidad
app.get('/productos/:id/disponibilidad', (req, res) => {
  const { id } = req.params;
  const sql = `SELECT stock_disponible FROM Producto WHERE id_producto = ?`;

  db.query(sql, [id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0) return res.status(404).json({ message: "Producto no encontrado" });

    const disponible = results[0].stock_disponible > 0;
    res.json({ disponible, stock: results[0].stock_disponible });
  });
});

// Inicia el server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Servidor API corriendo en http://localhost:${PORT}`);
});