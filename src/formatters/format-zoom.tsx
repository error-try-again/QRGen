import {ZoomRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";

export function formatZoom(data: ZoomRequest) {
  return `https://zoom.us/j/${data.zoomId}?pwd=${data.zoomPass}`;
}
