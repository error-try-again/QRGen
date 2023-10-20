# QRGen-FullStack

## This project is designed to automate and setup two Dockerized, rootless environments to provide QR code generation

    Backend: A Node.js server powered by Express.
    Frontend: Hosted on an NGINX container, this React application with TypeScript serves as the user interface for QR code generation.

The entire project is self-hostable and has been built over a weekend. While it has been thoroughly tested, there might be some unforeseen bugs and rough edges. If you encounter any, please feel free to open an issue.

## Installation Instructions:

*Run depends to ensure that the host system has all the required dependencies*

```bash
chmod +x depends.sh
sudo ./depends.sh
```

*Run the Project as the docker-primary user to build and install the core project*

```bash
machinectl shell docker-primary@ $HOME/QRGen-FullStack/install.sh $HOME/QRGen-FullStack/       
```

*Uninstall the project*
```bash
sudo ./depends.sh uninstall
```

## Security Notes
setup-deps.sh sets the default password for docker-primary to 'test'.
This should be changed in production environments.

# Example

![image](https://github.com/error-try-again/fullstack-qr-generator/assets/19685177/1d1ef425-5ca0-402c-b2b6-914bf4c0907d)
