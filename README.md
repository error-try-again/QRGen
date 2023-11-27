# QRGen - A self-hostable QR code generation service
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

![Dark-Text1-Firefox.png](examples%2FDemo%2FDark-Text1-Firefox.png)

### Firefox Light

![Demo1.png](examples%2FDemo%2FDemo1.png)

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

### For http only, localhost (frontend/in-browser qr generation)
```
...
1: Install minimal release (frontend QR generation) (Limited features)
2: Install full release (frontend QR generator and backend API/server side generation) (All features)
Please enter your choice (1/2): 1
Would you like to disable Docker build caching for this run? (yes/no):
yes
Would you like to specify a domain name other than the default (http://localhost) (yes/no)?
no
Using default domain name: localhost
Would you like to enable self-signed certificates? (yes/no):
no
```
### For self-signed https only, localhost (backend/server-side qr generation)
```
Port 8080 is already in use.
Please provide an alternate port or Ctrl+C to exit: 8081
Selected port 8081 is available.
1: Install minimal release (frontend QR generation) (Limited features)
2: Install full release (frontend QR generator and backend API/server side generation) (All features)
Please enter your choice (1/2): 2
Would you like to disable Docker build caching for this run? (yes/no):
yes
Would you like to specify a domain name other than the default (http://localhost) (yes/no)?
no
Using default domain name: localhost
Would you like to enable self-signed certificates? (yes/no):
yes
```

### For DH paramater generation - select the option that best suits you
```
Self-signed certificates for localhost generated at /home/docker-primary/QRGen/certs/live/localhost.
1: Use 2048-bit DH parameters (Faster)
2: Use 4096-bit DH parameters (More secure)
Please enter your choice (1/2): 1
Generate a Diffie-Hellman (DH) key exchange parameters file with 2048 bits...
Generating DH parameters, 2048 bit long safe prime
```

### Updating 

```
docker-primary@ubuntu:~/QRGen$ ./install.sh
Welcome to the QR Code Generator setup script!
1) Run Setup				6) Update Project
2) Run Mock Configuration		7) Stop Project Docker Containers
3) Uninstall				8) Prune All Docker Builds - Dangerous
4) Reload/Refresh			9) Quit
5) Dump logs
# Select 6)
No local changes to save
remote: Enumerating objects: 241, done.
remote: Counting objects: 100% (241/241), done.
remote: Compressing objects: 100% (133/133), done.
remote: Total 241 (delta 106), reused 218 (delta 93), pack-reused 0
Receiving objects: 100% (241/241), 48.64 KiB | 3.04 MiB/s, done.
Resolving deltas: 100% (106/106), completed with 21 local objects.
From https://github.com/error-try-again/QRGen
   477e3a5..8ef7a51  main                    -> origin/main
 * [new branch]      error-try-again-patch-1 -> origin/error-try-again-patch-1
 * [new branch]      legacy-frontend-only    -> origin/legacy-frontend-only
 * [new branch]      legacy-full-release     -> origin/legacy-full-release
 * [new branch]      submodule-support       -> origin/submodule-support
Updating 477e3a5..8ef7a51
...
Thanks for using the QR Code Generator setup script!
```
### Stop Containers
```
docker-primary@ubuntu:~/QRGen$ ./install.sh
Welcome to the QR Code Generator setup script!
1) Run Setup				6) Update Project
2) Run Mock Configuration		7) Stop Project Docker Containers
3) Uninstall				8) Prune All Docker Builds - Dangerous
4) Reload/Refresh			9) Quit
5) Dump logs
# Select 7)
Ensuring Docker environment variables are set...
Set DOCKER_HOST to unix:///run/user/1000/docker.sock
Stopping containers using docker-compose...
[+] Running 5/5
 ✔ Container qrgen-certbot-1   Removed                                                                   0.0s
 ✔ Container qrgen-frontend-1  Removed                                                                   0.6s
 ✔ Container qrgen-backend-1   Removed                                                                  10.3s
 ✔ Network qrgen_default       Removed                                                                   0.3s
 ✔ Network qrgen_qrgen         Removed                                                                   0.5s
Thanks for using the QR Code Generator setup script!
```

### Prune containers

```
Welcome to the QR Code Generator setup script!
1) Run Setup				6) Update Project
2) Run Mock Configuration		7) Stop Project Docker Containers
3) Uninstall				8) Prune All Docker Builds - Dangerous
4) Reload/Refresh			9) Quit
5) Dump logs
# Select 8)
Ensuring Docker environment variables are set...
Set DOCKER_HOST to unix:///run/user/1000/docker.sock
Identifying and purging Docker resources associated with 'qrgen'...
No 'qrgen' containers found.
Removing 'qrgen' images...
Untagged: qrgen-certbot:latest
Deleted: sha256:27274e67793b51028a72c51eb36c691eb690d1cc8eb544889a4417081cb6976c
Untagged: qrgen-frontend:latest
Deleted: sha256:087f9ead639be4602c155f1898697da569f44cbf2666e92c5d6ac581202fc860
Untagged: qrgen-backend:latest
Deleted: sha256:df2bc734be1ec8b8eac6f1febc842bedf5997a6f4b4aa3cee79a99dddc11b8a2
Removing 'qrgen' volumes...
qrgen_nginx-shared-volume
No 'qrgen' networks found.
Thanks for using the QR Code Generator setup script!
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

### Automatic Lets-Encrypt Production Certificates & HTTPS Servers Setup

```
docker-primary@ubuntu:~/QRGen$ ./install.sh
Welcome to the QR Code Generator setup script!
1) Run Setup				6) Update Project
2) Run Mock Configuration		7) Stop Project Docker Containers
3) Uninstall				8) Prune All Docker Builds - Dangerous
4) Reload/Refresh			9) Quit
5) Dump logs
# Select 1)
...
Selected port 8080 is available.
1: Install minimal release (frontend QR generation) (Limited features)
2: Install full release (frontend QR generator and backend API/server side generation) (All features)
Please enter your choice (1/2): 2
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
Please enter your choice (1/2/3): 2
...
NGINX configuration written to /home/docker-primary/QRGen/nginx.conf
Bringing down existing Docker Compose services...
Generating self-signed certificates for qr-gen.net...
/home/docker-primary/QRGen/certs/live/qr-gen.net already exists.
/home/docker-primary/QRGen/certs/dhparam already exists.
Do you want to regenerate the certificates in /home/docker-primary/QRGen/certs/live/qr-gen.net? [y/N]: y
...
Self-signed certificates for qr-gen.net generated at /home/docker-primary/QRGen/certs/live/qr-gen.net.
1: Use 2048-bit DH parameters (Faster)
2: Use 4096-bit DH parameters (More secure)
Please enter your choice (1/2): 2
Generate a Diffie-Hellman (DH) key exchange parameters file with 4096 bits...
Generating DH parameters, 4096 bit long safe prime
...
```

### Custom Lets-Encrypt Production Certificates & HTTPS Servers Setup (Full Install)
```
Port 8080 is already in use.
Please provide an alternate port or Ctrl+C to exit: 8081
Selected port 8081 is available.
1: Install minimal release (frontend QR generation) (Limited features)
2: Install full release (frontend QR generator and backend API/server side generation) (All features)
Please enter your choice (1/2): 2
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
Please enter your choice (1/2/3): 3
Please enter your Let's Encrypt email or type 'skip' to skip: skip
Would you like to use a production SSL certificate? (yes/no):
yes
Would you like to use a dry run? (yes/no):
yes
Would you like to force current certificate renewal? (yes/no):
yes
Would you like to automatically renew your SSL certificate? (yes/no):
yes
Would you like to enable HSTS? (yes/no):
yes
Would you like to enable OCSP Stapling? (yes/no):
yes
Would you like to enable Must Staple? (yes/no):
no
Would you like to enable Strict Permissions? (yes/no):
no
Would you like to enable UIR (Unique Identifier for Revocation)? (yes/no):
yes
Would you like to overwrite self-signed certificates? (yes/no):
yes
Would you like to enable TLSv1.3? (yes/no) (Recommended):
yes
Would you like to enable TLSv1.2? (yes/no):
no
...
Please enter your choice (1/2): 2
Generate a Diffie-Hellman (DH) key exchange parameters file with 4096 bits...
Generating DH parameters, 4096 bit long safe prime
...
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

### Local Install

![local-install-1.png](examples%2FLocal%2Flocal-install-1.png)

### HTTP only

![http-only.png](examples%2FLocal%2Fhttp-only.png)

### Staging environment

![auto-setup-staging.png](examples%2FGeneral%2Fauto-setup-staging.png)

### Production environment

![select-production.png](examples%2FGeneral%2Fselect-production.png)

### Self-signed SSL certificate

![regen-self-signed.png](examples%2FGeneral%2Fregen-self-signed.png)

### Pruning containers

![prune-all.png](examples%2FGeneral%2Fprune-all.png)

### Updating
![updating.png](examples%2FGeneral%2Fupdating.png)

### Stopping containers
![stop-containers.png](examples%2FGeneral%2Fstop-containers.png)
