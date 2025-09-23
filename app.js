const express = require('express');
const app = express();
const port = 3000;

// Simple routes
app.get('/', (req, res) => {
  res.send('Hello from monolith!');
});

app.get('/error', (req, res) => {
  res.status(500).send('Something went wrong');
});

// Start server
app.listen(port, () => {
  console.log(`Monolith app listening at http://localhost:${port}`);
});