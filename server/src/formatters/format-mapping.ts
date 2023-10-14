import {RequestTypeMap} from "../ts/types/all-request-types";
import {FormatHandler} from "../ts/types/helper-types";
import {
    CryptoRequest,
    EmailRequest, EventRequest, GeoLocationRequest, MeCardRequest,
    PhoneRequest,
    SMSRequest,
    TextRequest,
    UrlRequest, VCardRequest, WifiRequest
} from "../ts/interfaces/qr-code-request-interfaces";
import {formatEmail} from "./format-email";
import {formatEvent} from "./format-v-calender";
import {formatVCard} from "./format-v-card";
import {formatMeCard} from "./format-me-card";

export const formatters: { [K in keyof RequestTypeMap]: FormatHandler<RequestTypeMap[K]> } = {
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
