import {Tabs} from "../ts/enums/tabs-enum.tsx";

export const requiredFieldsMapping = {
    [Tabs.Text]: {fields: ['text'], errorMessage: "Text is required"},
    [Tabs.Url]: {fields: ['url'], errorMessage: "URL is required"},
    [Tabs.Email]: {fields: ['email'], errorMessage: "Email is required"},
    [Tabs.Phone]: {fields: ['phone'], errorMessage: "Phone is required"},
    [Tabs.WiFi]: {fields: ['ssid'], errorMessage: "SSID is required"},
    [Tabs.SMS]: {fields: ['phone', 'sms'], errorMessage: "Phone and SMS message are required"},
    [Tabs.Event]: {fields: ['event', 'venue', 'startTime', 'endTime'], errorMessage: "Event, Venue, Start Time and End Time are required"},
    [Tabs.GeoLocation]: {fields: ['latitude', 'longitude'], errorMessage: "Latitude and Longitude are required"},
    [Tabs.Crypto]: {fields: ['address'], errorMessage: "Address is required"},
    [Tabs.MeCard]: {fields: ['firstName', 'lastName', 'phone1'], errorMessage: "First Name, Last Name and Phone are required"},
    [Tabs.VCard]: {fields: ['firstName', 'lastName', 'email', 'phoneWork'], errorMessage: "First Name, Last Name, Email and Phone are required"},
    [Tabs.Zoom]: {fields: ['zoomId', 'zoomPass'], errorMessage: "Zoom Meeting ID and Password are required"},
};
