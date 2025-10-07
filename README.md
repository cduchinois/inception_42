# Inception - École 42 Project

This is a work in progress implementation of the **Inception** project from École 42.

## Overview

The Inception project involves setting up a complete infrastructure using Docker containers to host a WordPress website with a MariaDB database and Nginx as a reverse proxy. This project is designed to run on a Linux VM.

## Project Structure

```
inception2/
├── srcs/
│   ├── docker-compose.yml
│   └── requirements/
│       ├── mariadb/
│       ├── nginx/
│       └── wordpress/
└── secrets/
    ├── credentials.txt
    ├── db_password.txt
    └── db_root_password.txt
```

## Components

- **Nginx**: Reverse proxy and web server
- **WordPress**: Content management system
- **MariaDB**: Database server

## Status

🚧 **Work in Progress** - This project is currently under development as part of the École 42 curriculum.

## Requirements

- Docker
- Docker Compose
- Linux VM environment

## Usage

```bash
# Build and start the containers
make

# Stop the containers
make down
```

## Note

This project is part of the École 42 curriculum and is designed to run in a Linux VM environment.
