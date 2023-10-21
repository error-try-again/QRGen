import { GeoLocationRequest } from '../ts/interfaces/qr-code-request-interfaces';

export function formatGeoLocation(data: GeoLocationRequest) {
  return `geo:${data.latitude},${data.longitude}`;
}
