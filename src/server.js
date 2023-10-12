const express = require('express');
const QRCode = require('qrcode');
const cors = require('cors');
const archiver = require('archiver');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');


const app = express();
const PORT = 3001;
const MAX_QR_CODES = 50;

// Middleware Setup

// Trust first proxy
app.set('trust proxy', 1);

// Trust application at localhost:8080
const corsOptions = {
    origin: 'localhost:8080',
    optionsSuccessStatus: 200
};

app.use(cors(corsOptions)); // Enable CORS with options


app.use(express.json({limit: '1mb'}));  // Parse incoming JSON request bodies and limit to 1mb

app.use('/generate', rateLimit({windowMs: 15 * 60 * 1000, max: 100})); // Limit to 100 requests per 15 minutes
app.use('/batch', rateLimit({windowMs: 15 * 60 * 1000, max: 10})); // Limit to 10 requests per 15 minutes

app.use(helmet()); // Set security-related HTTP headers

// Handle unhandled promise rejections globally
process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});


// Definitions for Validators and Required Fields
const requiredFieldsForTab = {
    'Text': ['text'],
    'Url': ['url'],
    'Email': ['email', 'subject', 'body'],
    'Phone': ['phone'],
    'WiFi': ['ssid', 'encryption'],
    'SMS': ['phone', 'sms'],
    'Event': ['event', 'venue', 'startTime', 'endTime'],
    'GeoLocation': ['latitude', 'longitude'],
    'Crypto': ['cryptoType', 'address', 'amount'],
};

const cryptoValidators = {
    'Bitcoin': /^([13][a-km-zA-HJ-NP-Z1-9]{25,34})$/,
    'Bitcoin Cash': /^([13][a-km-zA-HJ-NP-Z1-9]{25,34})$/,
    'Ethereum': /^0x[a-fA-F0-9]{40}$/,
    'Litecoin': /^([LM3][a-km-zA-HJ-NP-Z1-9]{26,33})$/,
    'Dash': /^X[1-9A-HJ-NP-Za-km-z]{33}$/,
    'Doge': /^D{1}[5-9A-HJ-NP-U]{1}[1-9A-HJ-NP-Za-km-z]{32}$/
};

const validators = {
    'Crypto': (data) => data.cryptoType in cryptoValidators && cryptoValidators[data.cryptoType].test(data.address),
    'Email': (data) => /\S+@\S+\.\S+/.test(data.email),
    'Event': (data) => !isNaN(new Date(data.startTime).getTime()) && !isNaN(new Date(data.endTime).getTime()),
    'GeoLocation': (data) => {
        const latitude = parseFloat(data.latitude);
        const longitude = parseFloat(data.longitude);
        return !isNaN(latitude) && latitude >= -90 && latitude <= 90 && !isNaN(longitude) && longitude >= -180 && longitude <= 180;
    },
    'Phone': (data) => /^(\+?(\d{1,3}))?(\d{5,15})$/.test(data.phone),
    'SMS': (data) => data.phone && data.sms,
    'Text': (data) => !!data.text,
    'Url': (data) => /^https?:\/\//i.test(data.url),
    'WiFi': (data) => data.ssid && data.encryption
};

// Definitions for Validators and Required Fields
const formatDatetime = (dateString) => new Date(dateString).toISOString().replace(/-|:/g, '').split('.')[0];
const createVCalendar = (venue, startTime, endTime) => {
    return [
        "BEGIN:VCALENDAR",
        "VERSION:2.0",
        "BEGIN:VEVENT",
        "SUMMARY:" + venue,
        "LOCATION:" + venue,
        "DTSTART:" + formatDatetime(startTime),
        "DTEND:" + formatDatetime(endTime),
        "END:VEVENT",
        "END:VCALENDAR"
    ].join('\n');
};

// Sanitize input to prevent XSS
const sanitizeInput = (input) => {
    // Allow alphanumeric, whitespace, hyphen, dot, @, colon, and forward slash.
    return input.replace(/[^\w\s-.@:/]/gi, '');
};

// Data Type Switching
const handleDataTypeSwitching = (type, rest) => {
    function handleMailFormat() {
        if (rest.body && rest.subject) {
            return `mailto:${sanitizeInput(rest.email)}?subject=${sanitizeInput(rest.subject)}&body=${sanitizeInput(rest.body)}`;
        } else if (rest.subject) {
            return `mailto:${sanitizeInput(rest.email)}?subject=${sanitizeInput(rest.subject)}`;
        } else if (rest.body) {
            return `mailto:${sanitizeInput(rest.email)}?body=${sanitizeInput(rest.body)}`;
        } else {
            return `mailto:${sanitizeInput(rest.email)}`;
        }
    }

    function handleCryptoFormat() {
        if (rest.amount) {
            return `${sanitizeInput(rest.cryptoType)}:${sanitizeInput(rest.address)}?amount=${sanitizeInput(rest.amount)}`;
        } else {
            return `${sanitizeInput(rest.cryptoType)}:${sanitizeInput(rest.address)}`;
        }
    }

    function handleWifiFormat() {
        return `WIFI:T:${sanitizeInput(rest.encryption)};S:${sanitizeInput(rest.ssid)};P:${sanitizeInput(rest.password)};;`;
    }

    function handleGeoLocationFormat() {
        return `geo:${sanitizeInput(rest.latitude)},${sanitizeInput(rest.longitude)}`;
    }

    function handleSMSFormat() {
        return `SMSTO:${sanitizeInput(rest.phone)}:${sanitizeInput(rest.sms)}`;
    }

    function handleTelephoneFormat() {
        return `tel:${sanitizeInput(rest.phone)}`;
    }

    function handleURLFormat() {
        return sanitizeInput(rest.url);
    }

    function handleTextFormat() {
        return sanitizeInput(rest.text);
    }

    function handleEventFormat() {
        return createVCalendar(sanitizeInput(rest.venue), sanitizeInput(rest.startTime), sanitizeInput(rest.endTime));
    }

    switch (type) {
        case 'Text':
            return handleTextFormat();
        case 'Url':
            return handleURLFormat();
        case 'Email':
            return handleMailFormat();
        case 'Phone':
            return handleTelephoneFormat();
        case 'SMS':
            return handleSMSFormat();
        case 'GeoLocation':
            return handleGeoLocationFormat();
        case 'WiFi':
            return handleWifiFormat();
        case 'Crypto':
            return handleCryptoFormat();
        case 'Event':
            return handleEventFormat();
        default:
            return '';
    }
};

const validateData = (data, type) => {
    if (!(type in validators)) {
        throw new Error(`Unsupported type: ${type}`);
    }

    if (!validators[type](data)) {
        throw new Error(`Invalid data for type: ${type}`);
    }
};

const validateBatchData = (qrCodes, response) => {
    if (!Array.isArray(qrCodes) || qrCodes.length === 0) {
        return response.status(400).json({message: 'Invalid batch data. Must be a non-empty array.'});
    }

    const uniqueData = new Set(qrCodes.map(JSON.stringify));

    if (uniqueData.size !== qrCodes.length) {
        return response.status(400).json({message: 'Invalid batch data. Duplicate entries detected.'});
    }

    if (qrCodes.length > MAX_QR_CODES) {
        return response.status(400).json({message: `Invalid batch data. Maximum number of entries is ${MAX_QR_CODES}.`});
    }

    for (let i = 0; i < qrCodes.length; i++) {
        try {
            validateData(qrCodes[i], qrCodes[i].type);
        } catch (error) {
            console.log(error);
            return response.status(400).json({message: `Invalid data for type: ${qrCodes[i].type}`});
        }
    }
};


// Generate QR
const generateQR = async (data, size) => {
    const defaultSize = 150;
    let parsedSize = parseInt(size);

    if (isNaN(parsedSize) || parsedSize < 50 || parsedSize > 1000) {
        console.log(`Invalid size: ${size}. Using default size: ${defaultSize}`);
        parsedSize = defaultSize;
    }

    const qrCodeOptions = {
        width: parsedSize,
        height: parsedSize,
        type: 'image/png' // Enforce PNG type
    };

    return QRCode.toDataURL(data, qrCodeOptions);
};

const processSingleQRCode = async (data) => {
    const {type, ...rest} = data;
    validateData(rest, type);
    const sanitizedData = handleDataTypeSwitching(type, rest);
    const qrCodeData = await generateQR(sanitizedData, rest.size);
    return {...data, sanitizedData, qrCodeData};
};

const generateQRCodesForBatch = async (qrCodes, response) => {
    try {
        return await Promise.all(qrCodes.map(processSingleQRCode));
    } catch (error) {
        console.error(error);
        response.status(400).json({message: error.message});
    }
};

// Routes

// Not Currently In Use
app.post('/validate', (req, response) => {
    const {type, ...rest} = req.body;
    try {
        validateData(rest, type);
        response.status(200).send({message: 'Validation passed.'});
    } catch (error) {
        response.status(400).json({message: error.message});
    }
});

app.post('/generate', async (req, res) => {
    try {
        const processedQRCode = await processSingleQRCode(req.body);
        res.json({qrCodeURL: processedQRCode.qrCodeData});
    } catch (err) {
        console.error(err);
        res.status(500).json({message: err.message});
    }
});


app.post('/batch', async (req, response) => {
    try {
        const qrCodes = req.body.qrCodes;

        validateBatchData(qrCodes, response);

        // Guard against sending multiple responses in case of error
        if (response.headersSent) {
            return;
        }

        // Generate QR codes for each data item in the batch
        const qrCodesWithSanitizedData = await generateQRCodesForBatch(qrCodes, response);

        try {
            const archive = archiver('zip');

            archive.on('error', (err) => {
                response.status(500).send({error: err.message});
            });

            const dateStamp = new Date().toISOString().slice(0, 10);

            response.setHeader('Content-Type', 'application/zip');
            response.setHeader('Content-Disposition', `attachment; filename=qrBatch_${dateStamp}.zip`);

            archive.pipe(response);

            try {
                let index = 0;

                for (const qrCode of qrCodesWithSanitizedData) {
                    const buffer = Buffer.from(qrCode.qrCodeData.split(',')[1], 'base64');
                    const fileName = `${qrCode.type}_${index}.png`;
                    archive.append(buffer, {name: fileName});
                    index++;
                }

                archive.finalize();
            } catch (error) {
                console.error(error);
                response.status(500).json({message: 'Trouble appending files to archive.'});
            }

        } catch (error) {
            console.error(error);
            response.status(500).json({message: 'Trouble setting headers.'});
        }


    } catch (error) {
        console.error(error);
        response.status(500).json({message: 'Internal server error on batch generation.'});
    }
});


// Handle any server errors that slip though
app.use((err, req, response) => {
    console.error(err.stack);
    response.status(500).json({message: 'Internal server error'});
});

// Friendly welcome message
app.get('/', (req, response) => {
    response.send('Welcome to the QR Code Generator API!');
});

// Start server
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
