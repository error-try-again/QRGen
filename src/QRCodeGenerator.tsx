import React, { useState } from 'react';

interface QRCodeGeneratorProps {}

interface QRCodeRequest {
    text: string;
    url: string;
    wifi: string;
    email: string;
    phone: string;
    size: string;
}

const QRCodeGenerator: React.FC<QRCodeGeneratorProps> = () => {
    const [fields, setFields] = useState<QRCodeRequest>({
        text: "",
        url: "",
        wifi: "",
        email: "",
        phone: "",
        size: "150",
    });
    const [qrCodeURL, setQrCodeURL] = useState<string | null>(null);

    const validateFields = (): boolean => {
        if (!Object.values(fields).some(field => {
            return field.trim();
        })) {
            alert('Please enter at least one value to generate a QR code.');
            return false;
        }
        if (fields.email && !/\S+@\S+\.\S+/.test(fields.email)) {
            alert('Please enter a valid email address.');
            return false;
        }
        if (fields.phone && !/^\+?\d{10,15}$/.test(fields.phone)) {
            alert('Please enter a valid phone number.');
            return false;
        }
        return true;
    };

    const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>, fieldName: keyof QRCodeRequest) => {
        setFields((previousState: QRCodeRequest) => {
            return ({...previousState, [fieldName]: e.target.value});
        });
    };

    const generateQRCode = async () => {
        if (!validateFields()) {
            return;
        }

        try {
            const response = await fetch('/generate', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(fields),
            });

            const result = await response.json();

            if (result.qrCodeURL) {
                setQrCodeURL(result.qrCodeURL);
            } else {
                alert(result.message || 'Unknown error.');
            }
        } catch (error: any) {
            console.error("Error:", error.message);
            alert('Error occurred while generating the QR Code.');
        }
    };


    return (
        <div style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: '10px'
        }}>
            <div style={{
                display: 'flex',
                flexDirection: 'column',
                gap: '10px'
            }}>
                {Object.keys(fields).map(key => (
                    <input
                        key={key}
                        style={{
                            padding: '5px',
                            fontSize: '16px',
                            width: '300px',
                            borderRadius: '4px',
                            border: '1px solid #ccc'
                        }}
                        value={(fields as any)[key]}
                        onChange={(error: React.ChangeEvent<HTMLInputElement>) => {
                            handleInputChange(error, key as keyof QRCodeRequest);
                        }}
                        placeholder={`Enter ${key}`}
                    />
                ))}
            </div>
            <button style={{
                padding: '10px 20px',
                fontSize: '16px',
                cursor: 'pointer',
                borderRadius: '4px',
                border: 'none',
                backgroundColor: '#007BFF',
                color: 'white'
            }} onClick={generateQRCode}>Generate</button>
            {qrCodeURL && (
                <div style={{
                    marginTop: '20px',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    gap: '10px',
                    marginBottom: '20px'
                }}>
                    <img src={qrCodeURL} alt="Generated QR Code" style={{ width: `${fields.size}px`, height: `${fields.size}px` }} />
                    <a href={qrCodeURL} download="QRCode.png">Download QR Code</a>
                </div>
            )}
        </div>
    );
};

export { QRCodeGenerator };
