import './app.css';
import {QRCodeGenerator} from './qr-code-generator.tsx';


function App() {
    return (
        <div className="App">
            <h2>QR Code Generator</h2>
            <QRCodeGenerator />
        </div>
    );
}

export default App;
