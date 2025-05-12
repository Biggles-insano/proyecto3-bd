------------------------- TABLAS ---------------------------------------------------

CREATE TABLE Marca (
  id_marca SERIAL PRIMARY KEY,
  nombre_marca VARCHAR(100) NOT NULL,
  pais_origen VARCHAR(100)
);

CREATE TABLE Categoria_Producto (
  id_categoria SERIAL PRIMARY KEY,
  nombre_categoria VARCHAR(100) NOT NULL
);

CREATE TABLE Proveedor (
  id_proveedor SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR(200),
  telefono VARCHAR(15),
  email VARCHAR(100) UNIQUE
);

CREATE TABLE Producto (
  id_producto SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  precio NUMERIC(10, 2) NOT NULL CHECK (precio >= 0),
  stock_disponible INT NOT NULL CHECK (stock_disponible >= 0),
  categoria_id INT REFERENCES Categoria_Producto(id_categoria),
  proveedor_id INT REFERENCES Proveedor(id_proveedor),
  marca_id INT REFERENCES Marca(id_marca)
);

CREATE TABLE Cliente (
  id_cliente SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR(200),
  telefono VARCHAR(15),
  email VARCHAR(100) UNIQUE,
  fecha_registro DATE NOT NULL
);

CREATE TABLE Vendedor (
  id_vendedor SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  telefono VARCHAR(15),
  email VARCHAR(100) UNIQUE
);

CREATE TABLE Factura_Maestro (
  id_factura_maestro SERIAL PRIMARY KEY,
  numero_factura VARCHAR(50) NOT NULL,
  cliente_id INT REFERENCES Cliente(id_cliente),
  fecha_factura DATE NOT NULL,
  nit_cliente VARCHAR(20) NOT NULL,
  total NUMERIC(10, 2) NOT NULL,
  total_pagado NUMERIC(10, 2) DEFAULT 0.00,
  estado_factura VARCHAR(20) NOT NULL CHECK (estado_factura IN ('pendiente', 'pagada', 'anulada')),
  metodo_pago VARCHAR(50)
);

CREATE TABLE Factura_Detalle (
  id_factura_detalle SERIAL PRIMARY KEY,
  factura_maestro_id INT REFERENCES Factura_Maestro(id_factura_maestro),
  producto_id INT REFERENCES Producto(id_producto),
  cantidad INT NOT NULL,
  precio_unitario NUMERIC(10, 2) NOT NULL,
  total_producto NUMERIC(10, 2) NOT NULL
);

CREATE TABLE Inventario (
  id_inventario SERIAL PRIMARY KEY,
  producto_id INT REFERENCES Producto(id_producto),
  cantidad INT NOT NULL,
  fecha_movimiento DATE NOT NULL,
  tipo_movimiento VARCHAR(20) NOT NULL -- entrada o salida
);

CREATE TABLE Sucursal (
  id_sucursal SERIAL PRIMARY KEY,
  nombre_sucursal VARCHAR(100) NOT NULL,
  direccion VARCHAR(200),
  telefono VARCHAR(15)
);

CREATE TABLE Venta (
  id_venta SERIAL PRIMARY KEY,
  sucursal_id INT REFERENCES Sucursal(id_sucursal),
  total_venta NUMERIC(10, 2) NOT NULL,
  fecha_venta DATE NOT NULL,
  numero_facturas INT NOT NULL
);

CREATE TABLE Venta_Factura_Maestro (
  id_venta_factura SERIAL PRIMARY KEY,
  venta_id INT REFERENCES Venta(id_venta),
  factura_maestro_id INT REFERENCES Factura_Maestro(id_factura_maestro)
);

CREATE TABLE Descuento (
  id_descuento SERIAL PRIMARY KEY,
  nombre_descuento VARCHAR(100) NOT NULL,
  porcentaje NUMERIC(5, 2),
  monto_fijo NUMERIC(10, 2),
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL
);

CREATE TABLE Producto_Descuento (
  id_producto_descuento SERIAL PRIMARY KEY,
  producto_id INT REFERENCES Producto(id_producto),
  descuento_id INT REFERENCES Descuento(id_descuento),
  cantidad_aplicada NUMERIC(10, 2) NOT NULL
);


------------------------- TRIGGERS ---------------------------------------------------

--Actualizar stock
CREATE OR REPLACE FUNCTION fn_actualizar_stock_despues_venta()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE Producto
  SET stock_disponible = stock_disponible - NEW.cantidad
  WHERE id_producto = NEW.producto_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER actualizar_stock_despues_venta
AFTER INSERT ON Factura_Detalle
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_stock_despues_venta();

--Evitar venta sin stock
CREATE OR REPLACE FUNCTION fn_evitar_venta_sin_stock()
RETURNS TRIGGER AS $$
DECLARE
  stock_actual INT;
BEGIN
  SELECT stock_disponible INTO stock_actual
  FROM Producto
  WHERE id_producto = NEW.producto_id;

  IF stock_actual < NEW.cantidad THEN
    RAISE EXCEPTION 'No hay suficiente stock para realizar la venta';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER evitar_venta_sin_stock
BEFORE INSERT ON Factura_Detalle
FOR EACH ROW
EXECUTE FUNCTION fn_evitar_venta_sin_stock();

--Movimiento inventario Entrada 
CREATE OR REPLACE FUNCTION fn_registrar_movimiento_inventario()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO Inventario (producto_id, cantidad, fecha_movimiento, tipo_movimiento)
  VALUES (NEW.id_producto, NEW.stock_disponible, CURRENT_DATE, 'entrada');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER registrar_movimiento_inventario
AFTER INSERT ON Producto
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_movimiento_inventario();

--Movimiento inventario Salida
CREATE OR REPLACE FUNCTION fn_registrar_salida_inventario()
RETURNS TRIGGER AS $$
BEGIN
  -- Se inserta el movimiento de salida en Inventario
  INSERT INTO Inventario (producto_id, cantidad, fecha_movimiento, tipo_movimiento)
  VALUES (NEW.id_producto, OLD.stock_disponible - NEW.stock_disponible, CURRENT_DATE, 'salida');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER registrar_salida_inventario
AFTER UPDATE OF stock_disponible ON Producto
FOR EACH ROW
WHEN (OLD.stock_disponible > NEW.stock_disponible)
EXECUTE FUNCTION fn_registrar_salida_inventario();



-------------------- INSERTS --------------------------------------
INSERT INTO Marca (nombre_marca, pais_origen) VALUES
('Gucci', 'Italia'),
('Prada', 'Italia'),
('Louis Vuitton', 'Francia'),
('Hermès', 'Francia'),
('Burberry', 'Reino Unido'),
('Dolce & Gabbana', 'Italia'),
('Versace', 'Italia'),
('Balenciaga', 'Francia'),
('Valentino', 'Italia'),
('Yves Saint Laurent', 'Francia');
('Tommy Hilfiger', 'Estados Unidos'),
('Polo Ralph Lauren', 'Estados Unidos'),
('Calvin Klein', 'Estados Unidos'),
('Lacoste', 'Francia'),
('Guess', 'Estados Unidos'),
('Giorgio Armani', 'Italia'),
('Christian Dior', 'Francia'),
('Chanel', 'Francia'),
('Moncler', 'Italia');

INSERT INTO Categoria_Producto (nombre_categoria) VALUES
('Camisas de seda'),
('Chaquetas de cuero'),
('Pantalones de vestir'),
('Vestidos de noche'),
('Trajes a medida'),
('Abrigos de lana'),
('Zapatos italianos'),
('Bolsos premium'),
('Accesorios de piel'),
('Corbatas de diseño');

INSERT INTO Proveedor (nombre, direccion, telefono, email) VALUES
('Luxury Textiles Corp', 'Via della Seta 45, Milán', '+39021234567', 'textiles@luxury.it'),
('Cuero Premium S.A.', 'Calle Tenerías 8, Madrid', '+34915876543', 'cuero@premium.es'),
('Boutique Parisienne', 'Rue Saint-Honoré 202, París', '+33142639874', 'paris@boutique.fr'),
('Silk Road Imports', '5th Avenue 1001, Nueva York', '+12125551234', 'silk@imports.com'),
('Italian Shoemakers', 'Piazza della Scala 5, Milán', '+39027654321', 'shoes@italian.it'),
('British Wool Co.', 'Savile Row 12, Londres', '+442079876543', 'wool@british.uk'),
('Swiss Watches Ltd', 'Bahnhofstrasse 30, Zúrich', '+41442223344', 'time@swiss.ch'),
('French Perfumes', 'Place Vendôme 18, París', '+33149876543', 'parfum@france.fr'),
('Japanese Denim Co', 'Omotesando 3-5-2, Tokio', '+81354126897', 'denim@japan.jp'),
('Egyptian Cotton Group', 'Nile Corniche 45, El Cairo', '+20225789456', 'cotton@egypt.eg');

INSERT INTO Producto (nombre, descripcion, precio, stock_disponible, categoria_id, proveedor_id, marca_id) VALUES
('Camisa Algodón Egipcio', 'Camisa 100% algodón egipcio premium', 450.00, 25, 1, 10, 1),
('Chaqueta Cuero Caballero', 'Chaqueta de cuero italiano teñido a mano', 2200.00, 12, 2, 2, 3),
('Pantalón Versace Oro', 'Pantalón de vestir con detalles en hilo de oro', 850.00, 18, 3, 1, 7),
('Bolso Birkin 30', 'Bolso Hermès en piel de cocodrilo', 25000.00, 3, 8, 3, 4),
('Zapato Oxford Balenciaga', 'Zapato formal en piel de becerro francés', 780.00, 15, 7, 5, 8),
('Abrigo Burberry Trench', 'Abrigo clásico en gabardina impermeable', 1850.00, 8, 6, 6, 5),
('Corbata Seda Jacquard', 'Corbata de seda con diseño exclusivo', 210.00, 40, 10, 4, 6),
('Vestido Noche Prada', 'Vestido largo de seda con cristales Swarovski', 3600.00, 5, 4, 1, 2),
('Reloj Cuarzo Suizo', 'Reloj de pulsera con correa de piel', 4200.00, 10, 9, 7, 4),
('Guantes Piel Cabritilla', 'Guantes de piel suave forrados en seda', 320.00, 20, 9, 2, 9);

INSERT INTO Cliente (nombre, direccion, telefono, email, fecha_registro) VALUES
('Ana de la Cruz', 'Av. Reforma 1450, CDMX', '+525512345678', 'anacruz@luxury.com', '2020-03-15'),
('Carlos Vargas', 'Calle Serrano 89, Madrid', '+34911765432', 'cvargas@vipmail.es', '2021-07-22'),
('Sophie Dubois', 'Rue du Faubourg 78, París', '+33142659874', 'sdubois@paris.fr', '2019-11-05'),
('Luca Rossi', 'Via Montenapoleone 5, Milán', '+390277889900', 'l.rossi@fashion.it', '2022-01-10'),
('Emma Watson', 'Kensington Park 12, Londres', '+442071234567', 'ewatson@private.uk', '2023-02-18'),
('Alejandro González', 'Carrera 7 # 125-30, Bogotá', '+5716001234', 'agonzalez@empresa.com.co', '2022-09-01'),
('Mika Tanaka', 'Roppongi Hills 6-10-1, Tokio', '+81337981234', 'mika.t@japan.jp', '2021-05-30'),
('Olivia Chen', 'Champs-Élysées 102, París', '+33145563214', 'olivia.chen@asia.fr', '2023-04-12'),
('Diego Maradona Jr.', 'Puerto Madero 1450, Buenos Aires', '+541112345678', 'diegojr@legacy.ar', '2020-12-25'),
('Sheik Al-Fayed', 'Palm Jumeirah Villa 5, Dubai', '+97143012345', 'sheik@dubai.ae', '2023-06-15');

INSERT INTO Vendedor (nombre, telefono, email) VALUES
('María Fernández', '+525556789012', 'mfernandez@tiendalux.com'),
('Giovanni Lombardi', '+390277654321', 'glombardi@tiendalux.it'),
('Élodie Rousseau', '+331498563214', 'erousseau@tiendalux.fr'),
('James Carter', '+442076543219', 'jcarter@tiendalux.uk'),
('Fatima Al-Maktoum', '+971430987654', 'falmaktoum@tiendalux.ae'),
('Sakura Yamamoto', '+81337219876', 'syamamoto@tiendalux.jp'),
('Luis Martínez', '+571321654987', 'lmartinez@tiendalux.co'),
('Klaus Schmidt', '+4930123456789', 'kschmidt@tiendalux.de'),
('Valentina Rossi', '+390276543210', 'vrossi@tiendalux.it'),
('Amélie Dupont', '+33142336789', 'adupont@tiendalux.fr');

INSERT INTO Factura_Maestro (numero_factura, cliente_id, fecha_factura, nit_cliente, total, estado_factura, metodo_pago) VALUES
('FAC-001-2023', 1, '2023-01-15', 'CF-123456789', 2650.00, 'pagada', 'tarjeta'),
('FAC-002-2023', 3, '2023-02-20', 'RF-987654321', 18500.00, 'pendiente', 'transferencia'),
('FAC-003-2023', 5, '2023-03-10', 'GB-112233445', 4200.00, 'pagada', 'efectivo'),
('FAC-004-2023', 2, '2023-04-05', 'ES-556677889', 8500.00, 'anulada', NULL),
('FAC-005-2023', 10, '2023-05-18', 'AE-998877665', 25320.00, 'pagada', 'tarjeta'),
('FAC-006-2023', 7, '2023-06-22', 'JP-443322110', 1560.00, 'pendiente', 'tarjeta'),
('FAC-007-2023', 4, '2023-07-30', 'IT-776655443', 3600.00, 'pagada', 'transferencia'),
('FAC-008-2023', 6, '2023-08-12', 'CO-334455667', 450.00, 'pagada', 'efectivo'),
('FAC-009-2023', 8, '2023-09-01', 'FR-223344556', 2200.00, 'pendiente', 'tarjeta'),
('FAC-010-2023', 9, '2023-10-15', 'AR-123123123', 780.00, 'pagada', 'efectivo');

INSERT INTO Factura_Detalle (factura_maestro_id, producto_id, cantidad, precio_unitario, total_producto) VALUES
(1, 3, 2, 850.00, 1700.00),
(1, 7, 1, 210.00, 210.00),
(1, 10, 2, 320.00, 640.00),
(2, 4, 1, 25000.00, 25000.00),
(3, 9, 1, 4200.00, 4200.00),
(5, 2, 1, 2200.00, 2200.00),
(5, 4, 1, 25000.00, 25000.00),
(6, 1, 3, 450.00, 1350.00),
(7, 8, 1, 3600.00, 3600.00),
(10, 5, 1, 780.00, 780.00);

INSERT INTO Sucursal (nombre_sucursal, direccion, telefono) VALUES
('Boutique Centro Histórico', 'Plaza Mayor 5, Madrid', '+34912345678'),
('Flagship París', 'Avenue Montaigne 51, París', '+33147236598'),
('Luxury Dubai Mall', 'Financial Center Rd, Dubai', '+97144321234'),
('Milán Fashion District', 'Via della Spiga 23, Milán', '+39027894561'),
('Tokyo Ginza Store', 'Chuo-ku 5-4-1, Tokio', '+81335671234'),
('NY Fifth Avenue', '5th Ave 767, Nueva York', '+12126549876'),
('Londres Mayfair', 'Bond Street 28, Londres', '+44207321456'),
('México Polanco', 'Av. Masaryk 456, CDMX', '+525555551212'),
('Shanghái Pudong', 'Century Avenue 8, Shanghái', '+862158963214'),
('Sydney CBD', 'George Street 189, Sídney', '+61292345678');

INSERT INTO Inventario (producto_id, cantidad, fecha_movimiento, tipo_movimiento, sucursal_id) VALUES
(1, 50, '2023-01-05', 'entrada', 1),
(2, 15, '2023-01-05', 'entrada', 2),
(3, 30, '2023-01-10', 'entrada', 3),
(4, 5, '2023-02-01', 'entrada', 1),
(5, 25, '2023-02-15', 'entrada', 2),
(1, -5, '2023-03-20', 'salida', 1),
(2, -3, '2023-04-02', 'salida', 2),
(6, 10, '2023-05-10', 'entrada', 3),
(7, 50, '2023-06-01', 'entrada', 1),
(8, 8, '2023-07-15', 'entrada', 2);

INSERT INTO Venta (sucursal_id, total_venta, fecha_venta, numero_facturas) VALUES
(1, 2650.00, '2023-01-15', 1),
(3, 18500.00, '2023-02-20', 1),
(2, 4200.00, '2023-03-10', 1),
(5, 8500.00, '2023-04-05', 1),
(4, 25320.00, '2023-05-18', 1),
(7, 1560.00, '2023-06-22', 1),
(6, 3600.00, '2023-07-30', 1),
(8, 450.00, '2023-08-12', 1),
(9, 2200.00, '2023-09-01', 1),
(10, 780.00, '2023-10-15', 1);

INSERT INTO Venta_Factura_Maestro (venta_id, factura_maestro_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

INSERT INTO Descuento (nombre_descuento, porcentaje, monto_fijo, fecha_inicio, fecha_fin) VALUES
('Black Friday', 15.00, NULL, '2023-11-24', '2023-11-26'),
('Cliente VIP', NULL, 500.00, '2023-01-01', '2023-12-31'),
('Lanzamiento Colección', 10.00, NULL, '2023-03-01', '2023-03-07'),
('Descuento Corporativo', 20.00, NULL, '2023-06-01', '2023-06-30'),
('Aniversario Tienda', NULL, 1000.00, '2023-09-15', '2023-09-20'),
('Temporada Baja', 25.00, NULL, '2023-07-01', '2023-08-31'),
('Compra Múltiple', NULL, 300.00, '2023-04-01', '2023-05-01'),
('Empleados', 40.00, NULL, '2023-01-01', '2023-12-31'),
('Primera Compra', 10.00, NULL, '2023-01-01', '2023-12-31'),
('Pago Efectivo', 5.00, NULL, '2023-05-01', '2023-12-31');

INSERT INTO Producto_Descuento (producto_id, descuento_id, cantidad_aplicada) VALUES
(3, 1, 2),
(7, 3, 5),
(5, 6, 3),
(1, 9, 10),
(2, 4, 1),
(8, 2, 2),
(4, 5, 1),
(6, 7, 4),
(9, 8, 2),
(10, 10, 8);