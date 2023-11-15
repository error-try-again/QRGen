import express from "express";
import cors from "cors";
import helmet from "helmet";
import { qrCodeRoutes } from "./routes/qr-code-routes";
import { JSON_BODY_LIMIT, ORIGIN, PORT, TRUST_PROXY } from "./config";
import { rateLimiters } from "./middleware/rate-limiters";
import dotenv from "dotenv";
import fs from "node:fs";
import https from "node:https";

// Initialize express
export const app = express();

// Initialize dotenv
dotenv.config({ path: './.env' });

// Middleware Setup
app.set('trust proxy', TRUST_PROXY);
app.use(
  helmet(),
  cors({ origin: ORIGIN, optionsSuccessStatus: 200 }),
  express.json({ limit: JSON_BODY_LIMIT })
);

app.use('/generate', rateLimiters.singleQRCode);
app.use('/batch', rateLimiters.batchQRCode);

// Routes
app.use('/qr', qrCodeRoutes);

// Define SSL/TLS options
const sslOptions = {
  key: fs.readFileSync('/etc/ssl/certs/privkey.pem'),
  cert: fs.readFileSync('/etc/ssl/certs/cert.pem')
};

// Start HTTPS server
https.createServer(sslOptions, app).listen(PORT, () => {
  console.log(`Server running on https://localhost:${PORT}`);
});
