import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import './Navbar.css';

const Navbar = () => {
  const { user, logout, isAdmin } = useAuth();
  const location = useLocation();

  const handleLogout = async () => {
    await logout();
  };

  const isActive = (path) => {
    return location.pathname === path ? 'active' : '';
  };

  return (
    <nav className="navbar">
      <div className="navbar-container">
        <Link to="/" className="navbar-brand">
          🥗 NutriApp
        </Link>

        <div className="navbar-menu">
          <div className="navbar-nav">
            <Link to="/" className={`navbar-item ${isActive('/')}`}>
              Home
            </Link>
            <Link to="/search" className={`navbar-item ${isActive('/search')}`}>
              Search Products
            </Link>
          </div>

          <div className="navbar-actions">
            {user ? (
              <>
                <div className="user-info">
                  <span className="user-name">
                    Welcome, {user.username}
                    {isAdmin && <span className="admin-badge">Admin</span>}
                  </span>
                </div>
                
                {isAdmin && (
                  <Link to="/admin" className={`navbar-item admin-link ${isActive('/admin')}`}>
                    Admin Panel
                  </Link>
                )}
                
                <button onClick={handleLogout} className="navbar-button logout-button">
                  Logout
                </button>
              </>
            ) : (
              <>
                <Link to="/login" className={`navbar-button login-button ${isActive('/login')}`}>
                  Login
                </Link>
                <Link to="/register" className={`navbar-button register-button ${isActive('/register')}`}>
                  Register
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
