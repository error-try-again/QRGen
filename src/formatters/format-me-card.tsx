import {MeCardRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";

export const formatMeCard = (data: MeCardRequest): string =>
  [
    'MECARD:N:',
    `${data.lastName},${data.firstName}`,
    data.nickname && `NICKNAME:${data.nickname}`,
    data.phone1 && `TEL:${data.phone1}`,
    data.phone2 && `TEL:${data.phone2}`,
    data.phone3 && `TEL:${data.phone3}`,
    data.email && `EMAIL:${data.email}`,
    data.website && `URL:${data.website}`,
    data.birthday && `BDAY:${data.birthday}`,
    data.street &&
      `ADR:${data.street},${data.city},${data.state},${data.zipcode},${data.country}`,
    data.notes && `NOTE:${data.notes}`
  ]
    .filter(Boolean)
    .join(';');
