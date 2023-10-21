import React from 'react';
import { QRCodeGeneratorAction } from '../ts/types/reducer-types';
import { LatLng } from 'leaflet';

export function handleLocationSelect(
  dispatch: React.Dispatch<QRCodeGeneratorAction>,
  setSelectedPosition: React.Dispatch<React.SetStateAction<LatLng>>
) {
  return (latitudeLongitude: LatLng) => {
    dispatch({
      type: 'SET_FIELD',
      field: 'latitude',
      value: latitudeLongitude.lat.toString()
    });
    dispatch({
      type: 'SET_FIELD',
      field: 'longitude',
      value: latitudeLongitude.lng.toString()
    });
    setSelectedPosition(latitudeLongitude);
  };
}
