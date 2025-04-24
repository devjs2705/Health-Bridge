const express = require("express");
const router = express.Router();
const db = require("../utils/DB");

// POST - Add a medicine reminder
router.post('/medicineReminder', async (req, res) => {
    const { patient_id, medicine_name, shift, before_meal, days } = req.body;

    if (!patient_id || !medicine_name || !shift || !days) {
        return res.status(400).json({ message: "Missing fields" });
    }

    try {
        const query = `
            INSERT INTO medicine_reminders
            (patient_id, medicine_name, shift, before_meal, days)
            VALUES (?, ?, ?, ?, ?)
        `;
        const values = [
            patient_id,
            medicine_name,
            shift,
            before_meal,
            JSON.stringify(days),
        ];

        const [result] = await db.query(query, values);

        res.status(200).json({
            message: "Reminder added successfully",
            reminder_id: result.insertId
        });
    } catch (error) {
        console.error("Error adding reminder:", error);
        res.status(500).json({
            message: "Internal server error",
            error: error.message
        });
    }
});

// GET - Fetch all reminders for a patient
router.get('/medicineReminder/:patientId', async (req, res) => {
    const { patientId } = req.params;
    console.log("medicine Reminder Section.....");
    try {
        const query = `SELECT * FROM medicine_reminders WHERE patient_id = ?`;
        const [results] = await db.query(query, [patientId]);

        const reminders = results.map(reminder => ({
            ...reminder,
            days: JSON.parse(reminder.days)
        }));

        res.status(200).json(reminders);
    } catch (error) {
        console.error("Error fetching reminders:", error);
        res.status(500).json({
            message: "Internal server error",
            error: error.message
        });
    }
});

module.exports = router;