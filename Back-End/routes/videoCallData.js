const express = require("express");
const router = express.Router();
const db = require("../utils/DB");

router.get('/videoCall/:appointmentId', async (req, res) => {
  const appointmentId = req.params.appointmentId;

  try {
    const [rows] = await db.query(
      'SELECT channel_name, doctor_uid, patient_uid FROM appointments WHERE appointment_id = ?',
      [appointmentId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Appointment not found' });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error('Error fetching video call info:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;
