import rateLimit from "express-rate-limit";

// Define rate limit options for different routes
export const singleQRCodeLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  limit: 100, // Limit each IP to 100 requests per windowMs
});

export const batchQRCodeLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  limit: 10, // Limit each IP to 10 requests per windowMs
});

// Export the rate limiters
export const rateLimiters = {
  singleQRCode: singleQRCodeLimiter,
  batchQRCode: batchQRCodeLimiter,
};
