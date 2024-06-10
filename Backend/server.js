
const express = require('express');
const { Client } = require('pg');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const app = express();
dotenv.config();

const dbClient = new Client({
  connectionString: process.env.DATABASE_URL,
});
dbClient.connect();

app.use(express.json());

// Register a new user
app.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await dbClient.query(
      'INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING id, name, email',
      [name, email, hashedPassword]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Login and create a session
app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const result = await dbClient.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }
    const user = result.rows[0];
    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }
    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.json({ token });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Middleware to check authentication
const authenticate = (req, res, next) => {
  const token = req.header('Authorization').replace('Bearer ', '');
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Please authenticate' });
  }
};

// Check if user session is active
app.get('/session', authenticate, (req, res) => {
  res.json({ active: true });
});

// Logout the user
app.post('/logout', authenticate, (req, res) => {
  res.json({ message: 'Logged out successfully' });
});

// Get details of the logged-in user
app.get('/user', authenticate, async (req, res) => {
  try {
    const result = await dbClient.query('SELECT id, name, email FROM users WHERE id = $1', [req.userId]);
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Send verification email (mock implementation)
app.post('/verify', authenticate, async (req, res) => {
  // Implement email verification logic here
  res.json({ message: 'Verification email sent' });
});

// Send recovery email (mock implementation)
app.post('/recover', async (req, res) => {
  const { email } = req.body;
  // Implement password recovery logic here
  res.json({ message: 'Recovery email sent' });
});

// Continue with Google (mock implementation)
app.post('/oauth/google', async (req, res) => {
  // Implement OAuth2 logic here
  res.json({ message: 'Google OAuth2 not implemented' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

