import {CryptoRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";

export function formatCrypto(data: CryptoRequest) {
  return `${data.address}?amount=${data.amount ?? ''}`;
}
