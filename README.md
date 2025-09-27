# 🥗 NutriApp - Nutrition Product Rating Platform

A comprehensive full-stack nutrition product rating application built with React.js frontend, ColdFusion CFML backend, and MySQL database integration. This application helps users make better nutrition choices by providing detailed product ratings and smart alternatives.

## 🚀 Quick Start

### Prerequisites
- Node.js (v14 or higher)
- npm or yarn
- ColdFusion server (Lucee recommended) or CommandBox
- MySQL database server

### Running the Application

#### Option 1: Using the Start Script (Recommended)
```bash
# Make the start script executable (first time only)
chmod +x start-frontend.sh

# Start the frontend development server
./start-frontend.sh
```

#### Option 2: Manual Setup
```bash
# 1. Start the frontend
cd frontend
npm install
npm start

# 2. In a new terminal, start the backend (if using CommandBox)
cd backend
box start

# The frontend runs on: http://localhost:3000
# The backend API runs on: http://localhost:8080 (or your ColdFusion server port)
```

#### Option 3: Development Environment Setup
```bash
# Install frontend dependencies
cd frontend && npm install

# Start both frontend and backend in development mode
cd .. && npm run dev  # (if package.json scripts are configured)
```

## Features

### User Features
- **User Registration & Login**: Secure authentication system
- **Product Search**: Search products by name, category, or rating
- **Product Ratings**: Products rated from A (Best) to E (Worst)
- **Smart Suggestions**: Get recommendations for better alternatives
- **Category Browsing**: Browse by product categories (protein powder, chips, chocolates, popcorn, biscuits)

### Admin Features
- **Admin Panel**: Manage products and categories
- **Product Management**: Add, edit, and delete products
- **User Management**: View and manage user accounts

### Product Categories
- Protein Powder Supplements
- Chips & Snacks
- Chocolates & Sweets
- Popcorn & Corn Snacks  
- Biscuits & Cookies

### Rating System
- **A (Best)**: Highest quality, best nutritional value
- **B (Better)**: Good quality with minor concerns
- **C (Good)**: Average quality, acceptable choice
- **D (Bad)**: Below average, better alternatives available
- **E (Worst)**: Poor quality, not recommended

## 🏗️ Technology Stack & Architecture

### Frontend (React.js)
- **React.js 18+**: Modern hooks-based UI framework
- **React Router v6**: Client-side routing and navigation
- **Axios**: HTTP client for API communication with interceptors
- **Context API**: Global state management for authentication
- **CSS3**: Custom responsive styling with modern design
- **JavaScript ES6+**: Modern JavaScript features

### Backend (ColdFusion CFML)
- **ColdFusion/Lucee**: Server-side application logic
- **RESTful API**: JSON-based API endpoints with proper HTTP methods
- **CFC Components**: Object-oriented backend architecture
- **Session Management**: Secure user authentication with session tracking
- **CORS Support**: Cross-origin resource sharing enabled
- **MySQL Integration**: Database connectivity with prepared statements

### Database Layer
- **MySQL**: Relational database for persistent data storage
- **Schema Management**: Structured database with proper relationships
- **Data Services**: Abstracted data access layer
- **Sample Data**: Pre-populated demo data for testing

### Development Tools
- **Git**: Version control with GitHub integration
- **npm**: Package management for frontend dependencies
- **CommandBox**: ColdFusion development server (optional)
- **VS Code**: Recommended IDE with extensions

## 🔄 API Integration & Communication Flow

### How API Calls Are Made

#### Frontend → Backend Communication
```javascript
// Example: User authentication
const login = async (email, password) => {
  try {
    const response = await axios.post('/api/auth/login', {
      email,
      password
    });
    return response.data;
  } catch (error) {
    throw error.response.data;
  }
};

// Example: Fetching products with search
const searchProducts = async (query) => {
  const response = await axios.get('/api/products/search', {
    params: { q: query }
  });
  return response.data;
};
```

#### Backend API Response Format
```json
// Success Response
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    }
  },
  "message": "Login successful"
}

// Error Response
{
  "success": false,
  "error": "Invalid credentials",
  "code": 401
}
```

### API Architecture
- **RESTful Design**: Standard HTTP methods (GET, POST, PUT, DELETE)
- **JSON Communication**: All requests and responses use JSON format
- **Authentication**: Session-based auth with secure token management
- **Error Handling**: Consistent error responses with proper HTTP status codes
- **CORS Configuration**: Enables cross-origin requests from React frontend

## 📁 Project Structure

```
nutriapp/
├── 📁 frontend/                    # React.js Frontend Application
│   ├── 📁 public/                  # Static assets
│   │   ├── index.html              # HTML entry point
│   │   ├── favicon.ico             # App icon
│   │   └── manifest.json           # PWA manifest
│   ├── 📁 src/
│   │   ├── 📁 components/          # Reusable React components
│   │   │   ├── Navbar.js           # Navigation component
│   │   │   ├── ProductCard.js      # Product display card
│   │   │   ├── NutritionDetails.js # Nutrition info display
│   │   │   └── API test components  # Testing utilities
│   │   ├── 📁 contexts/            # React Context providers
│   │   │   └── AuthContext.js      # Authentication state
│   │   ├── 📁 pages/              # Page-level components
│   │   │   ├── Home.js             # Landing page
│   │   │   ├── Login.js & Register.js  # Auth pages
│   │   │   ├── ProductSearch.js    # Search interface
│   │   │   ├── ProductDetails.js   # Product detail view
│   │   │   └── AdminPanel.js       # Admin dashboard
│   │   ├── 📁 services/           # API communication layer
│   │   │   ├── authService.js      # Authentication API calls
│   │   │   └── productService.js   # Product API calls
│   │   ├── App.js                 # Main application component
│   │   └── index.js               # React entry point
│   ├── package.json               # Dependencies & scripts
│   └── README.md                  # Frontend documentation
├── 📁 backend/                    # ColdFusion CFML Backend
│   ├── 📁 api/                    # REST API endpoints
│   │   ├── auth.cfm               # Authentication endpoints
│   │   └── products.cfm           # Product endpoints
│   ├── 📁 components/             # ColdFusion Components (CFCs)
│   │   ├── AuthService.cfc        # User authentication logic
│   │   ├── ProductService.cfc     # Product business logic
│   │   ├── DataService.cfc        # Data access interface
│   │   └── MySQLDataService.cfc   # MySQL implementation
│   ├── 📁 database/               # Database files
│   │   ├── schema.sql             # Database structure
│   │   └── populate_data.sql      # Sample data insertion
│   ├── Application.cfc            # App configuration & settings
│   ├── index.cfm                  # API documentation
│   ├── server.json                # CommandBox server config
│   ├── web.config                 # IIS configuration
│   └── mysql-connector-java.jar   # MySQL JDBC driver
├── 📁 .git/                      # Git version control
├── .gitignore                     # Git ignore patterns
├── start-frontend.sh              # Frontend startup script
├── README.md                      # This documentation
├── SETUP_GUIDE.md                 # Detailed setup instructions
└── QUICK_FIX_GUIDE.md            # Troubleshooting guide
```

## 🗄️ Database Setup

### MySQL Database Configuration

#### 1. Create Database
```sql
CREATE DATABASE nutriapp;
USE nutriapp;
```

#### 2. Run Schema Script
```bash
# From the project root
mysql -u your_username -p nutriapp < backend/database/schema.sql
```

#### 3. Populate Sample Data
```bash
mysql -u your_username -p nutriapp < backend/database/populate_data.sql
```

#### 4. Update Database Configuration
Edit `backend/Application.cfc` with your database credentials:
```javascript
this.datasource = "nutriapp_db";
this.datasources = {
    nutriapp_db: {
        class: "com.mysql.cj.jdbc.Driver",
        connectionString: "jdbc:mysql://localhost:3306/nutriapp",
        username: "your_username",
        password: "your_password"
    }
};
```

## 🚀 Git Integration & Version Control

### Repository Setup
This project is integrated with Git and hosted on GitHub:
- **Repository**: [https://github.com/nirmalaRoy/nutriapp](https://github.com/nirmalaRoy/nutriapp)
- **Branch Strategy**: Main branch for stable releases
- **Commit History**: Full project history with meaningful commits

### Git Commands for Development
```bash
# Clone the repository
git clone https://github.com/nirmalaRoy/nutriapp.git
cd nutriapp

# Check current status
git status

# Add changes
git add .

# Commit changes
git commit -m "Your commit message"

# Push to GitHub
git push origin main

# Pull latest changes
git pull origin main
```

### Development Workflow
1. **Feature Development**: Create feature branches for new features
2. **Testing**: Test thoroughly before committing
3. **Commit**: Make atomic commits with clear messages
4. **Push**: Push to GitHub for backup and collaboration

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/logout` - User logout
- `GET /api/auth/validate` - Validate session
- `GET /api/auth/me` - Get current user info

### Products
- `GET /api/products` - Get all products
- `GET /api/products/search` - Search products
- `GET /api/products/{id}` - Get product by ID
- `GET /api/products/suggestions/{id}` - Get product suggestions
- `GET /api/products/categories` - Get product categories
- `GET /api/products/ratings` - Get rating system info
- `POST /api/products` - Add new product (admin only)

## 📋 Detailed Setup Instructions

### Prerequisites Checklist
- ✅ **Node.js** (v14+ required): [Download here](https://nodejs.org/)
- ✅ **npm** or **yarn**: Comes with Node.js
- ✅ **MySQL Server** (v8.0+): [Download here](https://dev.mysql.com/downloads/)
- ✅ **ColdFusion Server**: 
  - **Lucee** (recommended): [Download here](https://lucee.org/)
  - **CommandBox** (easiest): `npm install -g @ortussolutions/commandbox`
  - **Adobe ColdFusion** (enterprise)

### Step-by-Step Setup

#### 1. Clone and Setup Repository
```bash
# Clone from GitHub
git clone https://github.com/nirmalaRoy/nutriapp.git
cd nutriapp

# Make scripts executable
chmod +x start-frontend.sh
```

#### 2. Database Setup
```bash
# 1. Create MySQL database
mysql -u root -p
CREATE DATABASE nutriapp;
exit

# 2. Import schema and data
mysql -u root -p nutriapp < backend/database/schema.sql
mysql -u root -p nutriapp < backend/database/populate_data.sql
```

#### 3. Backend Configuration
```bash
# Navigate to backend
cd backend

# Option A: Using CommandBox (recommended)
box start

# Option B: Copy to existing ColdFusion server
# Copy entire backend folder to your CF webroot
```

#### 4. Frontend Setup
```bash
# Navigate to frontend
cd frontend

# Install dependencies
npm install

# Start development server
npm start
```

#### 5. Access Application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080 (or your CF server port)
- **API Docs**: http://localhost:8080/index.cfm

### Environment Configuration

#### Backend Configuration (`backend/Application.cfc`)
```javascript
// Update database settings
this.datasources = {
    nutriapp_db: {
        class: "com.mysql.cj.jdbc.Driver",
        connectionString: "jdbc:mysql://localhost:3306/nutriapp?useSSL=false",
        username: "root", // Your MySQL username
        password: "your_password", // Your MySQL password
        connectionLimit: 20,
        validate: true
    }
};

// CORS settings for React frontend
this.customTagPaths = {};
this.enableNullSupport = true;
this.sessionManagement = true;
this.sessionTimeout = createTimeSpan(0, 2, 0, 0); // 2 hours
```

#### Frontend API Configuration (`frontend/src/services/authService.js`)
```javascript
// Update base URL if needed
const API_BASE_URL = 'http://localhost:8080/api';
// For production: const API_BASE_URL = 'https://your-domain.com/api';
```

## Demo Credentials

### Regular User
- Email: john@example.com
- Password: password123

### Admin User  
- Email: admin@nutriapp.com
- Password: admin123

## Features in Detail

### Product Search & Suggestions
- Search products by keyword, category, or rating
- View detailed product information
- Get suggestions for better rated alternatives
- Progressive suggestion system (D→C→B→A)

### Rating System Intelligence  
- When viewing a D-rated product, see C-rated alternatives
- When viewing a C-rated product, see B-rated alternatives  
- When viewing B-rated products, see A-rated alternatives
- Always see the best (A-rated) options available

### Responsive Design
- Mobile-first responsive design
- Works on desktop, tablet, and mobile devices
- Touch-friendly interface

## Development Notes

### ColdFusion Backend
- Uses modern CFC (ColdFusion Component) architecture
- RESTful API design with JSON responses
- Secure session management
- CORS enabled for frontend integration

### React Frontend
- Modern React with hooks and context API
- Component-based architecture
- Responsive CSS with mobile-first approach
- Loading states and error handling

### Data Storage Design
- Application-scoped in-memory data collections
- Fast access and manipulation of data
- Comprehensive sample data for demonstration

## Future Enhancements

- Real-time notifications
- User reviews and ratings
- Barcode scanning
- Nutrition analysis API integration
- Social features (share favorites)
- Advanced filtering options
- Mobile app development

## 🚀 Deployment Guide

### Development Deployment
```bash
# Start both services in development mode
# Terminal 1: Frontend
cd frontend && npm start

# Terminal 2: Backend  
cd backend && box start
```

### Production Deployment

#### Frontend (React)
```bash
# Build production bundle
cd frontend
npm run build

# Deploy build folder to web server (Apache, Nginx, etc.)
# Or use services like Netlify, Vercel, or GitHub Pages
```

#### Backend (ColdFusion)
```bash
# Option 1: CommandBox Production
box start production=true

# Option 2: Deploy to existing CF server
# Copy backend folder to CF webroot
# Configure datasource in CF Administrator
# Ensure CORS headers are set for production domain
```

### Production Configuration

#### Environment Variables
```bash
# Frontend (.env.production)
REACT_APP_API_URL=https://your-api-domain.com/api
REACT_APP_ENV=production

# Backend (Application.cfc)
// Update for production
this.datasources.nutriapp_db.connectionString = 
    "jdbc:mysql://your-db-server:3306/nutriapp";
```

## 🛠️ Troubleshooting

### Common Issues & Solutions

#### Frontend Issues
```bash
# Issue: npm install fails
# Solution: Clear npm cache
npm cache clean --force
rm -rf node_modules package-lock.json
npm install

# Issue: CORS errors
# Solution: Check backend CORS configuration in Application.cfc

# Issue: API calls fail
# Solution: Verify backend URL in service files
```

#### Backend Issues
```bash
# Issue: MySQL connection fails
# Check: Database credentials in Application.cfc
# Check: MySQL server is running
# Check: Database exists and has proper permissions

# Issue: ColdFusion server won't start
# Solution: Check server.json configuration
# Check: Port conflicts (default: 8080)
# Check: Java installation and JAVA_HOME

# Issue: Session/Authentication issues
# Check: Session management enabled in Application.cfc
# Check: CORS headers include credentials
```

#### Database Issues
```sql
-- Issue: Tables don't exist
-- Solution: Run schema script
SOURCE backend/database/schema.sql;

-- Issue: No data in tables  
-- Solution: Run data population script
SOURCE backend/database/populate_data.sql;

-- Issue: Permission denied
-- Solution: Grant proper MySQL privileges
GRANT ALL PRIVILEGES ON nutriapp.* TO 'your_user'@'localhost';
FLUSH PRIVILEGES;
```

### Performance Optimization

#### Frontend Optimizations
- Enable React production build: `npm run build`
- Implement code splitting with React.lazy()
- Optimize images and assets
- Use React.memo for expensive components
- Implement service worker for caching

#### Backend Optimizations
- Enable ColdFusion query caching
- Implement database connection pooling
- Use prepared statements for all queries
- Enable GZip compression
- Configure proper session timeout

### Development Tools & Extensions

#### Recommended VS Code Extensions
- **ES7+ React/Redux/React-Native snippets**
- **ColdFusion (CFML)** by KamasamaK
- **Auto Rename Tag**
- **Bracket Pair Colorizer**
- **GitLens**
- **Thunder Client** (API testing)

## 📊 API Documentation

### Complete Endpoint Reference

#### Authentication Endpoints
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| POST | `/api/auth/login` | User login | `{email, password}` | `{success, data: {user}, token}` |
| POST | `/api/auth/register` | User registration | `{name, email, password}` | `{success, data: {user}}` |
| POST | `/api/auth/logout` | User logout | - | `{success, message}` |
| GET | `/api/auth/validate` | Validate session | - | `{success, data: {user}}` |
| GET | `/api/auth/me` | Current user info | - | `{success, data: {user}}` |

#### Product Endpoints
| Method | Endpoint | Description | Parameters | Response |
|--------|----------|-------------|------------|----------|
| GET | `/api/products` | Get all products | `?limit=20&offset=0` | `{success, data: [products]}` |
| GET | `/api/products/search` | Search products | `?q=term&category=cat&rating=A` | `{success, data: [products]}` |
| GET | `/api/products/{id}` | Get product by ID | - | `{success, data: {product}}` |
| GET | `/api/products/suggestions/{id}` | Get suggestions | - | `{success, data: [products]}` |
| GET | `/api/products/categories` | Get categories | - | `{success, data: [categories]}` |
| POST | `/api/products` | Create product (admin) | `{name, category, rating, ...}` | `{success, data: {product}}` |

## 🤝 Contributing

### Development Workflow
1. **Fork** the repository on GitHub
2. **Clone** your fork locally
3. **Create** a feature branch: `git checkout -b feature/amazing-feature`
4. **Make** your changes with proper testing
5. **Commit** with descriptive messages: `git commit -m 'Add amazing feature'`
6. **Push** to your branch: `git push origin feature/amazing-feature`
7. **Create** a Pull Request on GitHub

### Code Standards
- **Frontend**: Follow React best practices and ESLint rules
- **Backend**: Follow ColdFusion coding standards
- **Database**: Use proper naming conventions and normalization
- **Git**: Make atomic commits with clear commit messages

### Testing Requirements
- Frontend: Write unit tests for components using Jest/React Testing Library
- Backend: Create test cases for all API endpoints
- Integration: Test complete user workflows
- Performance: Test with realistic data loads

### Production Considerations
This application is designed for educational purposes. For production deployment, implement:
- **Security**: Input validation, SQL injection prevention, XSS protection
- **Database**: Connection pooling, query optimization, backup strategies  
- **Monitoring**: Application logs, performance metrics, error tracking
- **Scalability**: Load balancing, caching layers, CDN integration
- **CI/CD**: Automated testing, deployment pipelines, environment management

---

## 📄 License & Credits

This is an educational project demonstrating full-stack web development with React.js and ColdFusion.

**Created by**: Nirmala Roy  
**Repository**: [https://github.com/nirmalaRoy/nutriapp](https://github.com/nirmalaRoy/nutriapp)  
**Technologies**: React.js, ColdFusion CFML, MySQL  
**Last Updated**: 2025

---

# 🥗 **NutriApp** - Making Better Nutrition Choices Easier!

**⭐ Star this repository if you find it helpful!**
