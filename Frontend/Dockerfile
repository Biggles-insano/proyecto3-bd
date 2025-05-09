FROM node:18-alpine

WORKDIR /app

# Copiar archivos de configuración de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar todo el código fuente
COPY . .

# Construir el proyecto (esto genera la carpeta dist/)
RUN npm run build

# Exponer el puerto por donde Vite preview sirve el contenido
EXPOSE 4173

# Iniciar la aplicación en modo preview (producción)
CMD ["npx", "vite", "preview", "--host"]