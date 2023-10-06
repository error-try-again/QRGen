// src/App.tsx
import React from 'react';
import './App.css';
import {QRCodeGenerator} from './QRCodeGenerator';

function App() {
    return (
        <div className="App">
            <h1>QR Code Generator</h1>
            <QRCodeGenerator />
        </div>
    );
}

export default App;
