# QRGen - A self-hostable QR code generation service
## *(Express/Backend), TSX (Vite/React/Frontend), Bash/Shell (Automation)*
## Overview

This project aims to automate the setup of a scalable, self-hostable, full-stack QR code generation
service within a rootless Docker environment, with a focus on security & ease of use.
The project has been written in TS (Express), TSX (Vite/React), Bash/Shell (Automation) and has several key layers. Each of which deserve their own companion documentation.
To address the challenge of supporting multiple stack configurations, the project has gone through several iterations since its inception. 
Currently, it is comprised of two separate git submodules that are initialized within the containers themselves at build time.

[The first submodule is an optional backend (Express)](https://github.com/error-try-again/QRGen-backend) which provides an operational mode where QR codes are generated on the server. 
This is a complex design decision and is in preparation for a full-release version of the application, which will support several additional features such as link shortening/dynamic linking, QR code generation history, administrative configuration, user accounts/auth. 
This decision aims to provide an additional layer of security to the generation process, preventing certain types of speculative malicious QR injection & redirection attacks. 
To read more about planned features, skip to the Roadmap section. 

[The second submodule is a requisite frontend (Vite/React)](https://github.com/error-try-again/QRGen-frontend) that provides a simple, responsive, and mobile-friendly UI for generating QR codes.
The module can be run in isolation or in conjunction with the backend submodule depending on your use case.

The idea was initially conceived when I found myself needing to generate a large
number of QR codes for a project, and I was unable to find a suitable self-hostable solution, so I decided to build my own. 
I hope that others find it useful too. 


*Continuous improvements and bug fixes are expected. Contributions, issues & pull requests welcome.*
If you have a specific fix for the frontend or backend envrionments, please submit your pull request to the respective submodule.


A full write up and comprehensive documentation is
underway [here](https://insomniacvoid.dev/posts/qr-gen), but for now, here's a quick
overview of the project.

### Live Demo

[Link to Live Demo - Sydney, Australia](https://qr-gen.net/)

_If the demo server is is down for maintenance, it's probably
worth checking back in a couple hours_

# Desktop Examples

### Firefox Dark

![Dark-Text1-Firefox.png](images%2FDemo%2FDark-Text1-Firefox.png)

### Firefox Light

![Demo1.png](images%2FDemo%2FDemo1.png)

## Features

_QRGen supports the the QR Code generation in the following formats for both bulk and regular code generation_

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
- Self-signed SSL certificate generation.
- LetsEncrypt certificate automation for staging & production environments.
- Automated SSL certificate renewal via cron.
- Rootless & Dockerized.
- Security features such as CORS, rate limiting, OCSP stapling, HSTS, and more.
- NGINX proxy provides multi-service integrations.  
- Provides QR Generation web APIs (POST /qr/generate) or (POST /qr/batch)

## High level project overview

    Bash:
        depends.sh:
        - A minimal dependency installer/uninstaller for apt packages, user setup, NVM setup (root)
        
        install.sh:
        - A rootless installer for docker, environment configurations, and user prompts. 
        - Automated deployment and generation of Compose config files, Dockerfiles, and dependencies.
        - Certbot command generation and more.

    Python:
        - Modified Certbot fork in a Docker container for automatic certificate mergers between self-signed and Let's Encrypt certificates.

    NGINX:
        - Proxies queries between frontend/backend services.
        - Adds security headers and handles TLS with strong cipher suites.
        - Manages ACME challenge for Certbot.

    Compose:
        - Simplifies container and volume management.
        - Manages network configuration and port assignments.

    Express Backend (TypeScript):
        - Manages query validation mappings and security features (Helmet, CORS, rate limiting.)
        - API for generating and batching QR data.

    React Frontend (TSX/Vite):
        - Utilizes React for its efficient state management and context API.
        - Vite for bundling and testing integrations.


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

_For Lets-Encrypt Production Certificates & HTTPS Servers_

*Automatic*
```
Would you like to disable Docker build caching for this run? (yes/no):
yes
Would you like to specify a domain name other than the default (http://localhost) (yes/no)?
yes
Enter your domain name (e.g., example.com): qr-gen.net
Using custom domain name: http://qr-gen.net
Would you like to specify a subdomain other than the default (none) (yes/no)?
yes
Enter your subdomain name (e.g., www): void
Using custom subdomain: http://void.qr-gen.net
1: Use Let's Encrypt SSL
2: Use self-signed SSL certificates
3: Do not enable SSL
Please enter your choice (1/2/3): 1
1: Run automatic staging setup for Let's Encrypt SSL (Recommended for testing)
2: Run automatic production setup for Let's Encrypt SSL (Recommended for production)
3: Run custom setup for Let's Encrypt SSL
Please enter your choice (1/2): 2
```

*Custom*
```
# Would you like to specify a domain name other than the default (http://localhost) (yes/no)?
# yes
# Enter your domain name (e.g., example.com): qr-gen.net
# Using custom domain name: http://qr-gen.net
# Would you like to specify a subdomain other than the default (none) (yes/no)?
# yes
# Enter your subdomain name (e.g., www): void
# Using custom subdomain: http://void.qr-gen.net
# Would you like to use Let's Encrypt SSL for qr-gen.net (yes/no)?
# yes
# Would you like to run automatic staging setup for Let's Encrypt SSL (yes/no) (Recommended)?
# no
# Please enter your Let's Encrypt email or type 'skip' to skip: skip
# Would you like to use a production SSL certificate? (yes/no):
# yes
# Would you like to use a dry run? (yes/no):
# yes
# Would you like to force current certificate renewal? (yes/no):
# yes
# Would you like to automatically renew your SSL certificate? (yes/no):
# yes
# Would you like to enable HSTS? (yes/no):
# yes
# Would you like to enable OCSP Stapling? (yes/no):
# yes
# Would you like to enable Must Staple? (yes/no):
# no
# Would you like to enable Strict Permissions? (yes/no):
# no
# Would you like to enable UIR (Unique Identifier for Revocation)? (yes/no):
# yes
# Would you like to overwrite self-signed certificates? (yes/no):
# yes
```

# Roadmap

* Additional client/server validation for QR code formats
* Add import mechanism for QR code generation (CSV, JSON, Excel, etc.)
* API Documentation
* Improved CI/CD pipeline
* Improved test coverage
* Additional deployment options (E.g. Kubernetes, etc.)
* Admin panel for tunable settings (E.g. SSL configuration, rate limiting, content
  persistence, content expiry, etc.)
* Database support (E.g. MongoDB, etc.) for hosted content persistence (E.g. QR code
  generation history, dynamic QR code generation & linking, etc.)
* Rewrite the installer in Python
* Colour QR codes, logos & other customizations
* Add additional QR code formats (E.g. Google Reviews, etc.)

# Setup Screenshots

### TUI

![run-setup.png](images%2FGeneral%2Frun-setup.png)

### Staging environment

![auto-setup-staging.png](images%2FGeneral%2Fauto-setup-staging.png)

### Production environment

![select-production.png](images%2FGeneral%2Fselect-production.png)

### Self-signed SSL certificate

![regen-self-signed.png](images%2FGeneral%2Fregen-self-signed.png)
