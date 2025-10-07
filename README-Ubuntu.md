# Inception2 - Ubuntu Linux Deployment

This is the Ubuntu Linux version of the inception project, adapted from the macOS version.

## Key Differences from macOS Version

1. **Volume Paths**: Updated to use `/home/yuewang/data/` instead of `/Users/yuewang/data/`
2. **OS Compatibility**: All Dockerfiles use Debian base images which are fully compatible with Ubuntu
3. **Makefile**: Uses `$(HOME)` variable which works on both macOS and Linux

## Prerequisites

- Ubuntu Linux system
- Docker and Docker Compose installed
- User with sudo privileges (for /etc/hosts modification)

## Deployment Steps

1. Ensure Docker is installed and running:
   ```bash
   sudo systemctl status docker
   ```

2. Clone or copy this project to your Ubuntu system

3. Run the deployment:
   ```bash
   make all
   ```

## File Structure

The project maintains the exact same structure as the original:
- `srcs/docker-compose.yml` - Main compose file with Ubuntu-compatible volume paths
- `srcs/.env` - Environment variables
- `secrets/` - Contains password files
- `srcs/requirements/` - Individual service Dockerfiles and configurations

## Notes

- The Makefile will automatically create the required data directories under `$HOME/data/`
- The /etc/hosts file will be updated to map the domain name to localhost
- All Docker images are built from Debian base images ensuring Ubuntu compatibility