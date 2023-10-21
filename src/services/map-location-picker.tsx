import React, { memo, useEffect, useRef, useState } from 'react';
import { QRCodeGeneratorAction } from '../ts/types/reducer-types';
import { QRCodeGeneratorState } from '../ts/interfaces/qr-code-generator-state';
import L, { LatLng } from 'leaflet';
import { INITIAL_POSITION } from '../constants/constants';
import { Marker, Popup, TileLayer, useMap } from 'react-leaflet';
import { handleLocationSelect } from '../helpers/handle-location-select';
import { CustomIcon } from '../components/icons/custom-map-icon';

const LocationPickerComponent: React.FC<{
  dispatch: React.Dispatch<QRCodeGeneratorAction>;
  state: QRCodeGeneratorState;
}> = ({ dispatch, state }) => {
  const markerReference = useRef<L.Marker | null>(null);
  const [selectedPosition, setSelectedPosition] =
    useState<LatLng>(INITIAL_POSITION);
  const map = useMap();

  useEffect(() => {
    const handleMapClick = (event: L.LeafletMouseEvent) => {
      const latLng = event.latlng;
      handleLocationSelect(dispatch, setSelectedPosition)(latLng);
    };

    map.on('click', handleMapClick);

    return () => {
      map.off('click', handleMapClick);
    };
  }, [map, dispatch]);

  useEffect(() => {
    if (state.latitude && state.longitude) {
      const updatedLatLng = new LatLng(
        Number.parseFloat(state.latitude),
        Number.parseFloat(state.longitude)
      );
      setSelectedPosition(updatedLatLng);
      map.flyTo(updatedLatLng);
    }
  }, [map, state.latitude, state.longitude]);

  const eventHandlers = {
    dragend() {
      const marker = markerReference.current;
      if (marker) {
        const { lat, lng } = marker.getLatLng();
        handleLocationSelect(
          dispatch,
          setSelectedPosition
        )(new LatLng(lat, lng));
      }
    }
  };

  return (
    <>
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      />
      {selectedPosition && (
        <Marker
          position={selectedPosition}
          interactive={true}
          draggable={true}
          icon={CustomIcon}
          ref={markerReference}
          eventHandlers={eventHandlers}
        >
          <Popup>
            Latitude: {selectedPosition.lat.toFixed(4)}, Longitude:{' '}
            {selectedPosition.lng.toFixed(4)}
          </Popup>
        </Marker>
      )}
    </>
  );
};

LocationPickerComponent.displayName = 'LocationPicker';

export const LocationPicker = memo(LocationPickerComponent);
