require("dotenv").config();
const express = require("express");
const app = express();
const authRoute = require("./routes/auth.js")
const setAvailability = require("./routes/setAvailability.js");
const patientMyAppointmentsDoctors = require("./routes/appointment.js");
const doctorTimeSlots = require("./routes/doctorAvailability.js");
const bookAppointment = require("./routes/bookAppointment.js");
const patientMyAppointments = require("./routes/patientMyAppointments.js");
const doctorMyAppointments = require("./routes/doctorMyAppointments.js");
const medicineReminder = require("./routes/medicineReminder.js");
const connectDb = require("./utils/DB.js")
const cors = require("cors")

const corsOptions = {
    origin: "http://localhost:5173",
    methods: "GET, POST, PUT, DELETE, PATCH, HEAD",
    credentials: true,
};

app.use(cors(corsOptions));

app.use(express.json());

app.use("/api/auth", authRoute);

app.use("/api/doctor", setAvailability);
app.use("/api/doctor", doctorMyAppointments);

app.use("/api/patient", patientMyAppointmentsDoctors);
app.use("/api/patient", doctorTimeSlots);
app.use("/api/patient", bookAppointment);
app.use("/api/patient", patientMyAppointments);
app.use("/api/patient", medicineReminder);


const PORT = 5000;

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

