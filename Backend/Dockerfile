FROM node:18-alpine

WORKDIR /app

# Copiar archivos de configuración de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar código fuente
COPY . .

# Puerto que utilizará la aplicación
EXPOSE 5000

# Comando para iniciar la aplicación 
CMD ["npm", "start"]