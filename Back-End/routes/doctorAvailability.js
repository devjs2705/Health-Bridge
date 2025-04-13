const express = require("express");
const router = express.Router();
const db = require("../utils/DB");

// 3️⃣ Get available dates & time slots for a doctor
router.get("/doctorAvailability/:doctorId", async (req, res) => {
    const { doctorId } = req.params;

    if (!doctorId) {
        return res.status(400).json({ message: "Doctor ID is required." });
    }

    try {
        // Fetch available time slots for the given doctor
        const [results] = await db.query(
            "SELECT availability_id, available_date, time_slot FROM doctor_availability WHERE doctor_id = ? AND is_booked = 0 ORDER BY available_date, time_slot",
            [doctorId]
        );

        if (results.length === 0) {
            return res.status(404).json({ message: "No available time slots found for this doctor." });
        }

        // Grouping by date
        const availability = {};
        results.forEach(({ available_date, time_slot, availability_id }) => {
            if (!availability[available_date]) {
                availability[available_date] = [];
            }
            availability[available_date].push({ availability_id, time_slot });
        });

        res.json({ doctorId, availability });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
