import { QRCodeGeneratorState } from '../ts/interfaces/qr-code-generator-state';
import { LatLng } from 'leaflet';

export const initialState: QRCodeGeneratorState = {
  isLoading: false,
  qrCodeURL: '',
  size: '150',
  precision: 'H'
};

export const INITIAL_POSITION = new LatLng(51.505, -0.09);
export const CRYPTO_TYPES = [
  'bitcoin',
  'bitcoincash',
  'bitcoinsv',
  'ethereum',
  'litecoin',
  'dash',
  'dogecoin',
  'ripple',
  'zcash'
];

export const V_CARD_VERSION_LIST = ['4.0', '3.0', '2.1'];

export const DESKTOP_MEDIA_QUERY_THRESHOLD = 768;
