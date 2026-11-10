import express from 'express';
import cors from 'cors';
import authRoutes from '../routes/authRoutes.js';
import eventRoutes from '../routes/eventRoutes.js';
import organizationRoutes from '../routes/organizationRoutes.js';
import dotenv from 'dotenv';

dotenv.config();

const feAccess = process.env.FRONTEND_ORIGIN || "http://localhost:5173";
const app = express();


app.use(cors({
  origin: feAccess,
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
}));

app.use(express.json());

app.use(['/auth', '/api/auth'], authRoutes);
app.use(['/events', '/api/events'], eventRoutes);
app.use(['/organizations', '/api/organizations'], organizationRoutes);



const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
