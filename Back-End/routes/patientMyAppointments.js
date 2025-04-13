const express = require("express");
const router = express.Router();
const db = require("../utils/DB");

router.get("/appointments/:patientId", async (req, res) => {
    const { patientId } = req.params;

    try {
        const [appointments] = await db.query(
            `SELECT
                 a.appointment_id,
                 a.status,
                 u.name AS doctor_name,
                 d.specialization,
                 DATE_FORMAT(da.available_date, '%d %M %Y') AS available_date,
                 da.time_slot
             FROM appointments a
             JOIN doctors d ON a.doctor_id = d.doctor_id
             JOIN users u ON d.user_id = u.user_id
             JOIN doctor_availability da ON a.availability_id = da.availability_id
             WHERE a.patient_id = ?
`,
            [patientId]
        );

        res.json(appointments);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
