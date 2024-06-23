
const express = require('express');
const { Client } = require('pg');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const { sendVerificationEmail, sendRecoveryEmail } = require('./mail');
const app = express();
dotenv.config();

const dbClient = new Client({
  connectionString: process.env.DATABASE_URL,
});
dbClient.connect();

app.use(express.json());

// Register a new user
app.post('/register', async (req, res) => {
  const { username, email, password } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await dbClient.query(
      'INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3) RETURNING user_id, username, email',
      [username, email, hashedPassword]
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
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }
    const token = jwt.sign({ userId: user.uder_id }, process.env.JWT_SECRET, { expiresIn: '1h' });
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
    const result = await dbClient.query('SELECT user_id, username, email FROM users WHERE user_id = $1', [req.userId]);
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});



// Send verification email
app.post('/verify', authenticate, async (req, res) => {
  const { email } = req.body;
  try {
    const user = await dbClient.query('SELECT * FROM users WHERE email = $1', [email]);
    if (user.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const verificationToken = jwt.sign({ email: email }, process.env.JWT_SECRET, { expiresIn: '1d' });
    await dbClient.query('UPDATE users SET verification_token = $1 WHERE email = $2', [verificationToken, email]);

    await sendVerificationEmail(email, verificationToken);
    res.json({ message: 'Verification email sent' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


// Send recovery email
app.post('/recover', async (req, res) => {
  const { email } = req.body;
  try {
    const user = await dbClient.query('SELECT * FROM users WHERE email = $1', [email]);
    if (user.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const recoveryToken = jwt.sign({ email: email }, process.env.JWT_SECRET, { expiresIn: '1h' });
    await dbClient.query('UPDATE users SET recovery_token = $1 WHERE email = $2', [recoveryToken, email]);

    await sendRecoveryEmail(email, recoveryToken);
    res.json({ message: 'Recovery email sent' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

// Handle email verification logic
app.post('/verify-email', async (req, res) => {
  const { email, verificationToken } = req.body;
  try {
    // Verify the token
    const decodedToken = jwt.verify(verificationToken, process.env.JWT_SECRET);
    // Update email verification status
    await dbClient.query('UPDATE users SET email_verified = TRUE WHERE email = $1', [email]);
    res.json({ message: 'Email verified successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
