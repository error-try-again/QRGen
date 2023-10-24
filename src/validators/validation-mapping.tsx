import { Tabs } from '../ts/enums/tabs-enum';
import { isValidPhoneNumber } from '../utils/is-valid-phone.tsx';
import { QRCodeGeneratorState } from '../ts/interfaces/qr-code-generator-state.tsx';
import { isValidUrl } from '../utils/is-valid-url.tsx';
import { isTextWithinQRSizeLimit } from '../utils/is-within-qr-size-limit.tsx';

type TabFieldMapping = {
  errorMessage: string;
  fields: string[];
  validation?: (state: QRCodeGeneratorState) => boolean;
  validationError?: string;
};

export const requiredFieldsMapping: Record<Tabs, TabFieldMapping> = {
  [Tabs.Crypto]: {
    errorMessage: 'Address is required',
    fields: ['address']
  },
  [Tabs.Email]: {
    errorMessage: 'Email is required',
    fields: ['email']
  },
  [Tabs.Event]: {
    errorMessage: 'Event, Venue, Start Time and End Time are required',
    fields: ['event', 'venue', 'startTime', 'endTime']
  },
  [Tabs.GeoLocation]: {
    errorMessage: 'Latitude and Longitude are required',
    fields: ['latitude', 'longitude'],
    validationError: 'Invalid latitude or longitude'
  },
  [Tabs.MeCard]: {
    errorMessage: 'First Name, Last Name and Phone are required',
    fields: ['firstName', 'lastName', 'phone1']
  },
  [Tabs.Phone]: {
    errorMessage: 'Phone is required',
    fields: ['phone'],
    validation: (state: QRCodeGeneratorState) =>
      isValidPhoneNumber(state.phone),
    validationError: 'Invalid phone number'
  },
  [Tabs.SMS]: {
    errorMessage: 'Phone and SMS message are required',
    fields: ['phone', 'sms']
  },
  [Tabs.Text]: {
    errorMessage: 'Text is required',
    fields: ['text'],
    validation: (state: QRCodeGeneratorState) =>
      isTextWithinQRSizeLimit(state.text),
    validationError: 'Text exceeds QR size limit'
  },
  [Tabs.Url]: {
    errorMessage: 'URL is required',
    fields: ['url'],
    validation: (state: QRCodeGeneratorState) => isValidUrl(state.url),
    validationError: 'Invalid URL'
  },
  [Tabs.VCard]: {
    errorMessage: 'First Name, Last Name, Email and Phone are required',
    fields: ['firstName', 'lastName', 'email', 'phoneWork']
  },
  [Tabs.WiFi]: {
    errorMessage: 'SSID/Name & Encryption type are required',
    fields: ['ssid', 'encryption']
  },
  [Tabs.Zoom]: {
    errorMessage: 'Zoom Meeting ID and Password are required',
    fields: ['zoomId', 'zoomPass']
  }
};
