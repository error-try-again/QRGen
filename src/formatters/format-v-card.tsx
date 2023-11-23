import {VCardRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";

export const formatVCard = (data: VCardRequest): string =>
  [
    'BEGIN:VCARD',
    `VERSION:${data.version || '3.0'}`,
    `N:${data.lastName};${data.firstName}`,
    data.organization && `ORG:${data.organization}`,
    data.position && `TITLE:${data.position}`,
    data.phoneWork && `TEL;WORK:${data.phoneWork}`,
    data.phonePrivate && `TEL;HOME:${data.phonePrivate}`,
    data.phoneMobile && `TEL;CELL:${data.phoneMobile}`,
    data.faxWork && `TEL;WORK;FAX:${data.faxWork}`,
    data.faxPrivate && `TEL;HOME;FAX:${data.faxPrivate}`,
    data.email && `EMAIL:${data.email}`,
    data.website && `URL:${data.website}`,
    data.street &&
      `ADR:;;${data.street};${data.city};${data.state};${data.zipcode};${data.country}`,
    'END:VCARD'
  ]
    .filter(Boolean)
    .join('\n');
