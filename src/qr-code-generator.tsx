import React, {ChangeEvent, useCallback, useEffect, useMemo, useReducer, useRef, useState} from 'react';
import {MapContainer, Marker, Popup, TileLayer, useMap} from 'react-leaflet';
import L, {LatLng} from 'leaflet';
import 'leaflet/dist/leaflet.css';
import useMediaQuery from './hooks/use-media-query.tsx';
import {styles} from './assets/styles.tsx';
import {useTheme} from "./hooks/use-theme.tsx";
import {ThemeProvider} from "./contexts/theme-context.tsx";
import {Tabs} from "./ts/enums/tabs-enum.tsx";
import {MeCardRequest, QRCodeRequest, VCardRequest} from "./ts/interfaces/qr-code-request-types.tsx";
import {QRCodeGeneratorProperties} from "./ts/interfaces/util-types.tsx";
import {QRCodeGeneratorAction} from "./ts/types/reducer-types.tsx";
import {ErrorBoundary} from "./wrappers/error-boundary.tsx";
import {CustomIcon} from "./components/custom-map-icon.tsx";
import {DropdownField} from "./components/dropdown-field.tsx";
import {TabButton} from "./components/tab-button.tsx";
import {InputField} from "./components/input-field.tsx";
import {convertValueToString} from "./util/convert-to-string.tsx";
import {QRCodeGeneratorState} from "./ts/interfaces/qr-code-generator-state.tsx";
import {areValidCcBcc} from "./util/are-valid-cc-bcc.tsx";


const INITIAL_POSITION = new LatLng(51.505, -0.09);
const CRYPTO_TYPES = ['Bitcoin', 'Bitcoin Cash', 'Ethereum', 'Litecoin', 'Dash', "Doge"];
const initialState: QRCodeGeneratorState = {isLoading: false, qrCodeURL: "", size: "150"};

const VCardFields: (keyof VCardRequest)[] = [
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

const MeCardFields: (keyof MeCardRequest)[] = [
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

// State reducer that handles setting the state based on the action type and payload
// Allows managing complex state changes in a single function
const qrCodeReducer = (state: QRCodeGeneratorState, action: QRCodeGeneratorAction): QRCodeGeneratorState => {
    switch (action.type) {
        case 'SET_FIELD': {
            return {...state, [action.field]: action.value};
        }
        case 'SET_LOADING': {
            return {...state, isLoading: action.value};
        }
        case 'SET_QRCODE_URL': {
            return {...state, qrCodeURL: action.value, isLoading: false};
        }
        case 'RESET_STATE': {
            return {...initialState};
        }
        default: {
            return state;
        }
    }
};

function incrementBatchCount(setQrBatchCount: React.Dispatch<React.SetStateAction<number>>) {
    return () => {
        setQrBatchCount((previous: number) => previous + 1);
    };
}

function handleLocationSelect(dispatch: React.Dispatch<QRCodeGeneratorAction>, setSelectedPosition: React.Dispatch<React.SetStateAction<LatLng>>) {
    return (latlng: LatLng) => {
        dispatch({type: 'SET_FIELD', field: 'latitude', value: latlng.lat.toString()});
        dispatch({type: 'SET_FIELD', field: 'longitude', value: latlng.lng.toString()});
        setSelectedPosition(latlng);
    };
}

const QrCodeGenerator: React.FC<QRCodeGeneratorProperties> = () => {
    const [state, dispatch] = useReducer(qrCodeReducer, initialState);
    const [activeTab, setTab] = useState<Tabs>(Tabs.Text);
    const [selectedCrypto, setSelectedCrypto] = useState<string>('Bitcoin');
    const [error, setError] = useState<string>("");
    const [qrBatchCount, setQrBatchCount] = useState<number>(0); // Add state to keep track of batch count
    const [batchData, setBatchData] = useState<QRCodeRequest[]>([]);

    const {theme, toggleTheme} = useTheme();

    const containerStyles = useMemo(() => ({
        ...styles.themeContainer,
        backgroundColor: theme === 'light' ? 'white' : 'black',
        color: theme === 'light' ? 'black' : 'white',
    }), [theme]);

    const resetBatchAndLoadingState = () => {
        setBatchData([]);
        setQrBatchCount(0);
        dispatch({type: 'SET_LOADING', value: false});
    };


    const addToBatch = () => {
        const dataWithCorrectType = {...state, type: Tabs[activeTab]};
        addDataToBatch(dataWithCorrectType);
        incrementBatchCount(setQrBatchCount);
    };

    const addDataToBatch = (data: QRCodeRequest) => {
        if (!data.type) {
            console.error("Data does not have a 'type' property.");
            return;
        }
        setBatchData((previousBatch: QRCodeRequest[]) => [...previousBatch, data]);
    };

    const handleCryptoChange = (cryptoType: string) => {
        setSelectedCrypto(cryptoType);
        dispatch({type: 'SET_FIELD', field: 'cryptoType', value: cryptoType});
    };

    const handleInputChange = useCallback((event: ChangeEvent<HTMLElement & {
        value: string
    }>, fieldName: keyof QRCodeRequest) => {
        const value = event.target.value;
        dispatch({type: 'SET_FIELD', field: fieldName, value});
    }, []);

    const handleTabChange = (freshTab: Tabs) => {
        setError("");
        resetBatchAndLoadingState();
        dispatch({type: 'SET_QRCODE_URL', value: ""});
        dispatch({type: 'RESET_STATE'});
        setTab(freshTab);
    };

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
            console.log("State:", state);
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
            <div>
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
            </div>
        );
    });

    const validateInput = () => {
        const requiredFieldsMapping = {
            [Tabs.Text]: {fields: ['text'], errorMessage: "Text is required"},
            [Tabs.Url]: {fields: ['url'], errorMessage: "URL is required"},
            [Tabs.Email]: {fields: ['email'], errorMessage: "Email is required"},
            [Tabs.Phone]: {fields: ['phone'], errorMessage: "Phone is required"},
            [Tabs.WiFi]: {fields: ['ssid'], errorMessage: "SSID is required"},
            [Tabs.SMS]: {fields: ['phone', 'sms'], errorMessage: "Phone and SMS message are required"},
            [Tabs.Event]: {fields: ['event', 'venue', 'startTime', 'endTime'], errorMessage: "Event, Venue, Start Time and End Time are required"},
            [Tabs.GeoLocation]: {fields: ['latitude', 'longitude'], errorMessage: "Latitude and Longitude are required"},
            [Tabs.Crypto]: {fields: ['address'], errorMessage: "Address is required"},
            [Tabs.MeCard]: {fields: ['firstName', 'lastName', 'phone1'], errorMessage: "First Name, Last Name and Phone are required"},
            [Tabs.VCard]: {fields: ['firstName', 'lastName', 'email', 'phoneWork'], errorMessage: "First Name, Last Name, Email and Phone are required"}
        };

        const requiredFields = requiredFieldsMapping[activeTab];

        if (requiredFields) {
            for (const field of requiredFields.fields) {
                if (!state[field as keyof typeof state]) {
                    setError(requiredFields.errorMessage);
                    resetBatchAndLoadingState();
                    return false;
                }
            }
            if (activeTab === Tabs.Email) {
                if (state.cc && !areValidCcBcc(state.cc)) {
                    setError("One or more CC emails are invalid");
                    resetBatchAndLoadingState();
                    return false;
                }
                if (state.bcc && !areValidCcBcc(state.bcc)) {
                    setError("One or more BCC emails are invalid");
                    resetBatchAndLoadingState();
                    return false;
                }
            }
            return true;
        } else {
            return true;
        }
    };

    const generateQRCode = async () => {
        if (!validateInput()) {
            return;
        }

        dispatch({type: 'SET_LOADING', value: true});

        const isBatch = qrBatchCount > 1;
        const endpoint = isBatch ? '/batch' : '/generate';
        const requestData = isBatch ? {qrCodes: batchData} : {
            ...state,
            type: Tabs[activeTab]
        };

        try {
            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(requestData)
            });

            if (!response.ok) {
                await handleErrorResponse(response);
                return;
            }

            if (response.status === 429) {
                setError('You have exceeded the rate limit. Please try again later.');
                resetBatchAndLoadingState();
                return;
            }

            isBatch ? await handleBatchResponse(response) : await handleSingleResponse(response);

        } catch (error: unknown) {
            if (error instanceof Error) {
                handleFetchError(error);
            } else {
                setError("Unknown error.");
                resetBatchAndLoadingState();
            }
        }
    };

    const handleErrorResponse = async (response: Response) => {
        const result = await response.json();
        setError(result.message || 'Unknown error.');
        resetBatchAndLoadingState();
    };

    const handleBatchResponse = async (response: Response) => {
        const blob = await response.blob();
        const href = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = href;
        link.download = 'qrCodes.zip';
        document.body.append(link);
        link.click();
        link.remove();
        setError("");
        resetBatchAndLoadingState();
    };

    const handleSingleResponse = async (response: Response) => {
        const result = await response.json();
        dispatch({type: 'SET_QRCODE_URL', value: result.qrCodeURL});
        setError("");
        resetBatchAndLoadingState();
    };

    const handleFetchError = (error: Error) => {
        const errorMessage = 'Failed to generate the QR code. Please try again later.';
        console.error("Error:", error.message);

        setError(errorMessage);
        dispatch({type: 'SET_QRCODE_URL', value: ""});
        resetBatchAndLoadingState();
    };


    const renderInputFields = React.useMemo(() => (keys: (keyof QRCodeRequest)[]) => (
        <>
            {keys.map(key => {
                const convertedValue = convertValueToString(state[key]);
                return (
                    <InputField key={key.toString()}
                                keyName={key}
                                value={convertedValue}
                                handleChange={handleInputChange}
                                setError={setError}/>
                );
            })}
            {
                () => {
                    setError("");
                }
            }
        </>
    ), [handleInputChange, state]);

    const FieldSet: React.FC<{ fields: (keyof QRCodeRequest)[], state: QRCodeRequest }> = ({fields, state}) => {
        const isDesktop = useMediaQuery('(min-width: 760px)');
        const halfLength = fields.length / 2;

        const renderFields = (slice: (keyof QRCodeRequest)[]) => slice.map((key) => (
            <InputField
                key={key.toString()}
                keyName={key}
                value={state[key]}
                handleChange={handleInputChange}
                setError={setError}
            />
        ));

        return isDesktop ? (
            <div style={styles.renderBizCardsContainer}>
                <div style={styles.bizCardsColumn}>
                    {renderFields(fields.slice(0, halfLength))}
                </div>
                <div style={styles.bizCardsColumn}>
                    {renderFields(fields.slice(halfLength))}
                </div>
            </div>
        ) : (
            <div style={styles.renderBizCardsContainer}>
                <div style={styles.bizCardsColumnMobile}>
                    {renderFields(fields)}
                </div>
            </div>
        );
    };

    const renderVCardFields = () => (
        <>
            <div style={styles.fieldContainer}>
                <p style={styles.label}>vCard Version</p>
                {['2.1', '3.0', '4.0'].map(version => (
                    <div key={version}>
                        <input type="radio"
                               id={`version_${version}`}
                               name="version"
                               value={version}
                               checked={state.version === version}
                               onChange={(event: React.ChangeEvent<HTMLInputElement>) => handleInputChange(event, 'version')}
                        />
                        <label htmlFor={`version_${version}`}> {version}</label>
                    </div>
                ))}
            </div>
            <FieldSet fields={VCardFields} state={state}/>
        </>
    );

    const renderMeCardFields = () => <FieldSet fields={MeCardFields} state={state}/>;

    const TabSections = {
        [Tabs.Text]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>Text</h2>
                {renderInputFields(['text'])}
            </section>
        ),
        [Tabs.Url]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>URL</h2>
                {renderInputFields(['url'])}
            </section>
        ),
        [Tabs.Email]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>Email</h2>
                <InputField
                    keyName="email"
                    value={state.email}
                    handleChange={handleInputChange}
                    setError={setError}
                />
                <InputField
                    keyName="subject"
                    value={state.subject}
                    handleChange={handleInputChange}
                    setError={setError}
                />
                <InputField
                    keyName="cc"
                    value={state.cc}
                    handleChange={handleInputChange}
                    setError={setError}
                />
                <InputField
                    keyName="bcc"
                    value={state.bcc}
                    handleChange={handleInputChange}
                    setError={setError}
                />
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
        ),
        [Tabs.Phone]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>Phone</h2>
                {renderInputFields(['phone'])}
            </section>
        ),
        [Tabs.WiFi]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>WiFi Configuration</h2>
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
        [Tabs.Crypto]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>Crypto</h2>
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
        ), [Tabs.VCard]: () => (
            <section style={styles.section}>
                <h2 style={styles.sectionTitle}>VCard</h2>
                {renderVCardFields()}
            </section>
        ), [Tabs.MeCard]: () => {
            return (
                <section style={styles.section}>
                    <h2 style={styles.sectionTitle}>MeCard</h2>
                    {renderMeCardFields()}
                </section>
            );
        },
    };

    return <div style={containerStyles}>
        <div style={styles.tabContainer}>
            <button
                style={
                    {
                        ...styles.tabButton,
                    }
                }
                onClick={toggleTheme}>
                {
                    theme === 'light' ? <span role="img" aria-label="dark mode">Dark Mode 🌙</span> :
                        <span role="img" aria-label="light mode">Light Mode ☀️</span>
                }
            </button>
            <div>
                {Object.values(Tabs).map((tab: Tabs) => (
                    <TabButton
                        key={tab}
                        activeTab={activeTab}
                        tab={tab}
                        label={tab}
                        handleTabChange={handleTabChange}
                        setTab={setTab}
                    />
                ))}
            </div>

            {TabSections[activeTab]?.()}
            {error && <div style={styles.errorContainer}>{error}</div>}

            <div style={styles.qrButtonsContainer}>
                <button onClick={addToBatch}
                        style={styles.generateButton}
                        aria-label="Add To Bulk"
                        aria-busy={state.isLoading}>
                    Add To Bulk
                </button>
                <button style={styles.generateButton}
                        onClick={generateQRCode}
                        aria-label="Generate QR Code"
                        aria-busy={state.isLoading}>
                    {qrBatchCount >= 1 ? `Generate Zip (${qrBatchCount})` : 'Generate QR Code'}
                </button>
            </div>

            {state.qrCodeURL && <div style={styles.qrCodeContainer}>
                <img src={state.qrCodeURL}
                     alt="Generated QR Code"
                     style={{width: `${state.size}px`, height: `${state.size}px`}}
                     onError={(event: React.SyntheticEvent<HTMLImageElement>) => console.error('Image Error:', event)}
                />
                <a href={state.qrCodeURL} download="QRCode.png">
                    Download QR Code
                </a>
            </div>}
        </div>
    </div>;
};

const WrappedQRCodeGenerator = () => (
    <ThemeProvider>
        <ErrorBoundary>
            <QrCodeGenerator/>
        </ErrorBoundary>
    </ThemeProvider>
);

export {WrappedQRCodeGenerator as QRCodeGenerator};
