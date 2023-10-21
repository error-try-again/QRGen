import { RequestTypeMap } from '../ts/types/all-request-types';

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
  WifiRequest,
  ZoomRequest
} from '../ts/interfaces/qr-code-request-interfaces';

export type ValidatorFunction<T> = (data: T) => boolean;

export const validators: {
  [K in keyof RequestTypeMap]: ValidatorFunction<RequestTypeMap[K]>;
} = {
  Crypto: ({ address, cryptoType }: CryptoRequest) =>
    Boolean(cryptoType && address),
  Email: ({ email }: EmailRequest) => Boolean(email),
  Event: ({ endTime, startTime, venue }: EventRequest) =>
    Boolean(venue && startTime && endTime),
  GeoLocation: ({ latitude, longitude }: GeoLocationRequest) =>
    Boolean(latitude && longitude),
  Phone: (data: PhoneRequest) => Boolean(data.phone),
  SMS: ({ phone, sms }: SMSRequest) => Boolean(phone && sms),
  Text: ({ text }: TextRequest) => Boolean(text),
  Url: ({ url }: UrlRequest) => Boolean(url),
  VCard: ({ version, firstName, lastName, email, phoneWork }: VCardRequest) =>
    Boolean(version && firstName && lastName && email && phoneWork),
  MeCard: ({ firstName, lastName, phone1 }: MeCardRequest) =>
    Boolean(firstName && lastName && phone1),
  WiFi: ({ encryption, ssid }: WifiRequest) => Boolean(ssid && encryption),
  Zoom: ({ zoomId, zoomPass }: ZoomRequest) => Boolean(zoomId && zoomPass)
};
