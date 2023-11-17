# QRGen

## Summary

This project aims to automate the setup of a full-stack QR code generation service within rootless, dockerized environments. 
The project is written in TS (Express), TSX (Vite/React), Bash/Shell (Automation) and has several layers.

    Installers:  
        1. Dependency installation, running depends.sh as root ensures that all of the required dependencies are present, and that the required (non-root) user is set up correctly. 
        2. Project installation, running install.sh kicks off a set of scripts that provision multiple custom docker instances, configuration files, and automated features.   
    Backend: A Node.js server powered by Express, which handles the project API. 
    Frontend: A Vite-React TSX application powered by NGINX, providing SSL termination in the case it's setup, and proxying backend queries. 
    SSL/Certbot: A custom certbot image, automatically built from sources, provides the infrastructure necessary for production SSL certificates. 

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

# Desktop Examples

### Firefox Dark

![Dark-Text1-Firefox.png](images%2FDemo%2FDark-Text1-Firefox.png)

### Firefox Light

![Demo1.png](images%2FDemo%2FDemo1.png)

### Live Demo

[Link to Live Demo - Sydney, Australia](https://qr-gen.net/)

### Tested on:

* on Ubuntu 22.04.3 LTS, jammy, 5.15.0-87-generic SMP x86_64 GNU/Linux
* on Pop!_OS 22.04 LTS, jammy, 6.5.6-76060506-generic SMP x86_64 GNU/Linux

## Local Install Instructions:

```bash
cd ~ && git clone https://github.com/error-try-again/QRGen.git && cd QRGen && chmod +x depends.sh && sudo ./depends.sh
# Select 1) Full Installation (All)
```
```bash
cd ~ && cd QRGen && machinectl shell docker-primary@ $HOME/QRGen/install.sh
# 1) Run Setup 
```

## Remote Install Instructions:

_With keys, without ssh root-login_
```bash
ssh -i .ssh/mykey default-user@myhost
sudo su
git clone https://github.com/error-try-again/QRGen.git && cd QRGen && ~/QRGen/depends.sh
# Select 1) Full Installation (All)
exit && exit 
ssh -t -i .ssh/my-other-key docker-primary@myhost /home/docker-primary/QRGen/install.sh
# 1) Run Setup 
```

_With keys, with ssh root-login_
```bash
ssh -i .ssh/mykey root@myhost "git clone https://github.com/error-try-again/QRGen.git && cd QRGen && ~/QRGen/depends.sh"
# Select 1) Full Installation (All)
ssh -t -i .ssh/my-other-key docker-primary@myhost /home/docker-primary/QRGen/install.sh
# 1) Run Setup 
```

_Without keys_
```bash
ssh root@myhost "git clone https://github.com/error-try-again/QRGen.git && cd QRGen && ~/QRGen/depends.sh"
# Select 1) Full Installation (All)
ssh docker-primary@myhost /home/docker-primary/QRGen/install.sh
# 1) Run Setup 
```

_For Default HTTP Servers_

_For Self-Signed Certificates & HTTPS Servers_

_For Lets-Encrypt Staging Certificates & Dry Run_

_For Lets-Encrypt Productions Certificates & HTTPS Servers_

# Security

### Remote 
Regardless of your particular environment, I highly recommend you make use of ssh keys, and disable password auth by setting 'PasswordAuthentication no' in /etc/ssh/sshd_config & restarting sshd

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
* Write up

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
