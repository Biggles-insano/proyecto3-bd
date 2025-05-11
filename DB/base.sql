CREATE TABLE Marca ( id_marca INT PRIMARY KEY AUTO_INCREMENT, nombre_marca VARCHAR(100) NOT NULL, pais_origen VARCHAR(100) ); 

CREATE TABLE Categoria_Producto ( id_categoria INT PRIMARY KEY AUTO_INCREMENT, nombre_categoria VARCHAR(100) NOT NULL ); 

CREATE TABLE Proveedor ( id_proveedor INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(50) NOT NULL, apellido VARCHAR(50) NOT NULL, direccion VARCHAR(200), telefono VARCHAR(15), email VARCHAR(100), UNIQUE (email) ); 

CREATE TABLE Producto ( id_producto INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(100) NOT NULL, descripcion TEXT, precio DECIMAL(10, 2) NOT NULL, CHECK (precio >= 0), stock_disponible INT NOT NULL, CHECK (stock_disponible >= 0), categoria_id INT, proveedor_id INT, marca_id INT, FOREIGN KEY (categoria_id) REFERENCES Categoria_Producto(id_categoria), FOREIGN KEY (proveedor_id) REFERENCES Proveedor(id_proveedor), FOREIGN KEY (marca_id) REFERENCES Marca(id_marca) ); 

CREATE TABLE Cliente ( id_cliente INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(50) NOT NULL, apellido VARCHAR(50) NOT NULL, direccion VARCHAR(200), telefono VARCHAR(15), email VARCHAR(100), UNIQUE (email), fecha_registro DATE NOT NULL ); 

CREATE TABLE Vendedor ( id_vendedor INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(50) NOT NULL, apellido VARCHAR(50) NOT NULL, telefono VARCHAR(15), email VARCHAR(100), UNIQUE (email) ); 

CREATE TABLE Factura_Maestro ( id_factura_maestro INT PRIMARY KEY AUTO_INCREMENT, numero_factura VARCHAR(50) NOT NULL, cliente_id INT, fecha_factura DATE NOT NULL, nit_cliente VARCHAR(20) NOT NULL, total DECIMAL(10, 2) NOT NULL, -- Monto total de la factura total_pagado DECIMAL(10, 2) DEFAULT 0.00, -- Monto pagado hasta el momento estado_factura VARCHAR(20) NOT NULL, -- Estado de la factura (pendiente, pagada, anulada) CHECK (estado_factura IN ('pendiente', 'pagada', 'anulada')), metodo_pago VARCHAR(50), -- Forma de pago (efectivo, tarjeta, etc.) FOREIGN KEY (cliente_id) REFERENCES Cliente(id_cliente) );  

CREATE TABLE Factura_Detalle ( id_factura_detalle INT PRIMARY KEY AUTO_INCREMENT, factura_maestro_id INT, producto_id INT, cantidad INT NOT NULL, precio_unitario DECIMAL(10, 2) NOT NULL, total_producto DECIMAL(10, 2) NOT NULL, -- Monto total de ese producto (cantidad * precio_unitario) FOREIGN KEY (factura_maestro_id) REFERENCES Factura_Maestro(id_factura_maestro), FOREIGN KEY (producto_id) REFERENCES Producto(id_producto) );  

CREATE TABLE Inventario ( id_inventario INT PRIMARY KEY AUTO_INCREMENT, producto_id INT, cantidad INT NOT NULL, fecha_movimiento DATE NOT NULL, tipo_movimiento VARCHAR(20) NOT NULL, -- 'entrada' o 'salida' FOREIGN KEY (producto_id) REFERENCES Producto(id_producto) ); 

CREATE TABLE Sucursal ( id_sucursal INT PRIMARY KEY AUTO_INCREMENT, nombre_sucursal VARCHAR(100) NOT NULL, direccion VARCHAR(200), telefono VARCHAR(15) ); 

CREATE TABLE Venta ( id_venta INT PRIMARY KEY AUTO_INCREMENT, sucursal_id INT, total_venta DECIMAL(10, 2) NOT NULL, fecha_venta DATE NOT NULL, numero_facturas INT NOT NULL, -- Número de facturas asociadas a esta venta FOREIGN KEY (sucursal_id) REFERENCES Sucursal(id_sucursal) ); 

CREATE TABLE Venta_Factura_Maestro ( id_venta_factura INT PRIMARY KEY AUTO_INCREMENT, venta_id INT, factura_maestro_id INT, FOREIGN KEY (venta_id) REFERENCES Venta(id_venta), FOREIGN KEY (factura_maestro_id) REFERENCES Factura_Maestro(id_factura_maestro) ); 

CREATE TABLE Descuento ( id_descuento INT PRIMARY KEY AUTO_INCREMENT, nombre_descuento VARCHAR(100) NOT NULL, porcentaje DECIMAL(5, 2), monto_fijo DECIMAL(10, 2), fecha_inicio DATE NOT NULL, fecha_fin DATE NOT NULL ); 

CREATE TABLE Producto_Descuento ( id_producto_descuento INT PRIMARY KEY AUTO_INCREMENT, producto_id INT, descuento_id INT, cantidad_aplicada DECIMAL(10, 2) NOT NULL, -- El descuento aplicado al producto FOREIGN KEY (producto_id) REFERENCES Producto(id_producto), FOREIGN KEY (descuento_id) REFERENCES Descuento(id_descuento) ); 

DELIMITER //

CREATE TRIGGER actualizar_stock_despues_venta
AFTER INSERT ON Factura_Detalle
FOR EACH ROW
BEGIN
  UPDATE Producto
  SET stock_disponible = stock_disponible - NEW.cantidad
  WHERE id_producto = NEW.producto_id;
END;

CREATE TRIGGER evitar_venta_sin_stock
BEFORE INSERT ON Factura_Detalle
FOR EACH ROW
BEGIN
  IF (SELECT stock_disponible FROM Producto WHERE id_producto = NEW.producto_id) < NEW.cantidad THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No hay suficiente stock para realizar la venta';
  END IF;
END;

CREATE TRIGGER registrar_movimiento_inventario
AFTER INSERT ON Producto
FOR EACH ROW
BEGIN
  INSERT INTO Inventario (producto_id, cantidad, fecha_movimiento, tipo_movimiento)
  VALUES (NEW.id_producto, NEW.stock_disponible, CURDATE(), 'entrada');
END;

DELIMITER ;


INSERT INTO Marca (nombre_marca, pais_origen) VALUES
('Levi''s', 'Estados Unidos'),
('Calvin Klein', 'Estados Unidos'),
('Tommy Hilfiger', 'Estados Unidos'),
('Polo Ralph Lauren.', 'Estados Unidos'),
('Nautica', 'Estados Unidos'),
('Columbia', 'Estados Unidos'),
('Guess', 'Estados Unidos'),
('Lacoste', 'Francia'),
('Balenciaga', 'Francia'),
('Louis Vuitton', 'Francia'),
('Gucci', 'Italia'),
('Ralph Lauren', 'Estados Unidos'),
('Giorgio Armani', 'Italia'),
('Christian Dior', 'Francia'),
('Chanel', 'Francia'),
('Burberry', 'Reino Unido'),
('Prada', 'Italia'),
('Hermès', 'Francia'),
('Moncler', 'Italia');



INSERT INTO Categoria_Producto (nombre_categoria) VALUES
('Camisas'),
('Pantalones'),
('Chaquetas'),
('Zapatos'),
('Accesorios'),
('Vestidos'),
('Sudaderas'),
('Shorts'),
('Faldas'),
('Trajes de baño'),
('Blusas'),
('Abrigos'),
('Ropa interior'),
('Calcetines'),
('Cinturones'),
('Gorras'),
('Bufandas'),
('Guantes'),
('Pijamas'),
('Overoles');


INSERT INTO Proveedor (nombre, direccion, telefono, email) VALUES
('Textiles América', '6a Avenida 10-45, Zona 1, Ciudad de Guatemala', '2291-1234', 'contacto@textilesamerica.gt'),
('Distribuidora Fashion', 'Avenida Reforma 12-01, Zona 9', '2233-9876', 'ventas@fashion.com'),
('Moda Total', 'Boulevard Liberación 5-55, Zona 13', '2478-3344', 'info@modatotal.gt'),
('Confecciones Primavera', 'Calzada Roosevelt 21-70, Zona 7', '2384-6677', 'contacto@primavera.com'),
('Importadora Elite', 'Diagonal 6 14-70, Zona 10', '2455-8800', 'elite@importaciones.com'),
('Distribuciones Rivera', 'Zona 4 de Mixco, Guatemala', '2466-1100', 'rivera@distribuciones.com'),
('Ropa Centroamericana', 'Calle Martí 8-20, Zona 2', '2231-5644', 'centro@ropa.com'),
('TexIndustrias GT', 'Zona 12, Parque Industrial Las Naciones', '2333-4433', 'soporte@texgt.com'),
('Fashion Line', 'Zona 15, Vista Hermosa II', '2444-7711', 'ventas@fashionline.com'),
('Estilo Urbano', 'Boulevard Vista Real, Zona 16', '2312-8899', 'urbano@estilo.com'),
('Distribuidora Ávila', 'Chimaltenango, carretera Interamericana', '2224-1233', 'avila@distribuciones.gt'),
('Premium Textiles', 'Zona 5, Calle Real 3-45', '2377-9012', 'premium@textiles.com'),
('Boutique Express', 'C.C. Miraflores, local 204', '2499-1010', 'express@boutique.com'),
('Moda Nova', 'Zona 11, Colonia Las Charcas', '2298-3312', 'ventas@modanova.com'),
('Ropa Moderna', 'Santa Catarina Pinula, entrada principal', '2267-7744', 'moderna@ropa.com');


CREATE TABLE Marca ( id_marca INT PRIMARY KEY AUTO_INCREMENT, nombre_marca VARCHAR(100) NOT NULL, pais_origen VARCHAR(100) ); 

CREATE TABLE Categoria_Producto ( id_categoria INT PRIMARY KEY AUTO_INCREMENT, nombre_categoria VARCHAR(100) NOT NULL ); 

CREATE TABLE Proveedor ( id_proveedor INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(100) NOT NULL, direccion VARCHAR(200), telefono VARCHAR(15), email VARCHAR(100), UNIQUE (email) ); 

CREATE TABLE Producto ( id_producto INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(100) NOT NULL, descripcion TEXT, precio DECIMAL(10, 2) NOT NULL, CHECK (precio >= 0), stock_disponible INT NOT NULL, CHECK (stock_disponible >= 0), categoria_id INT, proveedor_id INT, marca_id INT, FOREIGN KEY (categoria_id) REFERENCES Categoria_Producto(id_categoria), FOREIGN KEY (proveedor_id) REFERENCES Proveedor(id_proveedor), FOREIGN KEY (marca_id) REFERENCES Marca(id_marca) ); 

CREATE TABLE Cliente ( id_cliente INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(100) NOT NULL, direccion VARCHAR(200), telefono VARCHAR(15), email VARCHAR(100), UNIQUE (email), fecha_registro DATE NOT NULL ); 

CREATE TABLE Vendedor ( id_vendedor INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(100) NOT NULL, telefono VARCHAR(15), email VARCHAR(100), UNIQUE (email) ); 

CREATE TABLE Factura_Maestro ( id_factura_maestro INT PRIMARY KEY AUTO_INCREMENT, numero_factura VARCHAR(50) NOT NULL, cliente_id INT, fecha_factura DATE NOT NULL, nit_cliente VARCHAR(20) NOT NULL, total DECIMAL(10, 2) NOT NULL, -- Monto total de la factura total_pagado DECIMAL(10, 2) DEFAULT 0.00, -- Monto pagado hasta el momento estado_factura VARCHAR(20) NOT NULL, -- Estado de la factura (pendiente, pagada, anulada) CHECK (estado_factura IN ('pendiente', 'pagada', 'anulada')), metodo_pago VARCHAR(50), -- Forma de pago (efectivo, tarjeta, etc.) FOREIGN KEY (cliente_id) REFERENCES Cliente(id_cliente) );  

CREATE TABLE Factura_Detalle ( id_factura_detalle INT PRIMARY KEY AUTO_INCREMENT, factura_maestro_id INT, producto_id INT, cantidad INT NOT NULL, precio_unitario DECIMAL(10, 2) NOT NULL, total_producto DECIMAL(10, 2) NOT NULL, -- Monto total de ese producto (cantidad * precio_unitario) FOREIGN KEY (factura_maestro_id) REFERENCES Factura_Maestro(id_factura_maestro), FOREIGN KEY (producto_id) REFERENCES Producto(id_producto) );  

CREATE TABLE Inventario ( id_inventario INT PRIMARY KEY AUTO_INCREMENT, producto_id INT, cantidad INT NOT NULL, fecha_movimiento DATE NOT NULL, tipo_movimiento VARCHAR(20) NOT NULL, -- 'entrada' o 'salida' FOREIGN KEY (producto_id) REFERENCES Producto(id_producto) ); 

CREATE TABLE Sucursal ( id_sucursal INT PRIMARY KEY AUTO_INCREMENT, nombre_sucursal VARCHAR(100) NOT NULL, direccion VARCHAR(200), telefono VARCHAR(15) ); 

CREATE TABLE Venta ( id_venta INT PRIMARY KEY AUTO_INCREMENT, sucursal_id INT, total_venta DECIMAL(10, 2) NOT NULL, fecha_venta DATE NOT NULL, numero_facturas INT NOT NULL, -- Número de facturas asociadas a esta venta FOREIGN KEY (sucursal_id) REFERENCES Sucursal(id_sucursal) ); 

CREATE TABLE Venta_Factura_Maestro ( id_venta_factura INT PRIMARY KEY AUTO_INCREMENT, venta_id INT, factura_maestro_id INT, FOREIGN KEY (venta_id) REFERENCES Venta(id_venta), FOREIGN KEY (factura_maestro_id) REFERENCES Factura_Maestro(id_factura_maestro) ); 

CREATE TABLE Descuento ( id_descuento INT PRIMARY KEY AUTO_INCREMENT, nombre_descuento VARCHAR(100) NOT NULL, porcentaje DECIMAL(5, 2), monto_fijo DECIMAL(10, 2), fecha_inicio DATE NOT NULL, fecha_fin DATE NOT NULL ); 

CREATE TABLE Producto_Descuento ( id_producto_descuento INT PRIMARY KEY AUTO_INCREMENT, producto_id INT, descuento_id INT, cantidad_aplicada DECIMAL(10, 2) NOT NULL, -- El descuento aplicado al producto FOREIGN KEY (producto_id) REFERENCES Producto(id_producto), FOREIGN KEY (descuento_id) REFERENCES Descuento(id_descuento) ); 

DELIMITER //

CREATE TRIGGER actualizar_stock_despues_venta
AFTER INSERT ON Factura_Detalle
FOR EACH ROW
BEGIN
  UPDATE Producto
  SET stock_disponible = stock_disponible - NEW.cantidad
  WHERE id_producto = NEW.producto_id;
END;

CREATE TRIGGER evitar_venta_sin_stock
BEFORE INSERT ON Factura_Detalle
FOR EACH ROW
BEGIN
  IF (SELECT stock_disponible FROM Producto WHERE id_producto = NEW.producto_id) < NEW.cantidad THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No hay suficiente stock para realizar la venta';
  END IF;
END;

CREATE TRIGGER registrar_movimiento_inventario
AFTER INSERT ON Producto
FOR EACH ROW
BEGIN
  INSERT INTO Inventario (producto_id, cantidad, fecha_movimiento, tipo_movimiento)
  VALUES (NEW.id_producto, NEW.stock_disponible, CURDATE(), 'entrada');
END;

DELIMITER ;


INSERT INTO Marca (nombre_marca, pais_origen) VALUES
('Levi''s', 'Estados Unidos'),
('Calvin Klein', 'Estados Unidos'),
('Tommy Hilfiger', 'Estados Unidos'),
('Polo Ralph Lauren.', 'Estados Unidos'),
('Nautica', 'Estados Unidos'),
('Columbia', 'Estados Unidos'),
('Guess', 'Estados Unidos'),
('Lacoste', 'Francia'),
('Balenciaga', 'Francia'),
('Louis Vuitton', 'Francia'),
('Gucci', 'Italia'),
('Ralph Lauren', 'Estados Unidos'),
('Giorgio Armani', 'Italia'),
('Christian Dior', 'Francia'),
('Chanel', 'Francia'),
('Burberry', 'Reino Unido'),
('Prada', 'Italia'),
('Hermès', 'Francia'),
('Moncler', 'Italia');


INSERT INTO Categoria_Producto (nombre_categoria) VALUES
('Camisas'),
('Pantalones'),
('Chaquetas'),
('Zapatos'),
('Accesorios'),
('Vestidos'),
('Sudaderas'),
('Shorts'),
('Faldas'),
('Trajes de baño'),
('Blusas'),
('Abrigos'),
('Ropa interior'),
('Calcetines'),
('Cinturones'),
('Gorras'),
('Bufandas'),
('Guantes'),
('Pijamas'),
('Overoles');


INSERT INTO Cliente (nombre, apellido, direccion, telefono, email, fecha_registro) VALUES
('Andrea', 'López', 'Residenciales La Montaña, Zona 16', '4567-1234', 'andrea.lopez1@gmail.com', '2022-03-15'),
('Carlos', 'Pérez', 'Cayalá, Zona 16', '5589-3345', 'carlos.perez2@gmail.com', '2022-06-22'),
('María', 'González', 'Condado Naranjo, Zona 4 de Mixco', '6678-9922', 'maria.gonzalez3@gmail.com', '2022-09-05'),
('Luis', 'Weber', 'Colonia Oakland, Zona 10', '7789-1155', 'luis.weber4@gmail.com', '2022-11-12'),
('Ana', 'Morales', 'Residenciales Vistas de San Isidro, Zona 16', '8890-2233', 'ana.morales5@gmail.com', '2022-12-02'),
('Jorge', 'Castillo', 'Residenciales Villa Sol, Carretera a El Salvador', '9912-3366', 'jorge.castillo6@gmail.com', '2023-01-18'),
('Karla', 'Chang', 'Colonia La Cañada, Zona 14', '1012-4477', 'karla.chang7@gmail.com', '2023-02-05'),
('Sergio', 'Rabanales', 'Colonia El Prado, Carretera a Fraijanes', '1123-5588', 'sergio.rabanales8@gmail.com', '2023-03-20'),
('Tatiana', 'Kim', 'Edificio Attica, Zona 14', '1234-5678', 'tatiana.kim9@gmail.com', '2023-04-11'),
('Ricardo', 'Hernández', 'Residenciales Santa Catarina, Zona 15', '2345-6789', 'ricardo.hernandez10@gmail.com', '2023-05-07'),
('Isabel', 'Nguyen', 'Colonia Montebello, Zona 8 de Mixco', '3456-7890', 'isabel.nguyen11@gmail.com', '2023-06-12'),
('Fernando', 'Mizrahi', 'Colonia Vista Hermosa I, Zona 15', '4567-8901', 'fernando.mizrahi12@gmail.com', '2023-07-19'),
('Gabriela', 'Dubois', 'Colonia Elgin, Zona 13', '5678-9012', 'gabriela.dubois13@gmail.com', '2023-08-23'),
('Manuel', 'Awad', 'Residenciales Santa Rosalia, Carretera a El Salvador', '6789-0123', 'manuel.awad14@gmail.com', '2023-09-14'),
('Lucía', 'Rosales', 'Colonia Ciudad Vieja, Zona 10', '7890-1234', 'lucia.rosales15@gmail.com', '2023-10-10'),
('Diego', 'Mendoza', 'Colonia Las Charcas, Zona 11', '8901-2345', 'diego.mendoza16@gmail.com', '2023-11-30'),
('Patricia', 'Klein', 'Colonia Lourdes, Zona 16', '9012-3456', 'patricia.klein17@gmail.com', '2023-12-15'),
('Miguel', 'Yamada', 'Colonia La Cañada, Zona 14', '1235-4680', 'miguel.yamada18@gmail.com', '2024-01-03'),
('Sofía', 'Martínez', 'Residenciales Vistas de San Isidro, Zona 16', '2346-5791', 'sofia.martinez19@gmail.com', '2024-01-16'),
('Juan', 'Smith', 'Cayalá, Zona 16', '3457-6802', 'juan.smith20@gmail.com', '2022-02-09'),
('Alexandra', 'Moreno', 'Colonia Oakland, Zona 10', '4568-7913', 'alexandra.moreno21@gmail.com', '2022-03-27'),
('Enrique', 'Bakr', 'Colonia El Prado, Carretera a Fraijanes', '5679-8024', 'enrique.bakr22@gmail.com', '2022-04-13'),
('Valeria', 'Müller', 'Residenciales La Montaña, Zona 16', '6780-9135', 'valeria.muller23@gmail.com', '2022-05-22'),
('Esteban', 'Coc', 'Santa Catarina Pinula, Residenciales', '7891-0246', 'esteban.qureshi24@gmail.com', '2022-06-30'),
('Camila', 'Santos', 'Colonia Montebello, Zona 8 de Mixco', '8902-1357', 'camila.santos25@gmail.com', '2022-07-14'),
('Roberto', 'Alvarez', 'Colonia Lourdes, Zona 16', '9013-2468', 'roberto.alvarez26@gmail.com', '2022-08-21'),
('Natalia', 'Li', 'Colonia Vista Hermosa II, Zona 15', '1124-3579', 'natalia.li27@gmail.com', '2022-09-18'),
('Francisco', 'Benavides', 'Colonia Elgin, Zona 13', '2235-4680', 'francisco.benavides28@gmail.com', '2022-10-29'),
('Mariana', 'Hassan', 'Colonia La Cañada, Zona 14', '3346-5791', 'mariana.hassan29@gmail.com', '2022-11-05'),
('Samuel', 'Dubois', 'Cayalá, Zona 16', '4457-6802', 'samuel.dubois30@gmail.com', '2022-12-12'),
('Elena', 'Wong', 'Condado Naranjo, Zona 4 de Mixco', '5568-7913', 'elena.wong31@gmail.com', '2023-01-20'),
('Pablo', 'Morales', 'Residenciales Villa Sol, Carretera a El Salvador', '6679-8024', 'pablo.morales32@gmail.com', '2023-02-11'),
('Diana', 'Ramírez', 'Colonia Oakland, Zona 10', '7780-9135', 'diana.ramirez33@gmail.com', '2023-03-17'),
('Nicolás', 'Khan', 'Residenciales Santa Rosalia, Carretera a El Salvador', '8891-0246', 'nicolas.khan34@gmail.com', '2023-04-08'),
('Marta', 'García', 'Colonia Vista Hermosa III, Zona 15', '9902-1357', 'marta.garcia35@gmail.com', '2023-05-23'),
('Julio', 'Hernández', 'Colonia El Prado, Carretera a Fraijanes', '1013-2468', 'julio.hernandez36@gmail.com', '2023-06-29'),
('Paola', 'Kim', 'Colonia La Cañada, Zona 14', '2124-3579', 'paola.kim37@gmail.com', '2023-07-12'),
('Felipe', 'Sato', 'Colonia Montebello, Zona 8 de Mixco', '3235-4680', 'felipe.sato38@gmail.com', '2023-08-21'),
('Silvia', 'Ramos', 'Residenciales La Montaña, Zona 16', '4346-5791', 'silvia.ramos39@gmail.com', '2023-09-15'),
('Oscar', 'Gómez', 'Colonia Lourdes, Zona 16', '5457-6802', 'oscar.gomez40@gmail.com', '2023-10-27'),
('Lorena', 'Rahman', 'Colonia Oakland, Zona 10', '6568-7913', 'lorena.rahman41@gmail.com', '2023-11-19'),
('David', 'Cohen', 'Colonia Elgin, Zona 13', '7679-8024', 'david.cohen42@gmail.com', '2023-12-04'),
('Carolina', 'Sharma', 'Santa Catarina Pinula, Residenciales', '8780-9135', 'carolina.sharma43@gmail.com', '2024-01-18'),
('Raúl', 'Maldonado', 'Residenciales Vistas de San Isidro, Zona 16', '9891-0246', 'raul.maldonado44@gmail.com', '2024-02-09'),
('Luciana', 'Kowalski', 'Cayalá, Zona 16', '1902-1357', 'luciana.kowalski45@gmail.com', '2024-02-23'),
('Pedro', 'Díaz', 'Colonia Vista Hermosa I, Zona 15', '2013-2468', 'pedro.diaz46@gmail.com', '2022-03-03'),
('Samantha', 'Salazar', 'Colonia Montebello, Zona 8 de Mixco', '3124-3579', 'samantha.salazar47@gmail.com', '2022-05-08'),
('Matías', 'Fischer', 'Colonia La Cañada, Zona 14', '4235-4680', 'matias.fischer48@gmail.com', '2022-06-27'),
('Alejandra', 'Kassis', 'Residenciales Santa Rosalia, Carretera a El Salvador', '5346-5791', 'alejandra.kassis49@gmail.com', '2022-08-18'),
('Cristiano', 'Ronaldo', 'Colonia Oakland, Zona 10', '6457-6802', 'cristiano50@gmail.com', '2022-09-30'),
('Patricio', 'Moreno', 'Colonia El Prado, Carretera a Fraijanes', '7568-7913', 'patricio.moreno51@gmail.com', '2022-10-20'),
('Mónica', 'Zhao', 'Residenciales Villa Sol, Carretera a El Salvador', '8679-8024', 'monica.zhao52@gmail.com', '2022-11-15'),
('René', 'García', 'Colonia Lourdes, Zona 16', '9780-9135', 'rene.garcia53@gmail.com', '2022-12-05'),
('Daniela', 'Benedetti', 'Colonia Vista Hermosa II, Zona 15', '1891-0246', 'daniela.benedetti54@gmail.com', '2023-01-09'),
('Sebastián', 'Lee', 'Cayalá, Zona 16', '2902-1357', 'sebastian.lee55@gmail.com', '2023-02-16'),
('Luisa', 'Alemán', 'Colonia Montebello, Zona 8 de Mixco', '3013-2468', 'luisa.aleman56@gmail.com', '2023-03-22'),
('Mauricio', 'Farah', 'Colonia La Cañada, Zona 14', '4124-3579', 'mauricio.farah57@gmail.com', '2023-04-27'),
('Valentina', 'Moraga', 'Residenciales La Montaña, Zona 16', '5235-4680', 'valentina.moraga58@gmail.com', '2023-05-15'),
('Rodrigo', 'Huang', 'Colonia Lourdes, Zona 16', '6346-5791', 'rodrigo.huang59@gmail.com', '2023-06-19'),
('Inés', 'Rahim', 'Colonia Oakland, Zona 10', '7457-6802', 'ines.rahim60@gmail.com', '2023-07-03'),
('Estela', 'Gutiérrez', 'Colonia Elgin, Zona 13', '8568-7913', 'estela.gutierrez61@gmail.com', '2023-08-11'),
('Lionel', 'Messi', 'Residenciales Santa Rosalia, Carretera a El Salvador', '9679-8024', 'liomessi62@gmail.com', '2023-09-27'),
('Teresa', 'Montenegro', 'Residenciales Vistas de San Isidro, Zona 16', '1780-9135', 'teresa.montenegro63@gmail.com', '2023-10-13'),
('Santiago', 'Miyamoto', 'Colonia Vista Hermosa I, Zona 15', '2891-0246', 'santiago.miyamoto64@gmail.com', '2023-11-06'),
('Paula', 'Durán', 'Colonia Montebello, Zona 8 de Mixco', '3902-1357', 'paula.duran65@gmail.com', '2023-12-21'),
('Javier', 'Sabbagh', 'Colonia La Cañada, Zona 14', '4013-2468', 'javier.sabbagh66@gmail.com', '2024-01-27'),
('Melissa', 'Villagrán', 'Cayalá, Zona 16', '5124-3579', 'melissa.villagran67@gmail.com', '2024-02-18'),
('Estefanía', 'Schmidt', 'Colonia Oakland, Zona 10', '6235-4680', 'estefania.schmidt68@gmail.com', '2022-04-14'),
('Tomás', 'Khatib', 'Residenciales La Montaña, Zona 16', '7346-5791', 'tomas.khatib69@gmail.com', '2022-06-07'),
('Agustina', 'Younes', 'Colonia El Prado, Carretera a Fraijanes', '8457-6802', 'agustina.younes70@gmail.com', '2022-07-19'),
('Renata', 'Salem', 'Colonia Vista Hermosa III, Zona 15', '9568-7913', 'renata.salem71@gmail.com', '2022-09-02'),
('Ferrucio', 'Lamborghini', 'Colonia Lourdes, Zona 16', '1679-8024', 'lamborghini@gmail.com', '2022-10-25'),
('Cecilia', 'Borges', 'Colonia Oakland, Zona 10', '2780-9135', 'cecilia.borges73@gmail.com', '2022-11-13'),
('Enzo', 'Ferrari', 'Colonia Elgin, Zona 13', '3891-0246', 'ferrari@gmail.com', '2022-12-29'),
('Marisol', 'Salim', 'Residenciales Santa Rosalia, Carretera a El Salvador', '4902-1357', 'marisol.salim75@gmail.com', '2023-01-06'),
('Iván', 'Kassis', 'Colonia Vista Hermosa II, Zona 15', '5013-2468', 'ivan.kassis76@gmail.com', '2023-02-28'),
('Rosa', 'Klein', 'Colonia Montebello, Zona 8 de Mixco', '6124-3579', 'rosa.klein77@gmail.com', '2023-03-19'),
('Hugo', 'Rashid', 'Colonia La Cañada, Zona 14', '7235-4680', 'hugo.rashid78@gmail.com', '2023-04-13'),
('Alicia', 'Méndez', 'Colonia Lourdes, Zona 16', '8346-5791', 'alicia.mendez79@gmail.com', '2023-05-24'),
('Emilio', 'Steiner', 'Colonia Oakland, Zona 10', '9457-6802', 'emilio.steiner80@gmail.com', '2023-06-07'),
('Carmen', 'Kaur', 'Colonia El Prado, Carretera a Fraijanes', '1568-7913', 'carmen.kaur81@gmail.com', '2023-07-15'),
('Erick', 'Salazar', 'Residenciales Villa Sol, Carretera a El Salvador', '2679-8024', 'erick.salazar82@gmail.com', '2023-08-27'),
('Patricia', 'Mizrahi', 'Colonia Vista Hermosa I, Zona 15', '3780-9135', 'patricia.mizrahi83@gmail.com', '2023-09-30'),
('Leonardo', 'Fajardo', 'Colonia Montebello, Zona 8 de Mixco', '4891-0246', 'leonardo.fajardo84@gmail.com', '2023-10-21'),
('Natalie', 'Ng', 'Colonia La Cañada, Zona 14', '5902-1357', 'natalie.ng85@gmail.com', '2023-11-28'),
('Mauricio', 'Hassan', 'Residenciales Santa Rosalia, Carretera a El Salvador', '6013-2468', 'mauricio.hassan86@gmail.com', '2023-12-18'),
('Mónica', 'Salim', 'Colonia Lourdes, Zona 16', '7124-3579', 'monica.salim87@gmail.com', '2024-01-10'),
('Joaquín', 'Benedetti', 'Colonia Oakland, Zona 10', '8235-4680', 'joaquin.benedetti88@gmail.com', '2024-02-14'),
('Sonia', 'Zhou', 'Colonia Elgin, Zona 13', '9346-5791', 'sonia.zhou89@gmail.com', '2022-03-18'),
('Héctor', 'Kassis', 'Colonia Vista Hermosa II, Zona 15', '1457-6802', 'hector.kassis90@gmail.com', '2022-04-21'),
('Miriam', 'Klein', 'Colonia Montebello, Zona 8 de Mixco', '2568-7913', 'miriam.klein91@gmail.com', '2022-06-11'),
('Kylian', 'Mbappé', 'Colonia La Cañada, Zona 14', '3679-8024', 'kmbappe@gmail.com', '2022-07-25'),
('Silvia', 'Kim', 'Residenciales La Montaña, Zona 16', '4780-9135', 'silvia.kim93@gmail.com', '2022-09-16'),
('Federico', 'Valverde', 'Colonia Lourdes, Zona 16', '5891-0246', 'federico.kowalski94@gmail.com', '2022-10-12'),
('Daniel', 'Qureshi', 'Colonia Oakland, Zona 10', '6902-1357', 'daniel.qureshi95@gmail.com', '2022-11-09'),
('Marina', 'Sabbagh', 'Colonia El Prado, Carretera a Fraijanes', '7013-2468', 'marina.sabbagh96@gmail.com', '2022-12-21'),
('Jude', 'Bellingham', 'Residenciales Santa Rosalia, Carretera a El Salvador', '8124-3579', 'judevblghm@gmail.com', '2023-01-31'),
('Lorena', 'Zhao', 'Colonia Vista Hermosa III, Zona 15', '9235-4680', 'lorena.zhao98@gmail.com', '2023-02-25'),
('Jorge', 'Li', 'Colonia Lourdes, Zona 16', '1346-5791', 'jorge.li99@gmail.com', '2023-04-09'),
('Valeria', 'Huang', 'Colonia Oakland, Zona 10', '2457-6802', 'valeria.huang100@gmail.com', '2023-05-17');


INSERT INTO Vendedor (nombre, apellido, telefono, email) VALUES
('María', 'Ajquejay', '5010-1000', 'maria.ajquejay@ventas.ropa.gt'),
('Carlos', 'Tuyuc', '5010-1001', 'carlos.tuyuc@ventas.ropa.gt'),
('Ana', 'Chocooj', '5010-1002', 'ana.chocooj@ventas.ropa.gt'),
('Luis', 'Yax', '5010-1003', 'luis.yax@ventas.ropa.gt'),
('Patricia', 'Cac', '5010-1004', 'patricia.cac@ventas.ropa.gt'),
('José', 'Pop', '5010-1005', 'jose.pop@ventas.ropa.gt'),
('Lucía', 'Raxón', '5010-1006', 'lucia.raxon@ventas.ropa.gt'),
('Sergio', 'Quiej', '5010-1007', 'sergio.quiej@ventas.ropa.gt'),
('Andrea', 'Iboy', '5010-1008', 'andrea.iboy@ventas.ropa.gt'),
('Miguel', 'Xocop', '5010-1009', 'miguel.xocop@ventas.ropa.gt'),
('Rosa', 'Toj', '5010-1010', 'rosa.toj@ventas.ropa.gt'),
('David', 'Peláez', '5010-1011', 'david.pelaez@ventas.ropa.gt'),
('Karen', 'Sicán', '5010-1012', 'karen.sican@ventas.ropa.gt'),
('Henry', 'Barrios', '5010-1013', 'henry.barrios@ventas.ropa.gt'),
('Claudia', 'Ché', '5010-1014', 'claudia.che@ventas.ropa.gt'),
('Oscar', 'Ramírez', '5010-1015', 'oscar.ramirez@ventas.ropa.gt'),
('Paola', 'González', '5010-1016', 'paola.gonzalez@ventas.ropa.gt'),
('Jorge', 'Méndez', '5010-1017', 'jorge.mendez@ventas.ropa.gt'),
('Gabriela', 'García', '5010-1018', 'gabriela.garcia@ventas.ropa.gt'),
('Raúl', 'López', '5010-1019', 'raul.lopez@ventas.ropa.gt'),
('Sofía', 'Morales', '5010-1020', 'sofia.morales@ventas.ropa.gt'),
('Fernando', 'Herrera', '5010-1021', 'fernando.herrera@ventas.ropa.gt'),
('Valeria', 'Rivas', '5010-1022', 'valeria.rivas@ventas.ropa.gt'),
('Nicolás', 'Estrada', '5010-1023', 'nicolas.estrada@ventas.ropa.gt'),
('Camila', 'Chávez', '5010-1024', 'camila.chavez@ventas.ropa.gt'),
('Brenda', 'Ixchop', '5010-1025', 'brenda.ixchop@ventas.ropa.gt'),
('Marvin', 'Sic', '5010-1026', 'marvin.sic@ventas.ropa.gt'),
('Elsa', 'Tzunun', '5010-1027', 'elsa.tzunun@ventas.ropa.gt'),
('Ricardo', 'Chaj', '5010-1028', 'ricardo.chaj@ventas.ropa.gt'),
('Sandra', 'Calel', '5010-1029', 'sandra.calel@ventas.ropa.gt'),
('Edgar', 'Sicajau', '5010-1030', 'edgar.sicajau@ventas.ropa.gt'),
('Flor', 'Tzep', '5010-1031', 'flor.tzep@ventas.ropa.gt'),
('Samuel', 'Yat', '5010-1032', 'samuel.yat@ventas.ropa.gt'),
('Marta', 'Cux', '5010-1033', 'marta.cux@ventas.ropa.gt'),
('Julio', 'Batz', '5010-1034', 'julio.batz@ventas.ropa.gt'),
('Julia', 'Chajón', '5010-1035', 'julia.chajon@ventas.ropa.gt'),
('Esteban', 'Caal', '5010-1036', 'esteban.caal@ventas.ropa.gt'),
('Beatriz', 'Cojolón', '5010-1037', 'beatriz.cojolon@ventas.ropa.gt'),
('Rony', 'Tzep', '5010-1038', 'rony.tzep@ventas.ropa.gt'),
('Elsa', 'Chaj', '5010-1039', 'elsa.chaj@ventas.ropa.gt'),
('Carlos', 'Tzunun', '5010-1040', 'carlos.tzunun@ventas.ropa.gt'),
('Mercedes', 'Ajtzalam', '5010-1041', 'mercedes.ajtzalam@ventas.ropa.gt'),
('Rafael', 'Chub', '5010-1042', 'rafael.chub@ventas.ropa.gt'),
('Dina', 'Choc', '5010-1043', 'dina.choc@ventas.ropa.gt'),
('César', 'Pérez', '5010-1044', 'cesar.perez@ventas.ropa.gt'),
('Verónica', 'Chumil', '5010-1045', 'veronica.chumil@ventas.ropa.gt'),
('Emilio', 'Ramos', '5010-1046', 'emilio.ramos@ventas.ropa.gt'),
('Gloria', 'Chaj', '5010-1047', 'gloria.chaj@ventas.ropa.gt'),
('Héctor', 'Sicán', '5010-1048', 'hector.sican@ventas.ropa.gt'),
('Irma', 'Chub', '5010-1049', 'irma.chub@ventas.ropa.gt'),
('Juan', 'Ajanel', '5010-1050', 'juan.ajanel@ventas.ropa.gt'),
('Paula', 'Tzoc', '5010-1051', 'paula.tzoc@ventas.ropa.gt'),
('Walter', 'Yat', '5010-1052', 'walter.yat@ventas.ropa.gt'),
('Rosa', 'Calí', '5010-1053', 'rosa.cali@ventas.ropa.gt'),
('Ramiro', 'Chacón', '5010-1054', 'ramiro.chacon@ventas.ropa.gt'),
('Jessica', 'Caal', '5010-1055', 'jessica.caal@ventas.ropa.gt'),
('Diego', 'Chub', '5010-1056', 'diego.chub@ventas.ropa.gt'),
('Silvia', 'Ixcol', '5010-1057', 'silvia.ixcol@ventas.ropa.gt'),
('Marcos', 'Chub', '5010-1058', 'marcos.chub@ventas.ropa.gt'),
('Clara', 'Ajcalón', '5010-1059', 'clara.ajcalon@ventas.ropa.gt'),
('Noé', 'Caal', '5010-1060', 'noe.caal@ventas.ropa.gt'),
('Rosa', 'Tzunún', '5010-1061', 'rosa.tzunun@ventas.ropa.gt'),
('Pedro', 'Ixchop', '5010-1062', 'pedro.ixchop@ventas.ropa.gt'),
('Elena', 'Chaj', '5010-1063', 'elena.chaj@ventas.ropa.gt'),
('Antonio', 'Chumil', '5010-1064', 'antonio.chumil@ventas.ropa.gt'),
('María', 'Choc', '5010-1065', 'maria.choc@ventas.ropa.gt'),
('Damaris', 'Ajanel', '5010-1066', 'damaris.ajanel@ventas.ropa.gt'),
('César', 'Tzoc', '5010-1067', 'cesar.tzoc@ventas.ropa.gt'),
('Estela', 'Calel', '5010-1068', 'estela.calel@ventas.ropa.gt'),
('Wilmer', 'Pop', '5010-1069', 'wilmer.pop@ventas.ropa.gt'),
('Aura', 'Tzunún', '5010-1070', 'aura.tzunun@ventas.ropa.gt'),
('Roberto', 'Yax', '5010-1071', 'roberto.yax@ventas.ropa.gt'),
('María', 'Chajón', '5010-1072', 'maria.chajon@ventas.ropa.gt'),
('Sonia', 'Chocooj', '5010-1073', 'sonia.chocooj@ventas.ropa.gt'),
('Andrés', 'Barrios', '5010-1074', 'andres.barrios@ventas.ropa.gt'),
('Evelyn', 'Peláez', '5010-1075', 'evelyn.pelaez@ventas.ropa.gt'),
('Manuel', 'Cojolón', '5010-1076', 'manuel.cojolon@ventas.ropa.gt'),
('Irvin', 'Quiej', '5010-1077', 'irvin.quiej@ventas.ropa.gt'),
('Leticia', 'Iboy', '5010-1078', 'leticia.iboy@ventas.ropa.gt'),
('Cristina', 'Xocop', '5010-1079', 'cristina.xocop@ventas.ropa.gt'),
('Oscar', 'Toj', '5010-1080', 'oscar.toj@ventas.ropa.gt'),
('Glenda', 'Ché', '5010-1081', 'glenda.che@ventas.ropa.gt'),
('Byron', 'Barrios', '5010-1082', 'byron.barrios@ventas.ropa.gt'),
('Ingrid', 'Méndez', '5010-1083', 'ingrid.mendez@ventas.ropa.gt'),
('Edwin', 'García', '5010-1084', 'edwin.garcia@ventas.ropa.gt'),
('Melvin', 'López', '5010-1085', 'melvin.lopez@ventas.ropa.gt'),
('Diana', 'Morales', '5010-1086', 'diana.morales@ventas.ropa.gt'),
('Leonel', 'Herrera', '5010-1087', 'leonel.herrera@ventas.ropa.gt'),
('Yolanda', 'Rivas', '5010-1088', 'yolanda.rivas@ventas.ropa.gt'),
('Walter', 'Estrada', '5010-1089', 'walter.estrada@ventas.ropa.gt'),
('María', 'Chávez', '5010-1090', 'maria.chavez@ventas.ropa.gt'),
('Elsa', 'Pérez', '5010-1091', 'elsa.perez@ventas.ropa.gt'),
('Kevin', 'Sánchez', '5010-1092', 'kevin.sanchez@ventas.ropa.gt'),
('Mónica', 'Ajquin', '5010-1093', 'monica.ajquin@ventas.ropa.gt'),
('Fredy', 'Ajanel', '5010-1094', 'fredy.ajanel@ventas.ropa.gt'),
('Reina', 'Choc', '5010-1095', 'reina.choc@ventas.ropa.gt'),
('Joaquín', 'Caal', '5010-1096', 'joaquin.caal@ventas.ropa.gt'),
('Minerva', 'Ixcol', '5010-1097', 'minerva.ixcol@ventas.ropa.gt'),
('Natalia', 'Pérez', '5010-1098', 'natalia.perez@ventas.ropa.gt'),
('Iván', 'Sánchez', '5010-1099', 'ivan.sanchez@ventas.ropa.gt');
