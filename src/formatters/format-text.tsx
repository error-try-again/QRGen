import {TextRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";

export function formatText(data: TextRequest) {
  return data.text ?? '';
}
