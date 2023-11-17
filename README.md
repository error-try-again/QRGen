# QRGen

## Summary

This project aims to automate the setup of a scalable full-stack QR code generation
service within a rootless Docker environment, with a focus on security, ease of use,
and simplicity. The project is written in TS (Express), TSX (Vite/React),
Bash/Shell (Automation) and has several key layers.

The idea was initially conceived when I found myself needing to generate a large
number of QR codes for a project, and I was unable to find a suitable
self-hostable solution. I decided to build my own, and QRGen was born.

The project is free because I was so damn sick of seeing QR code generation
services monetizing the hell out of their users. I hope others find it useful and
can make use of what I've built here.

The project is self-hostable and has been developed over approximately a month.
It's undergone extensive manual testing. Continuous improvements and bug fixes are
expected, with contributions welcome.

A full write up and comprehensive documentation is coming soon, but for now,
here's a quick overview of the project.

## Features

_QRGen supports the following formats for regular and bulk QR code generation (E.g.
1000+ QR codes at once):_

- Text
- URLs & links
- SMS
- Email
- Events
- Phone
- Geolocation
- Wifi
- Zoom
- Digital Contact Cards
- Crypto Currencies

_UI_

- Dark mode, responsive, and mobile-friendly design.

_Tech_

- Self-hostable QR code generation
    - Supports custom domains and subdomains, custom ports, etc.
    - Various formats and sizes, with multiple error correction levels.
    - Highly automated & scalable.
    - Supports multiple environments (development, staging, production, etc.)
        - Self-signed SSL certificate support for development environments. (TLS
          1.2 & 1.3)
        - LetsEncrypt support for staging & production environments.
        - Automated SSL certificate renewal via cron.
- Rootless & Dockerized.
- Security features: CORS, rate limiting, OCSP stapling, HSTS, and more.
- Provides QR Generation web APIs (POST /qr/generate) or (POST /qr/batch)

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

## Local Setup:

_Run the dependency installation script_

```bash
cd ~ && git clone https://github.com/error-try-again/QRGen.git && cd QRGen && chmod +x depends.sh && sudo ./depends.sh
# Select 1) Full Installation (All)
```

_Enter into a new shell with the newly created user, run project installation
script._

```bash
cd ~ && cd QRGen && machinectl shell docker-primary@ $HOME/QRGen/install.sh
# 1) Run Setup 
```

_For Default HTTP Servers_

_For Self-Signed Certificates & HTTPS Servers_

_For Lets-Encrypt Staging Certificates & Dry Run_

_For Lets-Encrypt Productions Certificates & HTTPS Servers_

## Remote Setup:

### Step 1

_With keys, without ssh root-login, run the dependency installation script_

```bash
# Connect to your remote host
ssh -i .ssh/<yourkey> <generic-user>@<hostip>

# Download dependency installer
wget https://raw.githubusercontent.com/error-try-again/QRGen/main/depends.sh && chmod +x depends.sh

# Elevate user
sudo su

# Run dependency installer 
sudo ./depends.sh
# Select 1) Full Installation (All)

# Exit root user, exit ssh session
exit && exit

```

### Step 2

_Create fresh user ssh key, run the project installation script_

```bash
# Setup fresh user key locally
ssh-keygen
ssh-copy-id -i ~/.ssh/<a-fresh-public-key> docker-primary@<hostip>

# Use your fresh key to remote in & install the project
ssh -t -i .ssh/<a-fresh-public-key> docker-primary@<hostip> "cd ~ && git clone https://github.com/error-try-again/QRGen.git && cd QRGen && /home/docker-primary/QRGen/install.sh"
# 1) Run Setup 
```

_For Default HTTP Servers_

_For Self-Signed Certificates & HTTPS Servers_

_For Lets-Encrypt Staging Certificates & Dry Run_

_For Lets-Encrypt Productions Certificates & HTTPS Servers_

# Security Recommendations

### Remote

- Regardless of your particular environment, I highly recommend you make use of ssh
  keys, and disable password auth by setting 'PasswordAuthentication no' in
  /etc/ssh/sshd_config & restarting sshd.

- More to come. (E.g. Fail2Ban, etc.)

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

## LetsEncrypt Rate Limit Example

![rate-limit-error.png](images%2FGeneral%2Frate-limit-error.png)
