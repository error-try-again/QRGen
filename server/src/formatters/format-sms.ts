import { SMSRequest } from '../ts/interfaces/qr-code-request-interfaces';

export function formatSMS(data: SMSRequest) {
  return `sms:${data.phone}?body=${data.sms}`;
}
