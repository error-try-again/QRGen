import {
  MeCardRequest,
  VCardRequest
} from '../ts/interfaces/qr-code-request-interfaces';

export const VCardFields: (keyof VCardRequest)[] = [
  'firstName',
  'lastName',
  'phoneWork',
  'email',
  'organization',
  'position',
  'phonePrivate',
  'phoneMobile',
  'faxWork',
  'faxPrivate',
  'website',
  'street',
  'zipcode',
  'city',
  'state',
  'country'
];

export const MeCardFields: (keyof MeCardRequest)[] = [
  'firstName',
  'lastName',
  'phone1',
  'nickname',
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
  'notes'
];
