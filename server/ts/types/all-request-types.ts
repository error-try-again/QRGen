import {
    CryptoRequest,
    EmailRequest, EventRequest,
    GeoLocationRequest, MeCardRequest,
    PhoneRequest,
    SMSRequest,
    TextRequest,
    UrlRequest, VCardRequest, WifiRequest
} from "../interfaces/qr-code-request-types";

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
    | MeCardRequest;


export type RequestTypeMap = {
    'Text': TextRequest,
    'Url': UrlRequest,
    'Email': EmailRequest,
    'Phone': PhoneRequest,
    'SMS': SMSRequest,
    'GeoLocation': GeoLocationRequest,
    'WiFi': WifiRequest,
    'Event': EventRequest,
    'Crypto': CryptoRequest,
    'VCard': VCardRequest,
    'MeCard': MeCardRequest
};
