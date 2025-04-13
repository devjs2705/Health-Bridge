const express = require("express");
const router = express.Router();
const db = require("../utils/DB");

// 1️⃣ Add availability for a doctor
// 1️⃣ Add availability for a doctor
router.post("/setAvailability", async (req, res) => {
    const { doctorId, availableDate, timeSlots } = req.body;

    if (!doctorId || !availableDate || !Array.isArray(timeSlots) || timeSlots.length === 0) {
        return res.status(400).json({ message: "All fields are required." });
    }

    try {
        // Insert multiple time slots for the doctor
        const values = timeSlots.map(slot => [doctorId, availableDate, slot, 0]); // is_booked = 0
        await db.query(
            "INSERT INTO doctor_availability (doctor_id, available_date, time_slot, is_booked) VALUES ?",
            [values]
        );

        // ✅ Set clock_in_status to 'active'
        await db.query(
            "UPDATE doctors SET clock_in_status = 'active' WHERE doctor_id = ?",
            [doctorId]
        );

        res.status(201).json({ message: "Availability set successfully! Doctor is now active." });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


// 2️⃣ Update availability (mark as booked or free)
router.patch("/updateAvailability", async (req, res) => {
    const { availabilityId, isBooked } = req.body;

    if (!availabilityId || typeof isBooked !== "boolean") {
        return res.status(400).json({ message: "Invalid request data." });
    }

    try {
        await db.query(
            "UPDATE doctor_availability SET is_booked = ? WHERE availability_id = ?",
            [isBooked ? 1 : 0, availabilityId]
        );

        res.json({ message: "Availability updated successfully!" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
