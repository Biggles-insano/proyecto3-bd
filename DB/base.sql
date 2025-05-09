CREATE TABLE Marca ( id_marca INT PRIMARY KEY AUTO_INCREMENT, nombre_marca VARCHAR(100) NOT NULL, pais_origen VARCHAR(100) ); 

CREATE TABLE Categoria_Producto ( id_categoria INT PRIMARY KEY AUTO_INCREMENT, nombre_categoria VARCHAR(100) NOT NULL ); 

CREATE TABLE Proveedor ( id_proveedor INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(100) NOT NULL, direccion VARCHAR(200), telefono VARCHAR(15), email VARCHAR(100) ); 

CREATE TABLE Producto ( id_producto INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(100) NOT NULL, descripcion TEXT, precio DECIMAL(10, 2) NOT NULL, stock_disponible INT NOT NULL, categoria_id INT, proveedor_id INT, marca_id INT, FOREIGN KEY (categoria_id) REFERENCES Categoria_Producto(id_categoria), FOREIGN KEY (proveedor_id) REFERENCES Proveedor(id_proveedor), FOREIGN KEY (marca_id) REFERENCES Marca(id_marca) ); 

CREATE TABLE Cliente ( id_cliente INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(100) NOT NULL, direccion VARCHAR(200), telefono VARCHAR(15), email VARCHAR(100), fecha_registro DATE NOT NULL ); 

CREATE TABLE Vendedor ( id_vendedor INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(100) NOT NULL, telefono VARCHAR(15), email VARCHAR(100) ); 

CREATE TABLE Factura_Maestro ( id_factura_maestro INT PRIMARY KEY AUTO_INCREMENT, numero_factura VARCHAR(50) NOT NULL, cliente_id INT, fecha_factura DATE NOT NULL, nit_cliente VARCHAR(20) NOT NULL, total DECIMAL(10, 2) NOT NULL, -- Monto total de la factura total_pagado DECIMAL(10, 2) DEFAULT 0.00, -- Monto pagado hasta el momento estado_factura VARCHAR(20) NOT NULL, -- Estado de la factura (pendiente, pagada, anulada) metodo_pago VARCHAR(50), -- Forma de pago (efectivo, tarjeta, etc.) FOREIGN KEY (cliente_id) REFERENCES Cliente(id_cliente) );  

CREATE TABLE Factura_Detalle ( id_factura_detalle INT PRIMARY KEY AUTO_INCREMENT, factura_maestro_id INT, producto_id INT, cantidad INT NOT NULL, precio_unitario DECIMAL(10, 2) NOT NULL, total_producto DECIMAL(10, 2) NOT NULL, -- Monto total de ese producto (cantidad * precio_unitario) FOREIGN KEY (factura_maestro_id) REFERENCES Factura_Maestro(id_factura_maestro), FOREIGN KEY (producto_id) REFERENCES Producto(id_producto) );  

CREATE TABLE Inventario ( id_inventario INT PRIMARY KEY AUTO_INCREMENT, producto_id INT, cantidad INT NOT NULL, fecha_movimiento DATE NOT NULL, tipo_movimiento VARCHAR(20) NOT NULL, -- 'entrada' o 'salida' FOREIGN KEY (producto_id) REFERENCES Producto(id_producto) ); 

CREATE TABLE Sucursal ( id_sucursal INT PRIMARY KEY AUTO_INCREMENT, nombre_sucursal VARCHAR(100) NOT NULL, direccion VARCHAR(200), telefono VARCHAR(15) ); 

CREATE TABLE Venta ( id_venta INT PRIMARY KEY AUTO_INCREMENT, sucursal_id INT, total_venta DECIMAL(10, 2) NOT NULL, fecha_venta DATE NOT NULL, numero_facturas INT NOT NULL, -- Número de facturas asociadas a esta venta FOREIGN KEY (sucursal_id) REFERENCES Sucursal(id_sucursal) ); 

CREATE TABLE Venta_Factura_Maestro ( id_venta_factura INT PRIMARY KEY AUTO_INCREMENT, venta_id INT, factura_maestro_id INT, FOREIGN KEY (venta_id) REFERENCES Venta(id_venta), FOREIGN KEY (factura_maestro_id) REFERENCES Factura_Maestro(id_factura_maestro) ); 

CREATE TABLE Descuento ( id_descuento INT PRIMARY KEY AUTO_INCREMENT, nombre_descuento VARCHAR(100) NOT NULL, porcentaje DECIMAL(5, 2), monto_fijo DECIMAL(10, 2), fecha_inicio DATE NOT NULL, fecha_fin DATE NOT NULL ); 

CREATE TABLE Producto_Descuento ( id_producto_descuento INT PRIMARY KEY AUTO_INCREMENT, producto_id INT, descuento_id INT, cantidad_aplicada DECIMAL(10, 2) NOT NULL, -- El descuento aplicado al producto FOREIGN KEY (producto_id) REFERENCES Producto(id_producto), FOREIGN KEY (descuento_id) REFERENCES Descuento(id_descuento) ); 

