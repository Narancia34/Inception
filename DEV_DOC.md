# Developer Documentation

## 1. Environment Setup (Prerequisites & Configuration)
### Prerequisites
*   **Operating System:** A Linux environment or Virtual Machine (Debian recommended).
*   **Binaries:** `docker`, `docker compose` (v2 architecture), and `make` must be installed on the host.
*   **Host Routing:** You must edit your `/etc/hosts` file to map `mgamraou.42.fr` to `127.0.0.1`.

### Configuration Files and Secrets
The infrastructure relies on a strictly defined `.env` file placed inside the `srcs/` directory. This file is parsed by Docker Compose to dynamically inject state and credentials into the containers during the execution phase.
1. Navigate to the `srcs/` directory.
2. Create a file named `.env`.
3. Define the following variables required by the initialization scripts:
    ```env
    # Database Configuration
    DATA_BASE=wordpress_db
    DB_USER=wp_user
    DB_PASSWORD=your_secure_password
    DB_ROOT_PASSWORD=your_root_password

    # WordPress Configuration
    DOMAIN_NAME=mgamraou.42.fr
    WP_ADMIN_USER=admin
    WP_ADMIN_PASSWORD=admin_password
    WP_ADMIN_EMAIL=admin@service.domain_extention
    WP_USER=author
    WP_USER_PASSWORD=author_password
    WP_USER_EMAIL=author@service.domain_extention
    ```

## 2. Building and Launching the Project
The build lifecycle is strictly governed by the root `Makefile`, which acts as an execution wrapper around Docker Compose.
To execute a clean build from scratch:
```bash
make all
