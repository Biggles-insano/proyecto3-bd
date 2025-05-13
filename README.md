# Sistema de inventario y ventas en una tienda de ropa

Este es un sistema de inventario para una tienda de ropa. El proyecto tiene como objetivo gestionar productos, clientes, facturas y ventas de manera eficiente. Utiliza una base de datos relacional PostgreSQL, React para el frontend y diversas herramientas para su implementación.

## Tecnologías Utilizadas

- **Frontend:** React para la creación de interfaces de usuario dinámicas.
- **Backend:**
  - Node.js para gestionar las peticiones del cliente y la lógica del negocio.
  - Express para gestionar las rutas y el servidor.
- **Base de Datos:**
  - PostgreSQL como base de datos relacional para almacenar la información sobre productos, clientes, facturas, etc.
  - pgAdmin como herramienta gráfica para administrar la base de datos PostgreSQL.
- **Docker:** docker-compose para configurar los contenedores y facilitar la ejecución del proyecto en cualquier entorno.

## Instalación

### Requisitos previos

- Tener instalado Docker para ejecutar el proyecto en contenedores.
- Tener Node.js y npm instalados para el backend y frontend.
- Tener acceso a PostgreSQL (puedes usar pgAdmin o cualquier otro cliente de PostgreSQL).

### Pasos para instalar

1. **Clonar el repositorio:**

```bash
git clone https://github.com/Biggles-insano/proyecto3-bd.git
```
```bash
cd proyecto3-bd
```

2.  **Teniendo Docker Desktop abierto corremos:**
```bash
docker-compose up --build
```

3.  **Te diriges a tu browser al puerto 4173 para visualizar el proyecto :**
```bash
http://localhost:4173/
```

Nota: Para correr el programa se debieron de haber insertado las credenciales de la base de datos del archivo docker-compose.yml en pgadmin para tener acceso su información y querys. 
