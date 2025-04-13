const express = require("express");
const router = express.Router();
const db = require("../utils/DB");

// 🩺 Get all appointments for a specific doctor
router.get("/appointments/:doctorId", async (req, res) => {
    const doctorId = req.params.doctorId;

    try {
        const [appointments] = await db.query(
            `
            SELECT
                a.appointment_id,
                a.status,
                u.name AS patient_name,
                DATE_FORMAT(da.available_date, '%d %M %Y') AS available_date,
                da.time_slot
            FROM appointments a
            JOIN patients p ON a.patient_id = p.patient_id
            JOIN users u ON p.user_id = u.user_id
            JOIN doctor_availability da ON a.availability_id = da.availability_id
            WHERE a.doctor_id = ?
            ORDER BY da.available_date ASC, da.time_slot ASC
            `,
            [doctorId]
        );

        res.json(appointments);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
