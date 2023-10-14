import {RequestTypeMap} from "../ts/types/all-request-types";
import {ValidatorFunction} from "../ts/types/helper-types";

export const validators: {
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
