import {UrlRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";

export function formatURL(data: UrlRequest) {
  return data.url ?? '';
}
