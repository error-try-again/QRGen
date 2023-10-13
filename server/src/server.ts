import express, {Response} from 'express';
import QRCode from 'qrcode';
import archiver from 'archiver';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import {
    CryptoRequest,
    EmailRequest,
    EventRequest, GeoLocationRequest,
    MeCardRequest, PhoneRequest, SMSRequest,
    TextRequest, UrlRequest,
    VCardRequest, WifiRequest
} from "./ts/interfaces/qr-code-request-types";
import {AllRequests, RequestTypeMap} from "./ts/types/all-request-types";
import {formatDatetime} from "./util/format-date-time";

const app = express();
const PORT = 3001;
const TRUST_PROXY = 1;
const JSON_LIMIT = '1mb';
const ORIGIN = 'http://localhost:8080';

const MAX_QR_CODES = 100;
const DEFAULT_QR_SIZE = 150;

// Middleware Setup
app.set('trust proxy', TRUST_PROXY);
app.use(helmet(), cors({origin: ORIGIN, optionsSuccessStatus: 200}), express.json({limit: JSON_LIMIT}));

app.use(express.json());

app.use('/generate', rateLimit({windowMs: 15 * 60 * 1000, limit: 100}));
app.use('/batch', rateLimit({windowMs: 15 * 60 * 1000, limit: 10}));

console.log('Server started.');

// Global Error Handling
for (const event of ['unhandledRejection', 'uncaughtException']) {
    process.on(event, (error, promise) =>
        console.error(`${event} at:`, promise ?? error, 'reason:', error ?? promise)
    );
}

// Define necessary interfaces
interface BaseQRData {
    type: string;
    size?: number;
}

interface QRData<T = {
    [key: string]: string | number | boolean | undefined;
}> extends BaseQRData {
    customData: T;
}


interface ProcessedQRData<T> extends QRData<T> {
    qrCodeData: string;
}

type ValidatorFunction<T extends AllRequests> = (data: T) => boolean;

type FormatHandler<T extends AllRequests> = (data: T) => string;


const validators: {
    [K in keyof RequestTypeMap]: ValidatorFunction<RequestTypeMap[K]>
} = {
    'Text': data => Boolean(data.text),
    'Url': data => Boolean(data.url),
    'Email': data => Boolean(data.email),
    'Phone': data => Boolean(data.phone),
    'SMS': data => Boolean(data.phone && data.sms),
    'GeoLocation': data => Boolean(data.latitude && data.longitude),
    'WiFi': data => Boolean(data.ssid && data.encryption),
    'Event': data => Boolean(data.venue && data.startTime && data.endTime),
    'Crypto': data => Boolean(data.cryptoType && data.address),
    'VCard': data => Boolean(data.firstName && data.lastName),
    'MeCard': data => Boolean(data.firstName && data.lastName)
};


const formatEmail = (data: EmailRequest): string => {
    const mailtoString = `mailto:${data.email}?`;
    const parameters = new URLSearchParams();

    if (data.subject) {
        parameters.set('subject', data.subject);
    }
    if (data.body) {
        parameters.set('body', data.body);
    }
    if (data.cc) {
        parameters.set('cc', data.cc);
    }
    if (data.bcc) {
        parameters.set('bcc', data.bcc);
    }

    return mailtoString + parameters.toString();
};

const formatEvent = (data: EventRequest): string => [
    "BEGIN:VCALENDAR",
    "VERSION:2.0",
    "BEGIN:VEVENT",
    `SUMMARY:${data.venue}`,
    `DTSTART:${formatDatetime(data.startTime!)}`, //! is used to tell TS that startTime is not null or undefined
    `DTEND:${formatDatetime(data.endTime!)}`,
    "END:VEVENT",
    "END:VCALENDAR"
].join('\n');

const formatVCard = (data: VCardRequest): string => [
    "BEGIN:VCARD",
    `VERSION:${data.version === '3.0' ? '3.0' : '2.1'}`,
    `N:${data.lastName};${data.firstName}`,
    data.organization && `ORG:${data.organization}`,
    data.position && `TITLE:${data.position}`,
    data.phoneWork && `TEL;WORK:${data.phoneWork}`,
    data.phonePrivate && `TEL;HOME:${data.phonePrivate}`,
    data.phoneMobile && `TEL;CELL:${data.phoneMobile}`,
    data.faxWork && `TEL;WORK;FAX:${data.faxWork}`,
    data.faxPrivate && `TEL;HOME;FAX:${data.faxPrivate}`,
    data.email && `EMAIL:${data.email}`,
    data.website && `URL:${data.website}`,
    data.street && `ADR:;;${data.street};${data.city};${data.state};${data.zipcode};${data.country}`,
    "END:VCARD"
].filter(Boolean).join('\n');

const formatMeCard = (data: MeCardRequest): string => [
    "MECARD:N:",
    `${data.lastName},${data.firstName}`,
    data.nickname && `NICKNAME:${data.nickname}`,
    data.phone1 && `TEL:${data.phone1}`,
    data.phone2 && `TEL:${data.phone2}`,
    data.phone3 && `TEL:${data.phone3}`,
    data.email && `EMAIL:${data.email}`,
    data.website && `URL:${data.website}`,
    data.birthday && `BDAY:${data.birthday}`,
    data.street && `ADR:${data.street},${data.city},${data.state},${data.zipcode},${data.country}`,
    data.notes && `NOTE:${data.notes}`
].filter(Boolean).join(';');

const formatters: { [K in keyof RequestTypeMap]: FormatHandler<RequestTypeMap[K]> } = {
    'Text': (data: TextRequest) => data.text ?? "",
    'Url': (data: UrlRequest) => data.url ?? "",
    'Email': formatEmail as FormatHandler<EmailRequest>,
    'Phone': (data: PhoneRequest) => `tel:${data.phone}`,
    'SMS': (data: SMSRequest) => `sms:${data.phone}?body=${data.sms}`,
    'GeoLocation': (data: GeoLocationRequest) => `geo:${data.latitude},${data.longitude}`,
    'WiFi': (data: WifiRequest) => `WIFI:T:${data.encryption};S:${data.ssid};P:${data.password};H:${data.hidden ? 1 : 0};`,
    'Event': formatEvent as FormatHandler<EventRequest>,
    'Crypto': (data: CryptoRequest) => `${data.cryptoType}:${data.address}?amount=${data.amount ?? ''}`,
    'VCard': formatVCard as FormatHandler<VCardRequest>,
    'MeCard': formatMeCard as FormatHandler<MeCardRequest>
};


// Helper functions
const sanitizeInput = <T>(input: T): T => typeof input === 'string'
    ? input.replaceAll(/[^\d\s,./:@A-Za-z-]/g, '') as unknown as T
    : input;

const handleDataTypeSwitching = <T extends AllRequests>(type: string, data: T): string => {
    if (!Object.keys(formatters).includes(type)) {
        throw new Error("Invalid type provided.");
    }
    return formatters[type as keyof RequestTypeMap](sanitizeInput(data));
};

const validateData = <T extends AllRequests>(data: QRData<T>, type: string): void => {
    if (!data || !data.customData) {
        throw new Error(`Missing data for type: ${type}`);
    }
    if (!validators[type as keyof RequestTypeMap](data.customData)) {
        throw new Error(`Invalid data for type: ${type}`);
    }
};


const generateQR = async (data: string, size: string | number): Promise<string> => {

    let parsedSize = Number(size);

    if (Number.isNaN(parsedSize) || parsedSize < 50 || parsedSize > 1000) {
        console.log(`Invalid size: ${size}. Using default size: ${DEFAULT_QR_SIZE}`);
        parsedSize = DEFAULT_QR_SIZE;
    }

    const scale = parsedSize / DEFAULT_QR_SIZE;  // default scale produces a QR code of DEFAULT_SIZE x DEFAULT_SIZE

    return QRCode.toDataURL(data, {
        scale: scale,
        type: 'image/png'
    });

};

const processSingleQRCode = async <T extends AllRequests>(qrData: QRData<T>): Promise<ProcessedQRData<T>> => {
    console.log("Received data:", qrData);
    validateData(qrData, qrData.type);

    const {type, size, customData} = qrData;
    const sanitizedData = handleDataTypeSwitching(type, customData);

    const qrCodeData = await generateQR(sanitizedData, size ?? DEFAULT_QR_SIZE);
    return {...qrData, qrCodeData};
};


const validateBatchData = (qrCodes: QRData[], response: Response) => {
    if (!Array.isArray(qrCodes) || qrCodes.length === 0) {
        return response.status(400).json({message: 'Invalid batch data. Must be a non-empty array.'});
    }

    const uniqueData = new Set(qrCodes.map((element) => JSON.stringify(element)));

    if (uniqueData.size !== qrCodes.length) {
        return response.status(400).json({message: 'Invalid batch data. Duplicate entries detected.'});
    }

    if (qrCodes.length > MAX_QR_CODES) {
        return response.status(400).json({message: `Invalid batch data. Maximum number of entries is ${MAX_QR_CODES}.`});
    }

    for (const qrCode of qrCodes) {
        try {
            validateData(qrCode, qrCode.type);
        } catch (error) {
            console.log(error);
            return response.status(400).json({message: `Invalid data for type: ${qrCode.type}`});
        }
    }

    return response.status(200).json({message: 'Batch data validated.'});
};


const generateQRCodesForBatch = async (qrCodes: QRData[]): Promise<ProcessedQRData<AllRequests>[]> => {
    return await Promise.all(qrCodes.map((element) => processSingleQRCode(element)));
};

// Routes
app.post('/generate', async (request, response) => {
    if (!request.body || !request.body.type) {
        return response.status(400).json({message: "Invalid request data."});
    }
    try {
        const processedQRCode = await processSingleQRCode(request.body);
        return response.json({qrCodeURL: processedQRCode.qrCodeData});
    } catch (error) {
        console.error(error);
        return response.status(500).json({message: "Internal server error on QR code generation."});
    }
});

app.post('/batch', async (request, response) => {
    try {
        const {qrCodes} = request.body;

        validateBatchData(qrCodes, response);

        // Guard against sending multiple responses in case of error
        if (response.headersSent) {
            return;
        }

        // Generate QR codes for each data item in the batch
        const qrCodesWithSanitizedData = await generateQRCodesForBatch(qrCodes);

        try {
            const archive = archiver('zip');

            archive.on('error', (error) => {
                response.status(500).send({error: error.message});
            });

            const dateStamp = new Date().toISOString().slice(0, 10);

            response.setHeader('Content-Type', 'application/zip');
            response.setHeader('Content-Disposition', `attachment; filename=qrBatch_${dateStamp}.zip`);

            archive.pipe(response);

            try {
                let index = 0;

                if (qrCodesWithSanitizedData) {
                    for (const qrCode of qrCodesWithSanitizedData) {
                        const buffer = Buffer.from(qrCode.qrCodeData.split(',')[1], 'base64');
                        const fileName = `${qrCode.type}_${index}.png`;
                        archive.append(buffer, {name: fileName});
                        index++;
                    }

                    await archive.finalize();
                } else {
                    response.status(500).json({message: 'Trouble generating QR codes.'});
                }

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


// Friendly welcome message
app.get('/', (request: any, response: any) => {
    if (request.query.name) {
        response.send(`Hello ${request.query.name}!`);
    }
    response.send('Hello World!');
});

// Start server
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
