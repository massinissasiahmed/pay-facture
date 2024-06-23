const nodemailer = require('nodemailer');

// Configure nodemailer transporter
const transporter = nodemailer.createTransport({
  service: 'gmail', 
  auth: {
    user: 'email@gmail.com', 
    pass: '', 
  },
});

// Function to send verification email
const sendVerificationEmail = (email, token) => {
  const mailOptions = {
    from: 'email@gmail.com', // Replace with your email
    to: email,
    subject: 'Email Verification',
    text: `Please verify your email by clicking on the following link: http://example.com/verify?token=${token}`, // Customize this
  };

  return transporter.sendMail(mailOptions);
};

// Function to send recovery email
const sendRecoveryEmail = (email, token) => {
  const mailOptions = {
    from: 'your-email@gmail.com', // Replace with your email
    to: email,
    subject: 'Password Recovery',
    text: `You can recover your password by clicking on the following link: http://example.com/recover?token=${token}`, // Customize this
  };

  return transporter.sendMail(mailOptions);
};

module.exports = {
  sendVerificationEmail,
  sendRecoveryEmail,
};
