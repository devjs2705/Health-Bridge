const express = require("express");
const router = express.Router();
const db = require("../utils/DB");

// 4️⃣ Book an appointment
router.post("/bookAppointment", async (req, res) => {
    const { patientId, doctorId, availabilityId } = req.body;

    if (!patientId || !doctorId || !availabilityId) {
        return res.status(400).json({ message: "All fields are required." });
    }

    const connection = await db.getConnection();
    try {
        await connection.beginTransaction(); // Start transaction

        // Insert appointment record (without appointment_date)
        await connection.query(
            "INSERT INTO appointments (doctor_id, patient_id, availability_id, status) VALUES (?, ?, ?, ?)",
            [doctorId, patientId, availabilityId, "Booked"]
        );

        // Mark the selected time slot as booked
        await connection.query(
            "UPDATE doctor_availability SET is_booked = 1 WHERE availability_id = ?",
            [availabilityId]
        );

        // Check if all time slots for this doctor are booked
        const [remainingSlots] = await connection.query(
            "SELECT COUNT(*) AS count FROM doctor_availability WHERE doctor_id = ? AND is_booked = 0",
            [doctorId]
        );

        if (remainingSlots[0].count === 0) {
            // If no slots are available, mark doctor as inactive
            await connection.query(
                "UPDATE doctors SET clock_in_status = 'inActive' WHERE doctor_id = ?",
                [doctorId]
            );
        }

        await connection.commit(); // Commit transaction
        res.status(201).json({ message: "Appointment booked successfully!" });
    } catch (error) {
        await connection.rollback(); // Rollback in case of error
        res.status(500).json({ error: error.message });
    } finally {
        connection.release(); // Release connection
    }
});

module.exports = router;
