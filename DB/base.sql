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


-- Inserts para tabla Producto
INSERT INTO Producto (nombre, descripcion, precio, stock_disponible, categoria_id, proveedor_id, marca_id) VALUES
('Camiseta básica blanca', 'Camiseta de algodón 100% color blanco', 15.00, 150, 1, 1, 1),
('Camiseta polo azul marino', 'Polo de pique con logo bordado', 25.00, 120, 1, 2, 2),
('Jean slim fit', 'Pantalón de mezclilla slim fit color oscuro', 45.00, 80, 2, 3, 3),
('Chaqueta bomber negra', 'Chaqueta bomber con cierre metálico y bolsillos laterales', 65.00, 60, 3, 4, 4),
('Zapatos deportivos blancos', 'Zapatos deportivos de cuero sintético y suela de goma', 55.00, 100, 4, 5, 5),
('Cinturón de cuero café', 'Cinturón clásico de cuero con hebilla metálica', 20.00, 200, 14, 6, 6),
('Vestido midi floral', 'Vestido midi con estampado floral y tirantes ajustables', 70.00, 40, 6, 7, 7),
('Sudadera con capucha gris', 'Sudadera de felpa suave con capucha y bolsillo canguro', 35.00, 90, 7, 8, 8),
('Short de mezclilla', 'Short de mezclilla azul claro con dobladillo deshilachado', 25.00, 75, 8, 9, 9),
('Falda plisada negra', 'Falda plisada de poliéster con cintura elástica', 30.00, 60, 9, 10, 10),
('Traje de baño estampado', 'Traje de baño de secado rápido con estampado tropical', 28.50, 50, 10, 11, 11),
('Blusa manga larga blanca', 'Blusa de gasa blanca con botones frontales', 22.00, 110, 11, 12, 12),
('Abrigo largo camel', 'Abrigo largo de paño color camel con solapas anchas', 120.00, 30, 12, 13, 13),
('Pack de calcetines deportivos', 'Pack de 5 pares de calcetines de algodón', 12.00, 300, 13, 14, 14),
('Cinturón trenzado azul', 'Cinturón trenzado de poliéster con detalles en cuero', 18.00, 140, 14, 15, 15),
('Gorra de béisbol roja', 'Gorra ajustable de algodón con visera curva', 17.00, 80, 15, 1, 16),
('Bufanda de lana gris', 'Bufanda tejida de lana suave color gris', 22.50, 60, 16, 2, 17),
('Guantes térmicos negros', 'Guantes térmicos de poliéster ideales para invierno', 19.00, 70, 17, 3, 18),
('Pijama de dos piezas', 'Pijama de algodón con camiseta y pantalón estampados', 32.00, 50, 18, 4, 19),
('Overol de mezclilla', 'Overol de mezclilla azul con tirantes ajustables', 55.00, 30, 19, 5, 1),
('Camiseta estampada urbana', 'Camiseta con estampado gráfico urbano', 18.00, 100, 1, 6, 2),
('Pantalón cargo verde', 'Pantalón cargo de algodón con múltiples bolsillos', 38.00, 55, 2, 7, 3),
('Chaqueta impermeable azul', 'Chaqueta impermeable con capucha y cierre frontal', 68.00, 45, 3, 8, 4),
('Zapatos casuales marrones', 'Zapatos casuales de gamuza con suela antideslizante', 62.00, 85, 4, 9, 5),
('Corbata de seda azul', 'Corbata de seda 100% color azul marino', 27.00, 90, 5, 10, 6),
('Vestido corto rojo', 'Vestido corto de algodón con escote en V', 49.00, 35, 6, 11, 7),
('Sudadera oversize beige', 'Sudadera oversize de felpa beige con puños elásticos', 42.00, 70, 7, 12, 8),
('Short deportivo negro', 'Short deportivo ligero con cintura elástica', 16.00, 120, 8, 13, 9),
('Falda denim azul', 'Falda corta de mezclilla azul con botones frontales', 29.00, 65, 9, 14, 10),
('Bikini de rayas', 'Bikini de dos piezas con estampado de rayas', 35.00, 40, 10, 15, 11),
('Blusa sin mangas verde', 'Blusa de viscosa sin mangas con cuello redondo', 21.00, 85, 11, 1, 12),
('Abrigo acolchado negro', 'Abrigo acolchado con cierre y bolsillos laterales', 110.00, 25, 12, 2, 13),
('Pack de calcetines invisibles', 'Pack de 3 pares de calcetines invisibles', 10.00, 200, 13, 3, 14),
('Cinturón elástico negro', 'Cinturón elástico con hebilla metálica', 14.00, 115, 14, 4, 15),
('Gorra trucker blanca', 'Gorra trucker con malla trasera y logo bordado', 19.00, 70, 15, 5, 16),
('Bufanda estampada', 'Bufanda de poliéster con estampado floral', 25.00, 50, 16, 6, 17),
('Guantes de cuero marrón', 'Guantes de cuero genuino forrados en tela', 35.00, 35, 17, 7, 18),
('Pijama polar azul', 'Pijama de polar azul para invierno', 40.00, 30, 18, 8, 19),
('Overol corto beige', 'Overol corto de lino beige con bolsillos frontales', 48.00, 28, 19, 9, 1),
('Camiseta deportiva gris', 'Camiseta de poliéster transpirable para deporte', 20.00, 130, 1, 10, 2),
('Pantalón de vestir negro', 'Pantalón de vestir corte recto color negro', 50.00, 47, 2, 11, 3),
('Chaqueta de mezclilla azul', 'Chaqueta de mezclilla azul claro con botones metálicos', 58.00, 37, 3, 12, 4),
('Zapatos formales negros', 'Zapatos de piel para ocasiones formales', 80.00, 70, 4, 13, 5),
('Correa de tela gris', 'Correa de tela con hebilla ajustable', 13.00, 170, 5, 14, 6),
('Vestido largo azul marino', 'Vestido largo de gasa azul marino', 95.00, 22, 6, 15, 7),
('Sudadera estampada blanca', 'Sudadera blanca con estampado frontal', 36.00, 65, 7, 1, 8),
('Short running azul', 'Short para correr de secado rápido', 18.00, 90, 8, 2, 9),
('Falda midi estampada', 'Falda midi con estampado geométrico', 34.00, 40, 9, 3, 10),
('Traje de baño enterizo negro', 'Traje de baño enterizo con escote en V', 40.00, 35, 10, 4, 11),
('Blusa con volantes rosa', 'Blusa de manga corta con volantes', 26.00, 75, 11, 5, 12),
('Abrigo impermeable verde', 'Abrigo impermeable con forro interior', 130.00, 18, 12, 6, 13),
('Pack de calcetines altos', 'Pack de 4 pares de calcetines altos', 14.00, 180, 13, 7, 14),
('Cinturón doble vuelta marrón', 'Cinturón de cuero doble vuelta', 22.00, 95, 14, 8, 15),
('Gorra deportiva negra', 'Gorra ligera para deporte con ajuste trasero', 15.00, 110, 15, 9, 16),
('Bufanda tubular azul', 'Bufanda tubular multifuncional', 13.50, 100, 16, 10, 17),
('Guantes para ciclismo', 'Guantes acolchados para ciclismo', 17.00, 45, 17, 11, 18),
('Pijama de franela cuadros', 'Pijama de franela con estampado de cuadros', 38.00, 32, 18, 12, 19),
('Overol largo negro', 'Overol largo de algodón negro', 56.00, 26, 19, 13, 1),
('Camiseta manga larga azul', 'Camiseta manga larga de algodón azul', 23.00, 105, 1, 14, 2),
('Pantalón jogger gris', 'Pantalón jogger de felpa gris', 32.00, 67, 2, 15, 3),
('Chaqueta acolchada roja', 'Chaqueta acolchada ligera color rojo', 72.00, 41, 3, 1, 4),
('Zapatos mocasines café', 'Mocasines de cuero color café', 65.00, 53, 4, 2, 5),
('Cinturón reversible negro/café', 'Cinturón reversible de cuero', 28.00, 80, 14, 3, 6),
('Vestido camisero blanco', 'Vestido camisero de lino blanco', 60.00, 33, 6, 4, 7),
('Sudadera básica negra', 'Sudadera básica de algodón color negro', 28.00, 97, 7, 5, 8),
('Short denim desgastado', 'Short denim azul con efecto desgastado', 27.00, 65, 8, 6, 9),
('Falda lápiz gris', 'Falda lápiz de punto color gris', 31.00, 52, 9, 7, 10),
('Bañador deportivo azul', 'Bañador deportivo con protección UV', 38.00, 38, 10, 8, 11),
('Blusa cruzada beige', 'Blusa cruzada de viscosa beige', 24.00, 77, 11, 9, 12),
('Abrigo de borrego marrón', 'Abrigo de borrego sintético marrón', 145.00, 20, 12, 10, 13),
('Pack de calcetines tobilleros', 'Pack de 6 pares de calcetines tobilleros', 16.00, 210, 13, 11, 14),
('Cinturón con remaches', 'Cinturón de cuero con remaches metálicos', 21.00, 104, 14, 12, 15),
('Gorra plana negra', 'Gorra plana estilo urbano', 18.00, 85, 15, 13, 16),
('Bufanda de algodón azul', 'Bufanda ligera de algodón azul', 20.00, 63, 16, 14, 17),
('Guantes de lana gris', 'Guantes de lana gruesa color gris', 23.00, 42, 17, 15, 18),
('Pijama estampada rosa', 'Pijama de algodón rosa con estampado floral', 29.00, 48, 18, 1, 19),
('Overol de trabajo azul', 'Overol de trabajo resistente color azul', 62.00, 18, 19, 2, 1),
('Camiseta cuello V negra', 'Camiseta de algodón con cuello en V', 16.00, 112, 1, 3, 2),
('Pantalón chino beige', 'Pantalón chino de algodón beige', 41.00, 72, 2, 4, 3),
('Chaqueta softshell gris', 'Chaqueta softshell impermeable gris', 98.00, 35, 3, 5, 4),
('Zapatos de lona azul', 'Zapatos de lona con suela blanca', 33.00, 115, 4, 6, 5),
('Correa de cuero negra', 'Correa de cuero genuino color negro', 19.00, 87, 5, 7, 6),
('Vestido de tirantes verde', 'Vestido corto de tirantes color verde', 53.00, 29, 6, 8, 7),
('Sudadera con cremallera roja', 'Sudadera roja con cierre completo', 34.00, 90, 7, 9, 8),
('Short de algodón gris', 'Short de algodón suave color gris', 19.00, 120, 8, 10, 9),
('Falda evasé azul', 'Falda evasé de algodón azul', 28.00, 60, 9, 11, 10),
('Traje de baño bikini negro', 'Bikini negro clásico de dos piezas', 37.00, 36, 10, 12, 11),
('Blusa estampada azul', 'Blusa de manga larga con estampado azul', 25.00, 65, 11, 13, 12),
('Abrigo cruzado gris', 'Abrigo cruzado de paño gris', 115.00, 21, 12, 14, 13),
('Pack de calcetines rayados', 'Pack de 5 pares de calcetines rayados', 13.00, 180, 13, 15, 14),
('Cinturón de tela beige', 'Cinturón de tela con punta de cuero', 12.00, 105, 14, 1, 15),
('Gorra de algodón verde', 'Gorra ajustable de algodón verde', 16.00, 92, 15, 2, 16),
('Bufanda tejida marrón', 'Bufanda tejida a mano color marrón', 24.00, 54, 16, 3, 17),
('Guantes impermeables negros', 'Guantes impermeables para lluvia', 26.00, 33, 17, 4, 18),
('Pijama de algodón azul', 'Pijama de algodón suave color azul', 27.00, 44, 18, 5, 19),
('Overol corto vaquero', 'Overol corto de mezclilla azul', 47.00, 27, 19, 6, 1),
('Camiseta sin mangas blanca', 'Camiseta de algodón sin mangas', 13.00, 140, 1, 7, 2),
('Pantalón palazzo negro', 'Pantalón palazzo de viscosa negro', 39.00, 49, 2, 8, 3),
('Chaqueta vaquera clara', 'Chaqueta vaquera azul claro', 53.00, 38, 3, 9, 4),
('Zapatos sandalias marrón', 'Sandalias de cuero marrón', 44.00, 90, 4, 10, 5),
('Correa deportiva azul', 'Correa elástica para deporte', 11.00, 132, 5, 11, 6),
('Vestido con encaje blanco', 'Vestido corto con detalles de encaje', 61.00, 26, 6, 12, 7),
('Sudadera cropped negra', 'Sudadera corta negra de algodón', 31.00, 88, 7, 13, 8),
('Short running verde', 'Short para correr verde con detalles reflectantes', 15.00, 105, 8, 14, 9),
('Falda tul rosa', 'Falda de tul rosa para ocasiones especiales', 37.00, 19, 9, 15, 10),
('Parka impermeable azul noche', 'Chaqueta parka resistente al agua con capucha interior', 120.00, 40, 3, 5, 10);
