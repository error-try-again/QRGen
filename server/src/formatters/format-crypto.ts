import { CryptoRequest } from '../ts/interfaces/qr-code-request-interfaces';

export function formatCrypto(data: CryptoRequest) {
  return `${data.address}?amount=${data.amount ?? ''}`;
}
