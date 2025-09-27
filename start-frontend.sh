#!/bin/bash

# NutriApp Frontend Startup Script
echo "🥗 Starting NutriApp Frontend..."

# Navigate to frontend directory
cd frontend

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Create .env file for API configuration (if it doesn't exist)
if [ ! -f ".env" ]; then
    echo "⚙️ Creating environment configuration..."
    cat > .env << EOF
# NutriApp Frontend Configuration
REACT_APP_API_URL=http://localhost:8051
REACT_APP_APP_NAME=NutriApp
EOF
fi

echo "🚀 Starting React development server..."
echo "Frontend will be available at: http://localhost:3000"
echo ""

# Start the React development server
npm start
