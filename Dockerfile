# Step 1: Use a lightweight Node.js image
FROM node:20-alpine

# Step 2: Set working directory
WORKDIR /app

# Step 3: Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Step 4: Copy the rest of the app
COPY . .

# Step 5: Expose the port your app listens on
EXPOSE 3000

# Step 6: Start Node.js app with tracing preloaded
CMD ["node", "-r", "./tracing.js", "app.js"]
