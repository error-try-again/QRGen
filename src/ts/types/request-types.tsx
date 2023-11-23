import {
    CryptoRequest,
    EmailRequest,
    EventRequest,
    GeoLocationRequest,
    MeCardRequest,
    PhoneRequest,
    SMSRequest,
    TextRequest,
    UrlRequest,
    VCardRequest,
    WifiRequest, ZoomRequest
} from "../interfaces/qr-code-request-interfaces.tsx";

export type AllRequests =
    | TextRequest
    | UrlRequest
    | EmailRequest
    | PhoneRequest
    | SMSRequest
    | GeoLocationRequest
    | WifiRequest
    | EventRequest
    | CryptoRequest
    | VCardRequest
    | MeCardRequest
    | ZoomRequest;

export type RequestTypeMap = {
    Text: TextRequest;
    Url: UrlRequest;
    Email: EmailRequest;
    Phone: PhoneRequest;
    SMS: SMSRequest;
    GeoLocation: GeoLocationRequest;
    WiFi: WifiRequest;
    Event: EventRequest;
    Crypto: CryptoRequest;
    VCard: VCardRequest;
    MeCard: MeCardRequest;
    Zoom: ZoomRequest;
};

export type FormatHandler<T extends AllRequests> = (data: T) => string;
