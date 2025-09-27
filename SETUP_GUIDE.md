# NutriApp Setup Guide

## 🔧 Issues Fixed

This guide addresses the key fixes made to ensure the NutriApp runs correctly:

### Fixed Issues:
1. **API URL Configuration Mismatch** - Unified frontend services to use `http://localhost:8051`
2. **Password Verification Bug** - Fixed backend authentication to work with demo credentials
3. **Mock Data Authentication** - Updated mock passwords to match demo credentials
4. **Session Management** - Added error handling for session date parsing
5. **Environment Configuration** - Added proper environment variable handling

## 🚀 Quick Start

### Prerequisites
- Node.js (v14 or higher)
- ColdFusion server (Lucee or Adobe ColdFusion)

### Option 1: Frontend Only (Mock Data)

1. **Start Frontend:**
   ```bash
   # Navigate to project root
   cd /Users/nirmalar/nutriapp
   
   # Make startup script executable
   chmod +x start-frontend.sh
   
   # Start frontend (automatically installs dependencies)
   ./start-frontend.sh
   ```

2. **Start Backend (Optional - for full functionality):**
   - Deploy the `backend/` folder to your ColdFusion server
   - Ensure server is running on port 8500/8051
   - The app includes comprehensive sample data for demonstration

### Option 2: Full Backend Setup

1. **Deploy ColdFusion Backend:**
   - Copy `backend/` to your CF server webroot
   - Configure CF server to run on port 8500/8051
   - The backend uses in-memory data storage for fast performance

2. **Start ColdFusion Server:**
   - Ensure your CF server is running
   - The app will automatically initialize with sample data
   - All data is stored in application memory during runtime

## 🎯 Demo Credentials

The app includes these demo accounts:

**Regular User:**
- Email: `john@example.com`
- Password: `password123`

**Admin User:**
- Email: `admin@nutriapp.com` 
- Password: `admin123`

## 🔧 Configuration

### Frontend Environment Variables
Create `.env` file in `/frontend/` directory:

```env
# NutriApp Frontend Configuration
REACT_APP_API_URL=http://localhost:8051
REACT_APP_APP_NAME=NutriApp - Nutrition Product Rating Platform

# Development settings
GENERATE_SOURCEMAP=false
BROWSER=false
```

### Backend Configuration
The `backend/Application.cfc` is pre-configured for in-memory storage:

```coldfusion
<!--- Data Storage Settings --->
<cfset this.appName = "NutriApp">

<!--- CORS Settings for React Frontend --->
<cfset this.allowedOrigins = ["http://localhost:3000", "http://127.0.0.1:3000"]>
```

## 🧪 Testing the Fixes

1. **Frontend starts without errors**
2. **Login works with demo credentials**
3. **Product search displays results (from mock data)**
4. **Admin panel accessible with admin account**
5. **No console errors in browser**

## 📱 Application Features

- **Product Search & Rating System (A-E)**
- **Smart Product Suggestions**
- **User Authentication**
- **Admin Product Management** 
- **Responsive Mobile Design**
- **In-Memory Data Storage**

## 🐛 Troubleshooting

### Frontend Issues:
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Check for port conflicts
lsof -i :3000
```

### Backend Issues:
- Verify ColdFusion server is running
- Check CF server logs for errors
- Confirm CORS settings allow frontend origin
- For production: implement proper password hashing (BCrypt)

### In-Memory Data Storage:
The app uses fast in-memory storage with comprehensive sample data. This makes it perfect for demonstrations and development with instant data access.

## 🔒 Security Notes

**For Production Use:**
1. Replace simplified password hashing with BCrypt
2. Implement persistent database storage (MongoDB, PostgreSQL, etc.)
3. Implement HTTPS
4. Add input validation and sanitization
5. Set up proper error handling and logging

## 📞 Support

The app includes comprehensive error handling and in-memory data storage, making it robust for demo purposes. All major components have been tested and optimized for performance.

---

**Ready to run!** 🥗 Start with `./start-frontend.sh` and use the demo credentials to explore the app.
