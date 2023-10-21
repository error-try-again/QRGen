import { PhoneRequest } from '../ts/interfaces/qr-code-request-interfaces';

export function formatPhone(data: PhoneRequest) {
  return `tel:${data.phone}`;
}
