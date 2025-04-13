require("dotenv").config();
const mysql = require("mysql2/promise");

// Create a connection pool
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10, // Set an appropriate limit based on your server
    queueLimit: 0,
});

pool.getConnection()
    .then((connection) => {
        console.log("Connected to MySQL database!");
        connection.release(); // Release connection after checking
    })
    .catch((err) => {
        console.error("Database connection failed:", err);
        process.exit(1);
    });

module.exports = pool; // Export the connection pool
