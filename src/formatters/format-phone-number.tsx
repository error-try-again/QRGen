import {PhoneRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";

export function formatPhone(data: PhoneRequest) {
  return `tel:${data.phone}`;
}
