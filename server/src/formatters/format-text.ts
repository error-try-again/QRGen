import { TextRequest } from '../ts/interfaces/qr-code-request-interfaces';

export function formatText(data: TextRequest) {
  return data.text ?? '';
}
