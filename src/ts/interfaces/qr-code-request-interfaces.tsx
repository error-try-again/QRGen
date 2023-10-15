import {Tabs} from "../enums/tabs-enum.tsx";


export interface UrlRequest {
    url?: string;
}

export  interface TextRequest {
    text?: string;
}

export interface WifiRequest {
    ssid?: string;
    encryption?: 'WEP' | 'WPA' | 'WPA2' | 'WPA3';
    hidden?: boolean;
    password?: string;
}

export interface EmailRequest {
    email?: string;
    subject?: string;
    body?: string;
    cc?: string;
    bcc?: string;
}

export interface PhoneRequest {
    phone?: string;
}

export interface SMSRequest {
    phone?: string;
    sms?: string;
}

export interface EventRequest {
    event?: string;
    venue?: string;
    startTime?: string;
    endTime?: string;
}

export interface GeoLocationRequest {
    latitude?: string;
    longitude?: string;
}

export interface CryptoRequest {
    cryptoType?: string;
    address?: string;
    amount?: string;
}

export interface PayPalRequest {
    paypalType?: 'buy_now' | 'addToCart' | 'donate';
    paypalEmail?: string;
    paypalItemName?: string;
    paypalItemNumber?: string;
    paypalAmount?: string;
    paypalCurrency?: string;
    paypalShipping?: string;
    paypalTax?: string;
}

export interface ZoomRequest {
    zoomType?: 'join' | 'meet' | 'webinar';
    zoomId?: string;
    zoomPass?: string;
    zoomStartTime?: string;
    zoomDuration?: string;
    zoomTopic?: string;
}

export interface SkypeRequest {
    skypeType?: 'call' | 'chat';
    skypeId?: string;
}

export interface WhatsAppRequest {
    whatsappType?: 'chat' | 'call';
    whatsappId?: string;
}

export interface VCardRequest {
    version?: '2.1' | '3.0' | '4.0';
    firstName?: string;
    lastName?: string;
    organization?: string;
    position?: string;
    phoneWork?: string;
    phonePrivate?: string;
    phoneMobile?: string;
    faxWork?: string;
    faxPrivate?: string;
    email?: string;
    website?: string;
    street?: string;
    zipcode?: string;
    city?: string;
    state?: string;
    country?: string;
}

export interface MeCardRequest {
    firstName?: string;
    lastName?: string;
    nickname?: string;
    phone1?: string;
    phone2?: string;
    phone3?: string;
    email?: string;
    website?: string;
    birthday?: string;
    street?: string;
    zipcode?: string;
    city?: string;
    state?: string;
    country?: string;
    notes?: string;
}

export interface QRCodeRequest extends TextRequest, UrlRequest, WifiRequest, EmailRequest, PhoneRequest, SMSRequest, EventRequest, GeoLocationRequest, CryptoRequest, MeCardRequest, VCardRequest {
    type?: keyof typeof Tabs;
    size?: string;
    precision?: string;
}
