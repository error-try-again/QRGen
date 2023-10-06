const express = require('express');
const QRCode = require('qrcode');
const cors = require('cors');

const app = express();
const PORT = process.env.BACKEND_PORT || 3000;

app.use(cors());
app.use(express.json());

const generateQR = async (data, size) => {
    const qrCodeOptions = {
        width: parseInt(size),
        height: parseInt(size)
    };
    return QRCode.toDataURL(data, qrCodeOptions);
};

app.post('/generate', async (req, res) => {
    try {
        const { text, url, wifi, email, phone, size } = req.body;
        const data = text || url || wifi || email || phone;
        const qrCodeURL = await generateQR(data, size);
        res.json({ qrCodeURL });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Failed to generate QR Code.' });
    }
});

app.get('/', (req, res) => {
    res.send('Welcome to the QR Code Generator API!');
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
