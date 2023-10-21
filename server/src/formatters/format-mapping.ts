import { RequestTypeMap } from '../ts/types/all-request-types';
import { FormatHandler } from '../ts/types/helper-types';
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
import { formatEmail } from './format-email';
import { formatEvent } from './format-v-calender';
import { formatVCard } from './format-v-card';
import { formatMeCard } from './format-me-card';
import { formatZoom } from './format-zoom.ts';
import { formatWiFi } from './format-wifi.ts';
import { formatURL } from './format-url.ts';
import { formatSMS } from './format-sms.ts';
import { formatText } from './format-text.ts';
import { formatPhone } from './format-phone-number.ts';
import { formatGeoLocation } from './format-geo-location.ts';
import { formatCrypto } from './format-crypto.ts';

export const formatters: {
  [K in keyof RequestTypeMap]: FormatHandler<RequestTypeMap[K]>;
} = {
  Crypto: formatCrypto as FormatHandler<CryptoRequest>,
  Email: formatEmail as FormatHandler<EmailRequest>,
  Event: formatEvent as FormatHandler<EventRequest>,
  GeoLocation: formatGeoLocation as FormatHandler<GeoLocationRequest>,
  MeCard: formatMeCard as FormatHandler<MeCardRequest>,
  Phone: formatPhone as FormatHandler<PhoneRequest>,
  SMS: formatSMS as FormatHandler<SMSRequest>,
  Text: formatText as FormatHandler<TextRequest>,
  Url: formatURL as FormatHandler<UrlRequest>,
  VCard: formatVCard as FormatHandler<VCardRequest>,
  WiFi: formatWiFi as FormatHandler<WifiRequest>,
  Zoom: formatZoom as FormatHandler<ZoomRequest>
};
