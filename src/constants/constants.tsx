import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state.tsx";
import {LatLng} from "leaflet";

export const initialState: QRCodeGeneratorState = {isLoading: false, qrCodeURL: "", size: "150"};
export const INITIAL_POSITION = new LatLng(51.505, -0.09);
export const CRYPTO_TYPES = ['Bitcoin', 'Bitcoin Cash', 'Ethereum', 'Litecoin', 'Dash', "Doge"];
export const DESKTOP_MEDIA_QUERY_THRESHOLD = 768;
