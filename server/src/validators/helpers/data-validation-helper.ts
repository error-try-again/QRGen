import {AllRequests, RequestTypeMap} from "../../ts/types/all-request-types";
import {QRData} from "../../ts/interfaces/helper-interfaces";
import {validators} from "../validation-mapping";

export const validateData = <T extends AllRequests>(data: QRData<T>, type: string): void => {
    if (!data || !data.customData) {
        throw new Error(`Missing data for type: ${type}`);
    }
    if (!validators[type as keyof RequestTypeMap](data.customData)) {
        throw new Error(`Invalid data for type: ${type}`);
    }
};
