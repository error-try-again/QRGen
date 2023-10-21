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
import { formatZoom } from './format-zoom';
import { formatWiFi } from './format-wifi';
import { formatURL } from './format-url';
import { formatSMS } from './format-sms';
import { formatText } from './format-text';
import { formatPhone } from './format-phone-number';
import { formatGeoLocation } from './format-geo-location';
import { formatCrypto } from './format-crypto';

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
