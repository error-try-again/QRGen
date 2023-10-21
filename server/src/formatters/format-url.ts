import { UrlRequest } from '../ts/interfaces/qr-code-request-interfaces';

export function formatURL(data: UrlRequest) {
  return data.url ?? '';
}
