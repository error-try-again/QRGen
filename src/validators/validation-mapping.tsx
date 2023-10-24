import { Tabs } from '../ts/enums/tabs-enum';

export const requiredFieldsMapping = {
  [Tabs.Text]: {
    errorMessage: 'Text is required',
    fields: ['text']
  },
  [Tabs.Url]: {
    errorMessage: 'URL is required',
    fields: ['url']
  },
  [Tabs.Email]: {
    errorMessage: 'Email is required',
    fields: ['email']
  },
  [Tabs.Phone]: {
    errorMessage: 'Phone is required',
    fields: ['phone']
  },
  [Tabs.WiFi]: {
    errorMessage: 'SSID is required',
    fields: ['ssid']
  },
  [Tabs.Crypto]: {
    errorMessage: 'Address is required',
    fields: ['address']
  },
  [Tabs.SMS]: {
    errorMessage: 'Phone and SMS message are required',
    fields: ['phone', 'sms']
  },
  [Tabs.Zoom]: {
    errorMessage: 'Zoom Meeting ID and Password are required',
    fields: ['zoomId', 'zoomPass']
  },
  [Tabs.GeoLocation]: {
    errorMessage: 'Latitude and Longitude are required',
    fields: ['latitude', 'longitude']
  },
  [Tabs.Event]: {
    errorMessage: 'Event, Venue, Start Time and End Time are required',
    fields: ['event', 'venue', 'startTime', 'endTime']
  },
  [Tabs.MeCard]: {
    errorMessage: 'First Name, Last Name and Phone are required',
    fields: ['firstName', 'lastName', 'phone1']
  },
  [Tabs.VCard]: {
    errorMessage: 'First Name, Last Name, Email and Phone are required',
    fields: ['firstName', 'lastName', 'email', 'phoneWork']
  }
};
