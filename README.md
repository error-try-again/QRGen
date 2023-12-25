![qrgen](https://github.com/error-try-again/QRGen/assets/19685177/d3bdf77b-62c1-48d6-bbeb-c49236651ebd)
# QRGen - A self-hostable Fullstack QR code generation service
## *TS (Express/Backend), TSX (Vite/React/Frontend), Bash/Shell (Automation)*
## Overview

This project aims to automate the setup of a scalable, self-hostable, full-stack QR code generation
service within a rootless Docker environment, with a focus on security & ease of use.
The project has been written in TS (Express), TSX (Vite/React), Bash/Shell (Automation) and has several key layers. Each of which deserve their own companion documentation.
To address the challenge of supporting multiple stack configurations, the project has gone through several iterations since its inception. 
Currently, it is comprised of two separate git submodules that are initialized within the containers themselves at build time.

*Note: If you're looking for a version of this project that does not use submodules and instead copies sources from the host/docker-primary user, see the legacy branch.*

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
If you have a specific fix for the frontend or backend environments, please submit your pull request to the respective submodule/repo.

A full write up and comprehensive documentation is
underway [here](https://insomniacvoid.dev/posts/qr-gen), but for now, here's a quick
overview of the project.

### Live Demo

[Link to Live Demo - Sydney, Australia](https://qr-gen.net/)

_If the demo server is is down for maintenance, it's probably
worth checking back in a couple hours_

# Desktop Examples

### Firefox Dark

![Dark-Text1-Firefox.png](examples%2FDemo%2FDark-Text1-Firefox.png "Firefox Dark Example Screenshot")

### Firefox Light

![Demo1.png](examples%2FDemo%2FDemo1.png "Firefox Light Example Screenshot")

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
- Google Reviews (user provided API key)

_UI_

- Dark mode, responsive, and mobile/tablet friendly design with a focus on accessibility and usability.

![mobile-dark.png](examples%2FDemo%2Fmobile-dark.png "Dark Mode Mobile Example Screenshot")

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
        - Manages virtual network configuration and associated port assignments.

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
```
```bash
Welcome to the QR Code Generator setup script!
1) Run Setup				6) Update Project
2) Run Mock Configuration		7) Stop Project Docker Containers
3) Uninstall				8) Prune All Docker Builds - Dangerous
4) Reload/Refresh			9) Quit
5) Dump logs
# Select 1)
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
# Select 1)
```

## Usage

For a more detailed usage guide, [head over to the project documentation](https://insomniacvoid.dev/posts/using-qr-gen).

### Healthcheck Setup (Optional)

[Guide to Installing Upptime on a Self-Hosted Runner](https://insomniacvoid.dev/posts/gh-self-hosted-runner)

# Roadmap

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
* Logo options & other customizations


# Setup Screenshots

### Local Install

![local-install-1.png](examples%2FLocal%2Flocal-install-1.png "Local Install Screenshot")

### HTTP only

![http-only.png](examples%2FLocal%2Fhttp-only.png "HTTP Only Screenshot")

### Staging environment

![auto-setup-staging.png](examples%2FGeneral%2Fauto-setup-staging.png "Auto Setup Staging Screenshot")

### Production environment

![select-production.png](examples%2FGeneral%2Fselect-production.png "Select Production Environment Screenshot")

### Self-signed SSL certificate

![regen-self-signed.png](examples%2FGeneral%2Fregen-self-signed.png "Self-signed SSL Certificate Screenshot")

### Pruning containers

![prune-all.png](examples%2FGeneral%2Fprune-all.png "Prune All Containers Screenshot")

### Updating
![updating.png](examples%2FGeneral%2Fupdating.png "Updating Screenshot")

### Stopping containers
![stop-containers.png](examples%2FGeneral%2Fstop-containers.png "Stopping Containers Screenshot")
