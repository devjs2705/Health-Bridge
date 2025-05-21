const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  // Instead of redirecting, return a response
  res.json({
    message: 'Chatbot is ready!',
    url: 'http://127.0.0.1:7860'  // This is the URL your frontend can use
  });
});

module.exports = router;
