import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import {qrCodeRoutes} from "./routes/qr-code-routes";
import {JSON_BODY_LIMIT, ORIGIN, PORT, TRUST_PROXY} from "./config";
import {rateLimiters} from "./middleware/rate-limiters";

// Initialize express
export const app = express();

// Middleware Setup
app.set('trust proxy', TRUST_PROXY);
app.use(helmet(), cors({origin: ORIGIN, optionsSuccessStatus: 200}), express.json({limit: JSON_BODY_LIMIT}));
app.use('/generate', rateLimiters.singleQRCode);
app.use('/batch', rateLimiters.batchQRCode);

// Routes
app.use('/qr', qrCodeRoutes);

// Global Error Handling
for (const event of ['unhandledRejection', 'uncaughtException']) {
    process.on(event, (error, promise) =>
        console.error(`${event} at:`, promise ?? error, 'reason:', error ?? promise)
    );
}

// Start server
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
