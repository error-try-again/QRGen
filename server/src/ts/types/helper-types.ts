import {AllRequests} from "./all-request-types";

export type ValidatorFunction<T extends AllRequests> = (data: T) => boolean;

export type FormatHandler<T extends AllRequests> = (data: T) => string;
