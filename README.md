# GLPI 11.0.0-beta2 Docker Image

This repository contains a Docker setup for GLPI 11.0.0-beta2, an open-source IT Service Management (ITSM) solution.

## Features

- Based on PHP 8.2 with Apache
- Includes MySQL 8.0 database
- Automatic directory creation and permissions setup
- Configured with PHP optimizations for GLPI
- Includes cron job setup for automated tasks
- Health check implementation
- Persistent data storage using Docker volumes

## Prerequisites

- Docker
- Docker Compose
- At least 2GB of RAM
- At least 1GB of free disk space

## Quick Start

1. Clone this repository
2. Run the following command:
   ```bash
   docker-compose up -d
   ```
3. Access GLPI at `http://localhost:8080`

## Configuration

### Environment Variables

- `TZ`: Timezone (default: UTC)
- `DB_HOST`: Database hostname (default: glpi-db)
- `DB_PORT`: Database port (default: 3306)

### Database Credentials

- Database Name: `glpi_db`
- Database User: `glpi_user`
- Database Password: `glpi_password_123`
- Root Password: `glpi_root_password_123`

### Ports

- GLPI Web Interface: `8080` (host) -> `80` (container)
- MySQL Database: `3307` (host) -> `3306` (container)

## Volumes

The following persistent volumes are created:

- `glpi_files`: GLPI files storage
- `glpi_config`: GLPI configuration files
- `glpi_mysql_data`: MySQL database data
- `glpi_mysql_config`: MySQL configuration

## Docker Images

- GLPI: Custom build from Dockerfile (PHP 8.2-Apache)
- Database: MySQL 8.0

## PHP Configuration

- Memory Limit: 256M
- Upload Max Filesize: 64M
- Post Max Size: 64M
- Max Execution Time: 600 seconds
- Secure Cookie Settings Enabled

## Maintenance

### Logs

- Apache logs are available in the standard Docker logs
- Cron jobs are logged to stdout
- Database logs are available through Docker logs

### Backup

To backup your GLPI installation, you should backup:
1. All Docker volumes
2. The MySQL database

## Security Notes

- Default database credentials should be changed in production
- The setup includes basic security configurations
- Apache is configured with proper security settings

## Contributing

Feel free to submit issues and enhancement requests.

## License

This Docker setup is provided as-is. GLPI itself is licensed under GPLv3+.