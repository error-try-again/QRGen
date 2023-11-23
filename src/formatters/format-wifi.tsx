import {WifiRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";

export function formatWiFi(data: WifiRequest) {
  return `WIFI:T:${data.encryption};S:${data.ssid};P:${data.password};H:${
    data.hidden ? 1 : 0
  };`;
}
