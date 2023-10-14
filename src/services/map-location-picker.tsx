import React, {useEffect, useRef, useState} from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";
import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state.tsx";
import L, {LatLng} from "leaflet";
import {INITIAL_POSITION} from "../constants/constants.tsx";
import {Marker, Popup, TileLayer, useMap} from "react-leaflet";
import {handleLocationSelect} from "../helpers/handle-location-select.tsx";
import {CustomIcon} from "../components/custom-map-icon.tsx";

export function MapLocationPicker(dispatch: React.Dispatch<QRCodeGeneratorAction>, state: QRCodeGeneratorState) {
    const LocationPicker: React.FC = React.memo(() => {
        const markerReference = useRef<L.Marker | null>(null);
        const [selectedPosition, setSelectedPosition] = useState<LatLng>(INITIAL_POSITION);
        const map = useMap();

        useEffect(() => {
            const handleMapClick = (event: L.LeafletMouseEvent) => {
                const latlng = event.latlng;
                handleLocationSelect(dispatch, setSelectedPosition)(latlng);
            };

            map.on('click', handleMapClick);

            return () => {
                map.off('click', handleMapClick);
            };
        }, [map]);

        useEffect(() => {
            if (state.latitude && state.longitude) {
                const updatedLatLng = new LatLng(Number.parseFloat(state.latitude), Number.parseFloat(state.longitude));
                setSelectedPosition(updatedLatLng);
                map.flyTo(updatedLatLng);
            }
        }, [map]);


        const eventHandlers = {
            dragend() {
                const marker = markerReference.current;
                if (marker) {
                    const {lat, lng} = marker.getLatLng();
                    handleLocationSelect(dispatch, setSelectedPosition)(new LatLng(lat, lng));
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
                        eventHandlers={eventHandlers}>
                        <Popup>
                            Latitude: {selectedPosition.lat.toFixed(4)},
                            Longitude: {selectedPosition.lng.toFixed(4)}
                        </Popup>
                    </Marker>
                )}
            </>
        );
    });
    return LocationPicker;
}
