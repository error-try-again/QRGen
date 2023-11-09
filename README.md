# QRGen-FullStack

## Summary

This project aims to automate the setup of a full-stack QR code generation service within rootless, dockerized
environments.

    Setup: Two Bash scripts used to orchestrate containers, setup enviornments, and install dependencies.
    Backend: A Node.js server powered by Express, written in TypeScript. 
    Frontend: A Vite-React TSX application powered by NGINX proxying requests to the backend.
    SSL: NGINX reverse proxy with SSL termination using LetsEncrypt.

The entire project is self-hostable and has been built over <s>a weekend</s> three weeks.
Although it's been thoroughly tested manually at the time of writing, unit tests are still a work in progress.

There might be some unforeseen bugs and rough edges. For the future roadmap, skip to the the bottom of this README.
If you encounter any bugs, please feel free to open an issue or a pull request so that I can investigate further.

## Features

* Self-hostable QR code generation service (Docker)
* Supports Bulk QR code generation (up to 1000 QR codes at a time)
* Supports multiple QR code formats (URL, SMS, Email, Events, Phone, Geolocation, Wifi, Zoom, Contact, Text)
* Supports multiple QR code sizes
* Supports multiple QR code error correction levels
* QR Generation APIs (POST /qr/generate) or (POST /qr/batch)
* CORS support, Rate limiting, and other security features
* Responsive design
* Mobile friendly
* Dark mode

### Tested on:

* on Ubuntu 22.04.3 LTS, jammy, 5.15.0-87-generic SMP x86_64 GNU/Linux
* on Pop!_OS 22.04 LTS, jammy, 6.5.6-76060506-generic SMP x86_64 GNU/Linux

## Installation Instructions:

```bash
cd ~ && git clone https://github.com/error-try-again/QRGen-FullStack.git && cd QRGen-FullStack
```

_Ensures that the host system has all the required dependencies_

```bash
chmod +x depends.sh
sudo ./depends.sh
```

_If you are running the project locally, you must use the following command to build and install the core project_

```bash
machinectl shell docker-primary@ $HOME/QRGen-FullStack/install.sh $HOME/QRGen-FullStack/
```

_If you are running the project on a remote server, you must use the following command to build and install the core
project_

```bash
ssh -t <user>@<host> "./$HOME/QRGen-FullStack/install.sh $HOME/QRGen-FullStack/"
```

_If you are already logged in remotely_

```bash
./install.sh
# Select run
```

_Uninstall the project_

```bash
sudo ./depends.sh uninstall
./install.sh
# Select cleanup
```

## Security Notes

setup-deps.sh sets the default password for docker-primary to 'test'.
This should be changed in production environments.

# Roadmap

* Add additional client/server validation for QR code formats
* Add import mechanism for QR code generation (CSV, JSON, Excel, etc.)
* API Documentation
* CI/CD pipeline
* Test coverage
* Add additional deployment options (E.g. Kubernetes, etc.)
* Admin panel for tunable settings (E.g. SSL configuration, rate limiting, content persistence, content expiry, etc.)
* Database support (E.g. MongoDB, etc.) for hosted content persistence (E.g. QR code generation history, dynamic QR code
  generation, etc.)
* Rewrite the installer in Python
