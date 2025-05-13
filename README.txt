Sistema de Inventario para Tienda de Ropa

Este es un sistema de inventario para una tienda de ropa. El proyecto tiene como objetivo gestionar productos, clientes, facturas y ventas de manera eficiente. Utiliza una base de datos relacional PostgreSQL, React para el frontend y diversas herramientas para su implementación.

Tecnologías Utilizadas
	•	Frontend:
React para la creación de interfaces de usuario dinámicas.
	•	Backend:
Node.js para gestionar las peticiones del cliente y la lógica del negocio.
Express para gestionar las rutas y el servidor.
	•	Base de Datos:
PostgreSQL como base de datos relacional para almacenar la información sobre productos, clientes, facturas, etc.
pgAdmin como herramienta gráfica para administrar la base de datos PostgreSQL.
	•	Docker:
docker-compose para configurar los contenedores y facilitar la ejecución del proyecto en cualquier entorno.

Instalación

Requisitos previos
	•	Tener instalado Docker para ejecutar el proyecto en contenedores.
	•	Tener Node.js y npm instalados para el backend y frontend.
	•	Tener acceso a PostgreSQL (puedes usar pgAdmin o cualquier otro cliente de PostgreSQL).

Pasos para instalar
	1.	Clonar el repositorio:
Primero, clona el repositorio ejecutando el siguiente comando:

git clone https://github.com/Biggles-insano/proyecto3-bd.git
cd proyecto3-bd


	2.	Configurar el entorno con Docker:
Si no tienes Docker instalado, sigue las instrucciones de instalación de Docker.
Una vez instalado Docker, ejecuta el siguiente comando:

docker-compose up -d

Esto iniciará los contenedores para PostgreSQL y otros servicios necesarios.

	3.	Instalar las dependencias para el frontend:
Navega a la carpeta Frontend y ejecuta:

cd Frontend
npm install


	4.	Instalar las dependencias para el backend:
Navega a la carpeta Backend y ejecuta:

cd Backend
npm install


	5.	Configurar la base de datos:
Asegúrate de que PostgreSQL esté corriendo y ejecuta el archivo init.sql en pgAdmin o cualquier otro cliente de base de datos para crear las tablas necesarias.
	6.	Ejecutar el proyecto:
Una vez que las dependencias estén instaladas, puedes ejecutar el frontend con:

npm start

Y el backend con:

npm start

Esto iniciará el sistema en tu compu.

Uso

El sistema permite realizar las siguientes acciones:
	•	Gestión de Productos: Agregar, editar y eliminar productos de la tienda.
	•	Gestión de Clientes: Registrar nuevos clientes y consultar los existentes.
	•	Gestión de Ventas: Crear facturas, gestionar los detalles de ventas y aplicar descuentos.
	•	Gestión de Inventario: Registrar los movimientos de entrada y salida de productos.

Consultas y Endpoints

El backend proporciona varios endpoints para interactuar con los datos, tales como:
	•	Obtener todos los productos: GET /productos
	•	Crear un nuevo producto: POST /productos
	•	Actualizar un producto: PUT /productos/:id
	•	Eliminar un producto: DELETE /productos/:id
	•	Obtener todas las ventas realizadas: GET /ventas
	•	Crear una nueva venta: POST /ventas

Contribuir

Si deseas contribuir a este proyecto, por favor sigue estos pasos:
	1.	Ponete un 100
  2.  Dona vía PayPal
