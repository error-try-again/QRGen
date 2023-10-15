import {MeCardRequest, VCardRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";

export const VCardFields: (keyof VCardRequest)[] = [
    'firstName',
    'lastName',
    'organization',
    'position',
    'phoneWork',
    'phonePrivate',
    'phoneMobile',
    'faxWork',
    'faxPrivate',
    'email',
    'website',
    'street',
    'zipcode',
    'city',
    'state',
    'country',
];

export const MeCardFields: (keyof MeCardRequest)[] = [
    'firstName',
    'lastName',
    'nickname',
    'phone1',
    'phone2',
    'phone3',
    'email',
    'website',
    'birthday',
    'street',
    'zipcode',
    'city',
    'state',
    'country',
    'notes',
];
