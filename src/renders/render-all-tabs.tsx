import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";
import React, {ChangeEvent} from "react";
import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state.tsx";
import {Tabs} from "../ts/enums/tabs-enum.tsx";
import {styles} from "../assets/styles.tsx";
import {DropdownField} from "../components/fields/dropdown-field.tsx";
import {InputField} from "../components/fields/input-field.tsx";
import {MapContainer} from "react-leaflet";
import {CRYPTO_TYPES} from "../constants/constants.tsx";
import {Divider} from "../components/extras/divider.tsx";
import {HandleInputChange} from "../callbacks/handle-input-change.tsx";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";
import {renderVCard} from "./render-v-card.tsx";
import {renderMeCard} from "./render-me-card.tsx";
import {RenderFieldsAsColumns} from "./render-fields-as-cols.tsx";
import {handleCryptoSelect} from "../helpers/handle-crypto-select.tsx";
import {RenderInputFields} from "./render-input-fields.tsx";

export const renderAllTabs = (
    state: QRCodeGeneratorState,
    dispatch: React.Dispatch<QRCodeGeneratorAction>,
    setError: (value: (((previousState: string) => string) | string)) => void,
    LocationPicker: React.FC,
    selectedCrypto: string,
    setSelectedCrypto: (value: (((previousState: string) => string) | string)) => void,
) => {

    const handleInputChange = HandleInputChange(state, dispatch);
    const handleCryptoChange = handleCryptoSelect(setSelectedCrypto, dispatch);
    const renderInputFields = RenderInputFields(state, dispatch, setError);
    const renderInputFieldsInColumns = RenderFieldsAsColumns(state, dispatch, setError);
    const renderVCardFields = renderVCard(state, dispatch, renderInputFieldsInColumns);
    const renderMeCardFields = renderMeCard(renderInputFieldsInColumns);

    return ({
        [Tabs.Text]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>Text</h2>
                <Divider/>
                {renderInputFields(['text'])}
            </section>
        ),
        [Tabs.Url]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>URL</h2>
                <Divider/>
                {renderInputFields(['url'])}
            </section>
        ),
        [Tabs.Email]: () => {
            return (
                <section style={styles.section}>
                    <h2 style={styles.sectionTitle}>Email</h2>
                    <Divider/>
                    {renderInputFields(['email', 'subject', 'cc', 'bcc'])}
                    <div style={styles.fieldContainer}>
                        <label style={styles.label} htmlFor="body">Enter Email Body</label>
                        <textarea
                            id="body"
                            style={{...styles.input, height: '100px'}}
                            value={state.body || ''}
                            onChange={(event: ChangeEvent<HTMLTextAreaElement>) => handleInputChange(event, 'body')}
                            placeholder="Enter your email body here"
                        ></textarea>
                    </div>
                </section>
            );
        },
        [Tabs.Phone]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>Phone</h2>
                <Divider/>
                {renderInputFields(['phone'])}
            </section>
        ),
        [Tabs.WiFi]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>WiFi Configuration</h2>
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
        ),
        [Tabs.SMS]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>SMS</h2>
                <Divider/>
                <InputField
                    keyName="phone"
                    value={state.phone}
                    handleChange={handleInputChange}
                    setError={setError}
                />
                <div style={styles.fieldContainer}>
                    <label style={styles.label} htmlFor="smsMessage">Enter SMS Message</label>
                    <textarea
                        id="smsMessage"
                        style={{...styles.input, height: '100px'}}
                        value={state.sms || ''}
                        onChange={(event: ChangeEvent<HTMLTextAreaElement>) => handleInputChange(event, 'sms')}
                        placeholder="Enter your SMS message here"
                    ></textarea>
                </div>
            </section>),
        [Tabs.Event]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>Event</h2>
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
        ),
        [Tabs.GeoLocation]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>GeoLocation</h2>
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
                    <section style={styles.section}>
                        <LocationPicker/>
                    </section>
                </MapContainer>
            </section>
        ),
        [Tabs.Crypto]: () => {
            return (
                <section style={styles.section}>
                    <h2 style={styles.sectionTitle}>Crypto</h2>
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
        }, [Tabs.Zoom]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>Zoom</h2>
                <Divider/>
                {renderInputFields(['zoomId', 'zoomPass'])}
            </section>
        ),
        [Tabs.VCard]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>VCard</h2>
                <Divider/>
                {renderVCardFields()}
            </section>
        ),
        [Tabs.MeCard]: () => {
            return (
                <section style={styles.section}>
                    <h2 style={styles.sectionTitle}>MeCard</h2>
                    <Divider/>
                    {renderMeCardFields()}
                </section>
            );
        },
    });
};
