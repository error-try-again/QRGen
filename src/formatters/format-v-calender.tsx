import {EventRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";
import {formatDatetime} from "../utils/format-date-time.tsx";

export const formatEvent = (data: EventRequest): string =>
  [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'BEGIN:VEVENT',
    `SUMMARY:${data.venue}`,
    `DTSTART:${formatDatetime(data.startTime!)}`, //! is used to tell TS that startTime is not null or undefined
    `DTEND:${formatDatetime(data.endTime!)}`,
    'END:VEVENT',
    'END:VCALENDAR'
  ].join('\n');
