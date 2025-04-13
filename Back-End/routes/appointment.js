const express = require("express");
const router = express.Router();
const db = require("../utils/DB");

// 1️⃣ Get available doctors by specialization (only active ones)
router.get("/doctors/:specialization", async (req, res) => {
    const { specialization } = req.params;
    try {
        const [doctors] = await db.query(
            "SELECT doctor_id, name FROM doctors JOIN users ON doctors.user_id = users.user_id WHERE specialization = ? AND clock_in_status = 'active'",
            [specialization]
        );
        res.json(doctors);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 2️⃣ Get available time slots for a selected doctor
router.get("/time-slots/:doctorId", async (req, res) => {
    const { doctorId } = req.params;
    try {
        const [timeSlots] = await db.query(
            "SELECT availability_id, available_date, time_slot FROM doctor_availability WHERE doctor_id = ? AND is_booked = 0",
            [doctorId]
        );
        res.json(timeSlots);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
