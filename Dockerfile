# Use Node.js 20 LTS
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy backend package.json
COPY backend/package.json ./

# Install dependencies
RUN npm install --production

# Copy all backend files
COPY backend/ ./

# Expose port
EXPOSE 3000

# Start the application
CMD ["node", "server.js"]

