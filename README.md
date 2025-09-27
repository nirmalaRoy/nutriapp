# NutriApp - Nutrition Product Rating Platform

A comprehensive nutrition product rating application built with React.js frontend, ColdFusion CFML backend, and in-memory data storage.

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

## Technology Stack

### Frontend
- **React.js**: User interface framework
- **React Router**: Client-side routing
- **Axios**: HTTP client for API communication
- **CSS3**: Custom styling with responsive design

### Backend
- **ColdFusion CFML**: Server-side application logic
- **RESTful API**: JSON-based API endpoints
- **Session Management**: Secure user authentication
- **CORS Support**: Cross-origin resource sharing

### Data Storage
- **In-Memory Storage**: Fast application-scoped data storage
- **Collections**: Users, Products, Sessions stored in application memory
- **Mock Data**: Pre-populated sample data for demonstration

## Project Structure

```
nutriapp/
├── frontend/                 # React.js application
│   ├── src/
│   │   ├── components/       # Reusable React components
│   │   ├── contexts/         # React context providers
│   │   ├── pages/           # Page components
│   │   ├── services/        # API service functions
│   │   └── App.js           # Main application component
│   ├── public/              # Static assets
│   └── package.json         # Node.js dependencies
├── backend/                 # ColdFusion CFML backend
│   ├── components/          # ColdFusion components (CFCs)
│   ├── api/                 # API endpoints
│   ├── Application.cfc      # Application configuration
│   └── index.cfm           # API documentation endpoint
├── backend/components/      # Data service and mock data
│   └── MockData.cfc         # Sample product data
└── README.md               # Project documentation
```

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

## Setup Instructions

### Prerequisites
- Node.js and npm
- ColdFusion server (Lucee or Adobe ColdFusion)

### Frontend Setup
```bash
cd frontend
npm install
npm start
```
The React app will run on http://localhost:3000

### Backend Setup
1. Deploy the backend folder to your ColdFusion server
2. Ensure CORS is properly configured for the React frontend
3. The app will automatically initialize with sample data on first start

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

## Contributing

This is a demonstration application. For production use, consider:
- Implementing persistent database storage (MongoDB, PostgreSQL, etc.)
- Adding comprehensive error handling
- Implementing data validation
- Adding automated testing
- Setting up CI/CD pipeline
- Implementing proper user authentication

---

**NutriApp** - Making better nutrition choices easier! 🥗
