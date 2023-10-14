import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";
import {LatLng} from "leaflet";

export function handleLocationSelect(dispatch: React.Dispatch<QRCodeGeneratorAction>, setSelectedPosition: React.Dispatch<React.SetStateAction<LatLng>>) {
    return (latlng: LatLng) => {
        dispatch({type: 'SET_FIELD', field: 'latitude', value: latlng.lat.toString()});
        dispatch({type: 'SET_FIELD', field: 'longitude', value: latlng.lng.toString()});
        setSelectedPosition(latlng);
    };
}
