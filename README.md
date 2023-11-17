# QRGen

## Summary

This project aims to automate the setup of a full-stack QR code generation service within rootless, dockerized environments. 

    Setup: Two Bash scripts used to orchestrate containers, setup enviornments, and install dependencies.
    Backend: A Node.js server powered by Express, written in TypeScript. 
    Frontend: A Vite-React TSX application powered by NGINX proxying requests to the backend.
    SSL: NGINX reverse proxy with SSL termination using LetsEncrypt.

The entire project is self-hostable and has been built over <s>a weekend</s> about a month.
Although it's been thoroughly tested manually at the time of writing, unit tests are still a work in progress.

There might be some unforeseen bugs and rough edges. For the future of the project, see the Roadmap section. 
If you encounter any bugs, please feel free to open an issue or a pull request so that I can investigate further.

## Features

* Self-hostable QR code generation service (Docker)
* Supports Bulk QR code generation (up to 1000 QR codes at a time)
* Supports multiple QR code formats (URL, SMS, Email, Events, Phone, Geolocation,
  Wifi, Zoom, Contact, Text)
* Supports multiple QR code sizes
* Supports multiple QR code error correction levels
* Responsive design
* Mobile friendly
* Dark mode
* QR Generation APIs (POST /qr/generate) or (POST /qr/batch)
* CORS support, Rate limiting, and other security features
* Supports Custom Domains & Subdomains
* Supports SSL termination using LetsEncrypt with automatic SSL certificate
  installation
* Supports automatic SSL certificate renewal (via cronjob)
* Supports Self-signed SSL certificates (for development environments)

### Live Demo

[Link to Live Demo - Sydney, Australia](https://qr-gen.net/)

### Tested on:

* on Ubuntu 22.04.3 LTS, jammy, 5.15.0-87-generic SMP x86_64 GNU/Linux
* on Pop!_OS 22.04 LTS, jammy, 6.5.6-76060506-generic SMP x86_64 GNU/Linux

## Local Install Instructions:

```bash
cd ~ && git clone https://github.com/error-try-again/QRGen.git && cd QRGen && chmod +x depends.sh && sudo ./depends.sh
# Select 1) Full Installation (All)
machinectl shell docker-primary@ $HOME/QRGen/install.sh
# 1) Run Setup 
```

## Remote Install Instructions:

```bash
ssh -i .ssh/mykey docker-primary@myhost "git clone https://github.com/error-try-again/QRGen.git && cd QRGen && ~/QRGen/depends.sh"
# Select 1) Full Installation (All)
ssh -t -i .ssh/mykey docker-primary@myhost /home/docker-primary/QRGen/install.sh
# 1) Run Setup 
```

# Roadmap

* Add additional client/server validation for QR code formats
* Add import mechanism for QR code generation (CSV, JSON, Excel, etc.)
* API Documentation
* CI/CD pipeline
* Improved test coverage
* Add additional deployment options (E.g. Kubernetes, etc.)
* Admin panel for tunable settings (E.g. SSL configuration, rate limiting, content
  persistence, content expiry, etc.)
* Database support (E.g. MongoDB, etc.) for hosted content persistence (E.g. QR code
  generation history, dynamic QR code generation, etc.)
* Rewrite the installer in Python
* Colour QR codes, logos & other customizations
* Add additional QR code formats (E.g. Google Reviews, etc.)

# Desktop Examples

### Firefox Dark

![Dark-Text1-Firefox.png](images%2FDemo%2FDark-Text1-Firefox.png)

### Firefox Light

![Demo1.png](images%2FDemo%2FDemo1.png)

# Setup Screenshots

### TUI

![run-setup.png](images%2FGeneral%2Frun-setup.png)

### Staging environment

![auto-setup-staging.png](images%2FGeneral%2Fauto-setup-staging.png)

### Production environment

![select-production.png](images%2FGeneral%2Fselect-production.png)

### Self-signed SSL certificate

![regen-self-signed.png](images%2FGeneral%2Fregen-self-signed.png)

### Machinectl

![machinectl.png](images%2FLocal%2Fmachinectl.png)

# Error Screenshots

![rate-limit-error.png](images%2FGeneral%2Frate-limit-error.png)
