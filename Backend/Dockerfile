FROM node:18-alpine

WORKDIR /app

# Copiar archivos de configuración de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar el resto del código fuente
COPY . .

# ⚠️ Generar el cliente de Prisma
RUN npx prisma generate

# Exponer el puerto del servidor Express
EXPOSE 5000

# Comando para iniciar la aplicación
CMD ["npm", "start"]
