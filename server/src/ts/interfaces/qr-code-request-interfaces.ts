export interface UrlRequest {
    url?: string;
}

export interface TextRequest {
    text?: string;
}

export interface WifiRequest {
    encryption?: 'WEP' | 'WPA' | 'WPA2' | 'WPA3';
    hidden?: boolean;
    password?: string;
    ssid?: string;
}

export interface EmailRequest {
    bcc?: string;
    body?: string;
    cc?: string;
    email?: string;
    subject?: string;
}

export interface PhoneRequest {
    phone?: string;
}

export interface SMSRequest {
    phone?: string;
    sms?: string;
}

export interface EventRequest {
    endTime?: string;
    event?: string;
    startTime?: string;
    venue?: string;
}

export interface GeoLocationRequest {
    latitude?: string;
    longitude?: string;
}

export interface CryptoRequest {
    address?: string;
    amount?: string;
    cryptoType?: string;
}

export interface ZoomRequest {
    zoomId?: string;
    zoomPass?: string;
}

export interface VCardRequest {
    version?: '2.1' | '3.0' | '4.0';
    city?: string;
    country?: string;
    email?: string;
    faxPrivate?: string;
    faxWork?: string;
    firstName?: string;
    lastName?: string;
    organization?: string;
    phoneMobile?: string;
    phonePrivate?: string;
    phoneWork?: string;
    position?: string;
    state?: string;
    street?: string;
    website?: string;
    zipcode?: string;
}

export interface MeCardRequest {
    birthday?: string;
    city?: string;
    country?: string;
    email?: string;
    firstName?: string;
    lastName?: string;
    nickname?: string;
    notes?: string;
    phone1?: string;
    phone2?: string;
    phone3?: string;
    state?: string;
    street?: string;
    website?: string;
    zipcode?: string;
}
