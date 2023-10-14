import {AllRequests, RequestTypeMap} from "../ts/types/all-request-types";
import {formatters} from "../formatters/format-mapping";
import {sanitizeInput} from "./sanitize-input";

export const handleDataTypeSwitching = <T extends AllRequests>(type: string, data: T): string => {
    if (!Object.keys(formatters).includes(type)) {
        throw new Error("Invalid type provided.");
    }
    return formatters[type as keyof RequestTypeMap](sanitizeInput(data));
};
