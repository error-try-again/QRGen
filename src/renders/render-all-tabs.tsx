import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import {ChangeEvent} from "react";
import {Tabs} from "../ts/enums/tabs-enum";
import {styles} from "../assets/styles";
import {DropdownField} from "../components/fields/dropdown-field";
import {InputField} from "../components/fields/input-field";
import {MapContainer} from "react-leaflet";
import {CRYPTO_TYPES} from "../constants/constants";
import {Divider} from "../components/extras/divider";
import {HandleInputChange} from "../callbacks/handle-input-change";
import {renderVCard} from "./render-v-card";
import {renderMeCard} from "./render-me-card";
import {RenderFieldsAsColumns} from "./render-fields-as-cols";
import {handleCryptoSelect} from "../helpers/handle-crypto-select";
import {RenderInputFields} from "./render-input-fields";
import {LocationPicker} from "../services/map-location-picker";
import {AllTabs} from "../ts/interfaces/all-tabs-interface.tsx";


export const RenderAllTabs = (
    {state, dispatch, setError, selectedCrypto, setSelectedCrypto}: AllTabs,
) => {

    const handleInputChange = HandleInputChange({dispatch: dispatch, state: state});
    const handleCryptoChange = handleCryptoSelect({dispatch: dispatch, setSelectedCrypto: setSelectedCrypto});
    const renderInputFields = RenderInputFields({state : state, dispatch : dispatch, setError : setError});
    const renderInputFieldsInColumns = RenderFieldsAsColumns({state : state, dispatch : dispatch, setError : setError});
    const renderVCardFields = renderVCard({state : state, dispatch : dispatch, renderInputFieldsInColumns : renderInputFieldsInColumns});
    const renderMeCardFields = renderMeCard({renderInputFieldsInColumns : renderInputFieldsInColumns});

    return ({
        [Tabs.Crypto]: () => {
            const {sectionTitle, section} = styles;
            return (
                <section style={section}>
                    <h2 style={sectionTitle}>Crypto</h2>
                    <Divider/>
                    {CRYPTO_TYPES.map(cryptoType => (
                        <div key={cryptoType}>
                            <input type="radio"
                                   id={cryptoType}
                                   name="cryptoType"
                                   value={cryptoType}
                                   checked={selectedCrypto === cryptoType}
                                   onChange={() => handleCryptoChange(cryptoType)}
                            />
                            <label htmlFor={cryptoType}> {cryptoType}</label><br/>
                        </div>
                    ))}
                    {selectedCrypto && (
                        <>
                            <InputField keyName="address"
                                        value={state.address}
                                        handleChange={handleInputChange}
                                        setError={setError}
                            />
                            <InputField
                                keyName="amount"
                                value={state.amount}
                                handleChange={handleInputChange}
                                setError={setError}
                            />
                        </>
                    )}
                </section>
            );
        },
        [Tabs.Email]: () => {
            const {input, sectionTitle, label, section, fieldContainer} = styles;
            return (
                <section style={section}>
                    <h2 style={sectionTitle}>Email</h2>
                    <Divider/>
                    {renderInputFields(['email', 'subject', 'cc', 'bcc'])}
                    <div style={fieldContainer}>
                        <label style={label} htmlFor="body">Enter Email Body</label>
                        <textarea
                            id="body"
                            style={{...input, height: '100px'}}
                            value={state.body || ''}
                            onChange={(event: ChangeEvent<HTMLTextAreaElement>) => handleInputChange(event, 'body')}
                            placeholder="Enter your email body here"
                        ></textarea>
                    </div>
                </section>
            );
        },
        [Tabs.Event]: () => {
            const {sectionTitle, section} = styles;
            return (
                <section style={section}>
                    <h2 style={sectionTitle}>Event</h2>
                    <Divider/>
                    {renderInputFields(['event', 'venue'])}
                    <InputField keyName="startTime"
                                value={state.startTime}
                                handleChange={handleInputChange}
                                type="datetime-local"
                                setError={setError}
                    />
                    <InputField
                        keyName="endTime"
                        value={state.endTime}
                        handleChange={handleInputChange}
                        type="datetime-local"
                        setError={setError}
                    />
                </section>
            );
        },
        [Tabs.GeoLocation]: () => {
            const {sectionTitle, section} = styles;
            return (
                <section style={section}>
                    <h2 style={sectionTitle}>GeoLocation</h2>
                    <Divider/>
                    {['latitude', 'longitude'].map(key => (
                        <InputField
                            key={key}
                            keyName={key as keyof QRCodeRequest}
                            value={state[key as keyof QRCodeRequest] as string}
                            handleChange={handleInputChange}
                            setError={setError}
                        />
                    ))}
                    <MapContainer center={[51.505, -0.09]} zoom={13} style={{width: '100%', height: '300px'}}>
                        <section style={section}>
                            <LocationPicker
                                state={state}
                                dispatch={dispatch}
                            />
                        </section>
                    </MapContainer>
                </section>
            );
        },
        [Tabs.MeCard]: () => {
            const {sectionTitle, section} = styles;
            return (
                <section style={section}>
                    <h2 style={sectionTitle}>MeCard</h2>
                    <Divider/>
                    {renderMeCardFields()}
                </section>
            );
        },
        [Tabs.Phone]: () => {
            const {sectionTitle, section} = styles;
            return (
                <section style={section}>
                    <h2 style={sectionTitle}>Phone</h2>
                    <Divider/>
                    {renderInputFields(['phone'])}
                </section>
            );
        },
        [Tabs.SMS]: () => {
            const {input, sectionTitle, label, section, fieldContainer} = styles;
            return (
                <section style={section}>
                    <h2 style={sectionTitle}>SMS</h2>
                    <Divider/>
                    <InputField
                        keyName="phone"
                        value={state.phone}
                        handleChange={handleInputChange}
                        setError={setError}
                    />
                    <div style={fieldContainer}>
                        <label style={label} htmlFor="smsMessage">Enter SMS Message</label>
                        <textarea
                            id="smsMessage"
                            style={{...input, height: '100px'}}
                            value={state.sms || ''}
                            onChange={(event: ChangeEvent<HTMLTextAreaElement>) => handleInputChange(event, 'sms')}
                            placeholder="Enter your SMS message here"
                        ></textarea>
                    </div>
                </section>);
        },
        [Tabs.Text]: () => {
            const {sectionTitle, section} = styles;
            return (
                <section style={section}>
                    <h2 style={sectionTitle}>Text</h2>
                    <Divider/>
                    {renderInputFields(['text'])}
                </section>
            );
        },
        [Tabs.Url]: () => {
            const {sectionTitle, section} = styles;
            return (
                <section style={section}>
                    <h2 style={sectionTitle}>URL</h2>
                    <Divider/>
                    {renderInputFields(['url'])}
                </section>
            );
        }, [Tabs.VCard]: () => {
            const {sectionTitle, section} = styles;
            return (
                <section style={section}>
                    <h2 style={sectionTitle}>VCard</h2>
                    <Divider/>
                    {renderVCardFields()}
                </section>
            );
        },
        [Tabs.WiFi]: () => {
            const {sectionTitle, section} = styles;
            return (
                <section style={section}>
                    <h2 style={sectionTitle}>WiFi Configuration</h2>
                    <Divider/>
                    {renderInputFields(['ssid', 'password'])}
                    <DropdownField keyName="encryption"
                                   handleChange={handleInputChange}
                                   options={['WEP', 'WPA', 'WPA2', 'WPA3']}
                                   value={state.encryption || ''}
                                   setError={setError}
                    />
                    <DropdownField keyName="hidden"
                                   handleChange={handleInputChange}
                                   options={['true', 'false']}
                                   value={state.hidden ? 'true' : 'false'}
                                   setError={setError}
                    />
                </section>
            );
        },
        [Tabs.Zoom]: () => {
            const {sectionTitle, section} = styles;
            return (
                <section style={section}>
                    <h2 style={sectionTitle}>Zoom</h2>
                    <Divider/>
                    {renderInputFields(['zoomId', 'zoomPass'])}
                </section>
            );
        },
    });
};
