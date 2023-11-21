import { useCore } from '../../hooks/use-core';
import { styles } from '../../assets/styles';
import { useHandleInputChange } from '../../hooks/callbacks/use-handle-input-change';
import { Divider } from '../extras/divider';
import { InputField } from '../fields/input-field';
import { isFieldRequired } from '../../helpers/is-field-required';
import { Tabs } from '../../ts/enums/tabs-enum';
import { QRCodeRequest } from '../../ts/interfaces/qr-code-request-interfaces';
import { MapContainer } from 'react-leaflet';
import { LocationPicker } from '../../services/map-location-picker';

export const GeoLocationTab = () => {
  const { dispatch, state, setError } = useCore();
  const { sectionTitle, section } = styles;
  const handleInputChange = useHandleInputChange();
  return (
    <section style={section}>
      <h2 style={sectionTitle}>GeoLocation</h2>
      <Divider />
      {['latitude', 'longitude'].map(key => (
        <InputField
          isRequired={isFieldRequired(Tabs.GeoLocation, key)}
          key={key}
          keyName={key as keyof QRCodeRequest}
          value={state[key as keyof QRCodeRequest] as string}
          handleChange={handleInputChange}
          setError={setError}
        />
      ))}
      <MapContainer
        center={[51.505, -0.09]}
        zoom={13}
        style={{ width: '100%', height: '300px' }}
      >
        <section style={section}>
          <LocationPicker
            state={state}
            dispatch={dispatch}
          />
        </section>
      </MapContainer>
    </section>
  );
};
