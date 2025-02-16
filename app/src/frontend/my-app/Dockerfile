# Use an official Node.js runtime as a parent image
FROM node:18

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files
COPY . .

# Build the React app
RUN npm run build

# Use nginx to serve the built frontend
FROM nginx:latest
COPY --from=0 /app/build /usr/share/nginx/html

# Expose the port
EXPOSE 80

# Start the server
CMD ["nginx", "-g", "daemon off;"]
