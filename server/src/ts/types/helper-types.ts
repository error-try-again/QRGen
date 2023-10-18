import {AllRequests} from "./all-request-types";

export type FormatHandler<T extends AllRequests> = (data: T) => string;
