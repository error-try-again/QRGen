import { formatEmail } from './format-email.tsx';
import { formatEvent } from './format-v-calender.tsx';
import { formatVCard } from './format-v-card.tsx';
import { formatMeCard } from './format-me-card.tsx';
import { formatZoom } from './format-zoom.tsx';
import { formatWiFi } from './format-wifi.tsx';
import { formatURL } from './format-url.tsx';
import { formatSMS } from './format-sms.tsx';
import { formatText } from './format-text.tsx';
import { formatPhone } from './format-phone-number.tsx';
import { formatGeoLocation } from './format-geo-location.tsx';
import { formatCrypto } from './format-crypto.tsx';
import {FormatHandler, RequestTypeMap} from "../ts/types/request-types.tsx";

import {
  CryptoRequest,
  EmailRequest,
  EventRequest,
  GeoLocationRequest,
  MeCardRequest,
  PhoneRequest,
  SMSRequest, TextRequest, UrlRequest, VCardRequest, WifiRequest, ZoomRequest
} from "../ts/interfaces/qr-code-request-interfaces.tsx";

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
