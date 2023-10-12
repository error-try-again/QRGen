import React, {
    ChangeEvent,
    CSSProperties,
    ReactNode,
    createContext,
    useContext,
    useCallback,
    useReducer,
    useState,
    useEffect,
    useRef,
    useMemo
} from 'react';
import {MapContainer, Marker, Popup, TileLayer, useMap} from 'react-leaflet';
import {LatLng} from 'leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import iconMarker from 'leaflet/dist/images/marker-icon.png'
import iconRetina from 'leaflet/dist/images/marker-icon-2x.png'
import iconShadow from 'leaflet/dist/images/marker-shadow.png'
import useMediaQuery from './hooks/useMediaQuery';

const customIcon = L.icon({
    iconRetinaUrl: iconRetina,
    iconUrl: iconMarker,
    shadowUrl: iconShadow,
    iconSize: [25, 41],
    iconAnchor: [12, 41], // Positions the tip of the marker at the exact location.
});

const INITIAL_POSITION = new LatLng(51.505, -0.09);
const CRYPTO_TYPES = ['Bitcoin', 'Bitcoin Cash', 'Ethereum', 'Litecoin', 'Dash', "Doge"];

const initialState: QRCodeGeneratorState = {isLoading: false, qrCodeURL: null, size: "150"};

const styles: { [key: string]: CSSProperties } = {
    bizCardsColumn: {
        flex: '1',
        minWidth: '300px',
    },
    bizCardsColumnMobile: {
        flex: '1',
        margin: '0 10px',
        minWidth: '300px',
        flexBasis: '100%',
    },
    dropdown: {
        border: '1px solid #ccc',
        borderRadius: '4px',
        fontSize: '16px',
        padding: '5px',
        width: '100%'
    },
    errorContainer: {
        backgroundColor: '#d78b8b',
        border: '1px solid red',
        borderRadius: '4px',
        padding: '10px',
        marginBottom: '20px',
        textAlign: 'center',
        fontWeight: 'bold'
    },
    fieldContainer: {
        display: 'flex',
        flexDirection: 'column',
        gap: '10px',
        marginBottom: '10px',
        width: '100%'
    },
    generateButton: {
        fontSize: '14px',
        padding: '8px 15px',
    },
    input: {
        border: '1px solid #ccc',
        borderRadius: '4px',
        fontSize: '16px',
        padding: '5px'
    },
    label: {
        fontSize: '14px',
        marginBottom: '5px'
    },
    notice: {
        color: 'red',
        marginBottom: '10px',
    },
    qrButtonsContainer: {
        display: 'flex',
        gap: '10px',
        marginBottom: '10px',
        width: '100%'
    },
    qrCodeContainer: {
        alignItems: 'center',
        display: 'flex',
        flexDirection: 'column',
        gap: '10px',
        marginTop: '20px'
    },
    renderBizCardsContainer: {
        display: 'flex',
        flexDirection: 'row',
        gap: '10px',
        marginBottom: '10px',
        width: '100%',
        justifyContent: 'space-between',
    },
    section: {
        marginBottom: '20px',
    },
    sectionTitle: {
        fontSize: '18px',
        marginBottom: '10px',
        textAlign: 'center'
    },
    tabButton: {
        padding: '5px 10px',
        margin: '2px',
        fontSize: '12px',
    },
    tabContainer: {
        display: 'flex',
        flexWrap: 'wrap',
        overflowX: 'auto',
        gap: '5px',
        marginBottom: '10px',
        textAlign: 'initial'
    },
    themeContainer: {
        alignItems: 'center',
        display: 'flex',
        flexDirection: 'column',
        gap: '20px',
        margin: '0 auto',
        maxWidth: '400px',
        padding: '20px 0',
    },

};

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

const ThemeProvider: React.FC<ThemeProviderProps> = ({children}) => {
    const [theme, setTheme] = useState('light'); // default theme is light

    useEffect(() => {
        // Update the document body styles based on the theme
        document.body.style.backgroundColor = theme === 'light' ? 'white' : 'black';
        document.body.style.color = theme === 'light' ? 'black' : 'white';

        // Override default display behavior
        document.body.style.display = 'block'
    }, [theme]);

    const toggleTheme = () => {
        if (theme === 'light') {
            setTheme('dark');
        } else {
            setTheme('light');
        }
    };

    return (
        <ThemeContext.Provider value={{theme, toggleTheme}}>
            {children}
        </ThemeContext.Provider>
    );
};

const useTheme = (): ThemeContextType => {
    const context = useContext(ThemeContext);
    if (!context) {
        throw new Error('useTheme must be used within a ThemeProvider');
    }
    return context;
};

interface ThemeContextType {
    theme: string;
    toggleTheme: () => void;
}

interface ThemeProviderProps {
    children: ReactNode;
}

interface QRCodeGeneratorProps {
    children?: ReactNode;
}

interface UrlRequest {
    url?: string;
}

interface TextRequest {
    text?: string;
}

interface WifiRequest {
    ssid?: string;
    encryption?: 'WEP' | 'WPA' | 'WPA2' | 'WPA3';
    hidden?: boolean;
    password?: string;
}

interface EmailRequest {
    email?: string;
    subject?: string;
    body?: string;
}

interface PhoneRequest {
    phone?: string;
}

interface SMSRequest {
    phone?: string;
    sms?: string;
}

interface EventRequest {
    event?: string;
    venue?: string;
    startTime?: string;
    endTime?: string;
}

interface GeoLocationRequest {
    latitude?: string;
    longitude?: string;
}

interface CryptoRequest {
    cryptoType?: string;
    address?: string;
    amount?: string;
}

interface VCardRequest {
    version?: '2.1' | '3.0' | '4.0';
    firstName?: string;
    lastName?: string;
    organization?: string;
    position?: string;
    phoneWork?: string;
    phonePrivate?: string;
    phoneMobile?: string;
    faxWork?: string;
    faxPrivate?: string;
    email?: string;
    website?: string;
    street?: string;
    zipcode?: string;
    city?: string;
    state?: string;
    country?: string;
}

interface MeCardRequest {
    firstName?: string;
    lastName?: string;
    nickname?: string;
    phone1?: string;
    phone2?: string;
    phone3?: string;
    email?: string;
    website?: string;
    birthday?: string;
    street?: string;
    zipcode?: string;
    city?: string;
    state?: string;
    country?: string;
    notes?: string;
}

interface ErrorBoundaryProps {
    children: ReactNode;
}

interface QRCodeGeneratorState extends QRCodeRequest {
    isLoading: boolean;
    qrCodeURL: string | null;
}

interface QRCodeRequest extends TextRequest, UrlRequest, WifiRequest, EmailRequest, PhoneRequest, SMSRequest, EventRequest, GeoLocationRequest, CryptoRequest, MeCardRequest, VCardRequest {
    type?: keyof typeof Tabs;
    size?: string;
}

enum Tabs {
    Text = 'Text',
    Url = 'Url',
    Email = 'Email',
    Phone = 'Phone',
    WiFi = 'WiFi',
    SMS = 'SMS',
    Event = 'Event',
    GeoLocation = 'GeoLocation',
    Crypto = 'Crypto',
    MeCard = 'MeCard',
    VCard = 'VCard',
}

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

class ErrorBoundary extends React.Component<ErrorBoundaryProps> {
    state = {hasError: false};

    static getDerivedStateFromError(error: Error) {
        console.error(error);
        return {hasError: true};
    }

    componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
        console.error("ErrorBoundary caught an error", error, errorInfo);
    }

    render() {
        if (this.state.hasError) {
            return (
                <div>
                    <h1>Something went wrong. Please try again later.</h1>
                    <a href="/report-error">Report this error</a>
                </div>
            );
        }
        return this.props.children;
    }
}

type QRCodeGeneratorAction =
    | { type: 'SET_FIELD'; field: keyof QRCodeRequest; value: any }
    | { type: 'SET_LOADING'; value: boolean }
    | { type: 'SET_QRCODE_URL'; value: string | null }
    | { type: 'RESET_STATE' };

// State reducer that handles setting the state based on the action type and payload
// Allows managing complex state changes in a single function
const qrCodeReducer = (state: QRCodeGeneratorState, action: QRCodeGeneratorAction): QRCodeGeneratorState => {
    switch (action.type) {
        case 'SET_FIELD':
            return {...state, [action.field]: action.value};
        case 'SET_LOADING':
            return {...state, isLoading: action.value};
        case 'SET_QRCODE_URL':
            return {...state, qrCodeURL: action.value, isLoading: false};
        case 'RESET_STATE':
            return {...initialState};
        default:
            return state;
    }
};

const InputField: React.FC<{
    keyName: keyof QRCodeRequest,
    value: any,
    type?: string,
    setError: React.Dispatch<React.SetStateAction<string | null>>,
    handleChange: (event: ChangeEvent<HTMLInputElement>, fieldName: keyof QRCodeRequest) => void
}> = React.memo(({keyName, value, type = 'text', handleChange, setError}) => {
    const friendlyKeyName = keyName.charAt(0).toUpperCase() + keyName.slice(1).replace(/([A-Z])/g, ' $1'); // Converts "cryptoType" to "Crypto Type"
    return (
        <div style={styles.fieldContainer}>
            <label style={styles.label} htmlFor={String(keyName)}>Enter {friendlyKeyName}</label>
            <input
                type={type}
                id={String(keyName)}
                style={styles.input}
                value={value || ''}
                onChange={(e: ChangeEvent<HTMLInputElement>) => handleChange(e, keyName)}
                onFocus={() => setError(null)}
                placeholder={`Enter ${friendlyKeyName}`}
            />
        </div>
    );
});

const DropdownField: React.FC<{
    keyName: keyof QRCodeRequest,
    options: string[],
    value: any,
    setError: React.Dispatch<React.SetStateAction<string | null>>,
    handleChange: (event: ChangeEvent<HTMLSelectElement>, fieldName: keyof QRCodeRequest) => void
}> = React.memo(({keyName, options, value, handleChange, setError}) => {
    const friendlyKeyName = keyName.charAt(0).toUpperCase() + keyName.slice(1).replace(/([A-Z])/g, ' $1');
    return (
        <div style={styles.fieldContainer}>
            <label style={styles.label} htmlFor={String(keyName)}>Select {friendlyKeyName}</label>
            <select
                id={String(keyName)}
                style={styles.dropdown}
                value={value || ''}
                onChange={(e: React.ChangeEvent<HTMLSelectElement>) => {
                    handleChange(e, keyName);
                }}
                onFocus={() => setError(null)}>
                <option value="">{`-- Choose ${friendlyKeyName} --`}</option>
                // Updated for clarity
                {options.map((option: string) => (<option key={option} value={option}>{option}</option>))}
            </select>
        </div>
    );
});


const QRCodeGenerator: React.FC<QRCodeGeneratorProps> = () => {
    const [state, dispatch] = useReducer(qrCodeReducer, initialState);
    const [activeTab, setTab] = useState<Tabs>(Tabs.Text);
    const [selectedCrypto, setSelectedCrypto] = useState<string>('Bitcoin');
    const [error, setError] = useState<string | null>(null);
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

    const incrementBatchCount = () => {
        setQrBatchCount((prev: number) => prev + 1);
    };

    const addToBatch = () => {
        let dataWithCorrectType = {...state, type: Tabs[activeTab]};
        addDataToBatch(dataWithCorrectType);
        incrementBatchCount();
    };

    const addDataToBatch = (data: QRCodeRequest) => {
        if (!data.type) {
            console.error("Data does not have a 'type' property.");
            return;
        }
        setBatchData((prevBatch: QRCodeRequest[]) => [...prevBatch, data]);
    };

    const handleInputChange = useCallback((event: ChangeEvent<HTMLElement & {
        value: string
    }>, fieldName: keyof QRCodeRequest) => {
        const value = event.target.value;
        dispatch({type: 'SET_FIELD', field: fieldName, value});
    }, []);

    const handleTabChange = (newTab: Tabs) => {
        setError(null);
        resetBatchAndLoadingState();
        dispatch({type: 'SET_QRCODE_URL', value: null});
        dispatch({type: 'RESET_STATE'});
        setTab(newTab);
    };

    const TabButton: React.FC<{
        activeTab: Tabs,
        tab: Tabs,
        label: string,
        setTab: React.Dispatch<React.SetStateAction<Tabs>>
    }> = React.memo(({activeTab, tab, label}) => {
        return (
            <button onClick={() => handleTabChange(tab)}
                    style={{...styles.tabButton, borderBottom: activeTab === tab ? '2px solid blue' : 'none'}}>
                {label}
            </button>
        );
    });

    const LocationPicker: React.FC = React.memo(() => {
        const markerRef = useRef<L.Marker | null>(null);
        const [selectedPosition, setSelectedPosition] = useState<LatLng>(INITIAL_POSITION);
        const map = useMap();

        const handleMapClick = (event: L.LeafletMouseEvent) => {
            const latlng = event.latlng;
            handleLocationSelect(latlng);
        };

        const handleLocationSelect = (latlng: LatLng) => {
            dispatch({type: 'SET_FIELD', field: 'latitude', value: latlng.lat.toString()});
            dispatch({type: 'SET_FIELD', field: 'longitude', value: latlng.lng.toString()});
            setSelectedPosition(latlng);
        };


        useEffect(() => {
            map.on('click', handleMapClick);

            return () => {
                map.off('click', handleMapClick);
            };
        }, [map, handleLocationSelect]);

        useEffect(() => {
            if (state.latitude && state.longitude) {
                const newLatLng = new LatLng(parseFloat(state.latitude), parseFloat(state.longitude));
                setSelectedPosition(newLatLng);
                map.flyTo(newLatLng);
            }
        }, [state.latitude, state.longitude, map]);


        const eventHandlers = {
            dragend() {
                const marker = markerRef.current;
                if (marker) {
                    const {lat, lng} = marker.getLatLng();
                    handleLocationSelect(new LatLng(lat, lng));
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
                        icon={customIcon}
                        ref={markerRef}
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

    const handleCryptoChange = (cryptoType: string) => {
        setSelectedCrypto(cryptoType);
        dispatch({type: 'SET_FIELD', field: 'cryptoType', value: cryptoType});
    };
    const validateInput = () => {
        const {GeoLocation, Email, MeCard, Text, VCard, Crypto, SMS, Phone, WiFi, Url, Event} = Tabs;
        switch (activeTab) {
            case Text:
                if (!state.text) {
                    setError("Text is required");
                    resetBatchAndLoadingState();
                    return false;
                }
                break;
            case Url:
                if (!state.url) {
                    setError("URL is required");
                    resetBatchAndLoadingState();
                    return false;
                }
                break;
            case Email:
                if (!state.email) {
                    setError("Email is required");
                    resetBatchAndLoadingState();
                    return false;
                }
                break;
            case Phone:
                if (!state.phone) {
                    setError("Phone is required");
                    resetBatchAndLoadingState();
                    return false;
                }
                break;
            case WiFi:
                if (!state.ssid) {
                    setError("SSID is required");
                    resetBatchAndLoadingState();
                    return false;
                }
                break;
            case SMS:
                if (!state.phone || !state.sms) {
                    setError("Phone and SMS message are required");
                    resetBatchAndLoadingState();
                    return false;
                }
                break;
            case Event:
                if (!state.event || !state.venue || !state.startTime || !state.endTime) {
                    setError("Event, Venue, Start Time and End Time are required");
                    resetBatchAndLoadingState();
                    return false;
                }
                break;
            case GeoLocation:
                if (!state.latitude || !state.longitude) {
                    setError("Latitude and Longitude are required");
                    resetBatchAndLoadingState();
                    return false;
                }
                break;
            case Crypto:
                if (!state.address) {
                    setError("Address is required");
                    resetBatchAndLoadingState();
                    return false;
                }
                break;
            case MeCard:
                if (!state.firstName || !state.lastName || !state.phone1) {
                    setError("First Name, Last Name and Phone are required");
                    resetBatchAndLoadingState();
                    return false;
                }
                break;
            case VCard:
                if (!state.firstName || !state.lastName || !state.email || !state.phoneWork) {
                    setError("First Name, Last Name, Email and Phone are required");
                    resetBatchAndLoadingState();
                    return false;
                }
                break;
            default:
                break;
        }
        return true;
    };
    // @ts-ignore
    const generateQRCode = async () => {
        if (!validateInput()) {
            return;
        }
        dispatch({type: 'SET_LOADING', value: true});

        let dataToSend: QRCodeRequest = {...state};
        dataToSend.type = Tabs[activeTab];

        try {
            // Use /batch if qrBatchCount is more than 1.
            const endpoint = qrBatchCount > 1 ? '/batch' : '/generate';
            const requestData = qrBatchCount > 1 ? {qrCodes: batchData} : dataToSend;

            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(requestData)
            });

            if (!response.ok) {
                const result = await response.json();
                setError(result.message || 'Unknown error.');
                resetBatchAndLoadingState();
                return;
            }

            if (response.status === 429) {
                setError('You have exceeded the rate limit. Please try again later.');
                resetBatchAndLoadingState();
                return;
            }

            if (qrBatchCount > 1) {
                const blob = await response.blob();
                const href = window.URL.createObjectURL(blob);
                const link = document.createElement('a');
                link.href = href;
                link.download = 'qrCodes.zip';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                setError(null);
                resetBatchAndLoadingState();
            } else {
                const result = await response.json();
                dispatch({type: 'SET_QRCODE_URL', value: result.qrCodeURL});
                setError(null);
                resetBatchAndLoadingState();
            }

        } catch (error: any) {
            console.error("Error:", error.message);
            setError('Failed to generate the QR code. Please try again later.');
            dispatch({type: 'SET_QRCODE_URL', value: null});
            resetBatchAndLoadingState();
        }
    };

    const renderInputFields = React.useMemo(() => (keys: (keyof QRCodeRequest)[]) => (
        <>
            {keys.map(key => (
                <InputField key={key.toString()}
                            keyName={key}
                            value={state[key]}
                            handleChange={handleInputChange}
                            setError={setError}/>
            ))}
            {
                () => {
                    setError(null);
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

        if (isDesktop) {
            return (
                <div style={styles.renderBizCardsContainer}>
                    <div style={styles.bizCardsColumn}>
                        {renderFields(fields.slice(0, halfLength))}
                    </div>
                    <div style={styles.bizCardsColumn}>
                        {renderFields(fields.slice(halfLength))}
                    </div>
                </div>
            );
        } else {
            return (
                <div style={styles.renderBizCardsContainer}>
                    <div style={styles.bizCardsColumnMobile}>
                        {renderFields(fields)}
                    </div>
                </div>
            );
        }
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
                               onChange={(e: React.ChangeEvent<HTMLInputElement>) => handleInputChange(e, 'version')}
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
                <div style={styles.fieldContainer}>
                    <label style={styles.label} htmlFor="body">Enter Email Body</label>
                    <textarea
                        id="body"
                        style={{...styles.input, height: '100px'}}
                        value={state.body || ''}
                        onChange={(e: ChangeEvent<HTMLTextAreaElement>) => handleInputChange(e, 'body')}
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
                        onChange={(e: ChangeEvent<HTMLTextAreaElement>) => handleInputChange(e, 'sms')}
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
                        value={state[key as keyof QRCodeRequest]}
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
                     onError={(e: React.SyntheticEvent<HTMLImageElement>) => console.error('Image Error:', e)}
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
            <QRCodeGenerator/>
        </ErrorBoundary>
    </ThemeProvider>
);

export {WrappedQRCodeGenerator as QRCodeGenerator};
