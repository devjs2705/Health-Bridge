const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
require("dotenv").config();
const db = require("../utils/DB"); // Importing the database pool

const SPECIALIZATIONS = [
  "ENT", "General Physician", "Cardiologist", "Pediatrician", "Dermatologist", "Orthopedist"
];

// User Registration
router.post("/register", async (req, res) => {
  const { email, password, role, name } = req.body;

  if (!email || !password || !role || !name) {
    return res.status(400).json({ message: "All fields are required." });
  }

  let connection;
  try {
    connection = await db.getConnection(); // Get a connection from the pool
    await connection.beginTransaction(); // Start transaction

    // Check if email already exists
    const [existingUser] = await connection.execute("SELECT * FROM users WHERE email = ?", [email]);
    if (existingUser.length > 0) {
      await connection.rollback();
      return res.status(400).json({ message: "Email already registered." });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    const [userResult] = await connection.execute(
      "INSERT INTO users (email, password, role, name) VALUES (?, ?, ?, ?)",
      [email, hashedPassword, role, name]
    );
    const userId = userResult.insertId;

    if (role === "patient") {
      // Insert into patients table
      await connection.execute(
        "INSERT INTO patients (user_id) VALUES (?)",
        [userId]
      );
    } else if (role === "doctor") {
      const specialization = SPECIALIZATIONS[Math.floor(Math.random() * SPECIALIZATIONS.length)];
      await connection.execute(
        "INSERT INTO doctors (user_id, specialization) VALUES (?, ?)",
        [userId, specialization]
      );
    }

    await connection.commit(); // Commit transaction
    res.status(201).json({ message: "User registered successfully!" });
  } catch (error) {
    if (connection) await connection.rollback(); // Rollback on error
    res.status(500).json({ error: error.message });
  } finally {
    if (connection) connection.release(); // Release connection
  }
});

// User Login
router.post("/login", async (req, res) => {
  const { email, password, role } = req.body; // Accept role from frontend

  let connection;
  try {
    connection = await db.getConnection();

    // Fetch user by email
    const [results] = await connection.execute(
      "SELECT * FROM users WHERE email = ?",
      [email]
    );

    if (results.length === 0) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const user = results[0];

    // ✅ Check if role matches
    if (user.role !== role) {
      return res.status(403).json({ message: `You are registered as a ${user.role}. Please select the correct role.` });
    }

    // ✅ Check password
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    // ✅ Generate JWT
    const token = jwt.sign(
      { userId: user.user_id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    // Get Patient Id of Doctor Id
    if(role == 'patient')
    {
        const [patientRows] = await db.query(
                'SELECT patient_id FROM patients WHERE user_id = ?',
                [user.user_id]
              );

        const patientId = patientRows[0].patient_id;

        res.json({token, user, patientId});
    }
    else
    {
        const [doctorRows] = await db.query(
                        'SELECT doctor_id FROM doctors WHERE user_id = ?',
                        [user.user_id]
                      );

        const doctorId = doctorRows[0].doctor_id;

        res.json({token, user, doctorId});
    }
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Something went wrong" });
  } finally {
    if (connection) connection.release();
  }
});


module.exports = router;
