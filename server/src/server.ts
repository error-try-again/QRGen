import express from "express";
import cors from "cors";
import helmet from "helmet";
import { qrCodeRoutes } from "./routes/qr-code-routes";
import { JSON_BODY_LIMIT, ORIGIN, PORT, TRUST_PROXY, USE_SSL } from "./config";
import { rateLimiters } from "./middleware/rate-limiters";
import dotenv from "dotenv";
import http from "node:http";

// Initialize express
const app = express();

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

// Conditional SSL setup
const useSSL = USE_SSL === 'true';

// Function to start HTTPS server
const startHttpsServer = () => {
  import('node:fs')
    .then(fs => {
      import('node:https').then(https => {
        const sslOptions = {
          key: fs.readFileSync('/etc/ssl/certs/privkey.pem'),
          cert: fs.readFileSync('/etc/ssl/certs/cert.pem')
        };

        https.createServer(sslOptions, app).listen(PORT, () => {
          console.log(`HTTPS server running on https://localhost:${PORT}`);
        });
      });
    })
    .catch(error => {
      console.error('Failed to start HTTPS server:', error);
    });
};

// Start server based on SSL configuration
if (useSSL) {
  startHttpsServer();
} else {
  http.createServer(app).listen(PORT, () => {
    console.log(`HTTP server running on http://localhost:${PORT}`);
  });
}
