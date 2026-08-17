# User Documentation

## 1. Services Provided by the Stack
This infrastructure provides a complete, secure web hosting environment consisting of three core services:
*   **Nginx (Web Server):** Acts as the front-door reverse proxy. It receives all secure incoming traffic (HTTPS) and serves the website to the user's browser.
*   **WordPress (Content Management System):** The application itself. It processes dynamic PHP code to generate web pages, manage media, and control site content.
*   **MariaDB (Database):** The secure backend storage engine. It holds all the text content, user accounts, and configuration settings for the WordPress site.

## 2. Starting and Stopping the Project
The entire system is managed via a command-line tool called `Make` from the host machine.
*   **To start the project:** Open your terminal in the root directory of the repository and run:
    ```bash
    make all
    ```
    This initializes the data folders, builds the services, and runs them silently in the background.
*   **To stop the project:** When you are finished, you can safely shut down the services without losing your data by running:
    ```bash
    make down
    ```

## 3. Accessing the Website and Administration Panel
Before accessing the site, ensure your local `/etc/hosts` file routes the domain `mgamraou.42.fr` to `127.0.0.1`.
*   **The Public Website:** Open a web browser and navigate to `https://mgamraou.42.fr`. Because the site uses a self-signed security certificate for local development, your browser will show a security warning. Click "Advanced" (or equivalent) and proceed to the site.
*   **The Administration Panel:** To manage the content, navigate to `https://mgamraou.42.fr/wp-admin`. This provides the graphical login screen to the WordPress backend.

## 4. Locating and Managing Credentials
All user accounts and database passwords are securely centralized in an environment variable file named `.env` located in the `srcs/` directory.
*   To update a password or database user, stop the project (`make down`), edit the `.env` file with your new values, and restart the project.
*   *Security Note:* This file is strictly excluded from version control to prevent exposing sensitive credentials to the public.

## 5. Checking Service Health
To verify that the infrastructure is running smoothly, you can check the status of the active containers. From the `srcs/` directory, run:
```bash
docker compose ps
