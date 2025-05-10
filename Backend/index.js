const express = require('express');
const cors = require('cors');
const app = express();
const productosRoutes = require('./routes/productos');
const ventasRoutes = require('./routes/ventas');

app.use(cors());
app.use(express.json());

// Rutas
app.use('/api/productos', productosRoutes);
app.use('/api/ventas', ventasRoutes);

// Puerto
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
