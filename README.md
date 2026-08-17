*This project has been created as part of the 42 curriculum by mgamraou.*

# Inception

## Description
This project focuses on system administration and infrastructure architecture by requiring the deployment of a multi-service web environment using Docker and Docker Compose. The goal is to build an isolated, containerized infrastructure from scratch using custom Dockerfiles rather than relying on pre-built, ready-to-use images from Docker Hub. The architecture orchestrates Nginx (TLS terminating reverse proxy), WordPress (via PHP-FPM), and MariaDB, communicating over an internal Docker bridge network.

## Project Description

### Architecture & Design Choices
This project utilizes Docker to enforce process isolation. The infrastructure relies on three primary services, each running in a dedicated container, enforcing a strict one-process-per-container model (PID 1). 

The source code includes custom `Dockerfile` configurations for each service, initialization bash scripts to bootstrap the databases and web configurations, and a `docker-compose.yml` file to orchestrate the network rules and volume bindings. 

Key design choices include:
*   **TLS Configuration:** Nginx is strictly configured to accept only TLSv1.2 and TLSv1.3 traffic on port 443, utilizing self-signed X.509 certificates generated non-interactively via OpenSSL.
*   **Process Management:** PHP-FPM is configured with a `dynamic` process manager to optimize physical RAM usage by spawning worker processes specifically in response to TCP traffic bursts.
*   **Data Persistence:** Host bind mounts are mapped to `/home/mgamraou/data/` to ensure database and website files survive container teardowns.

### Technical Comparisons

#### Virtual Machines vs Docker
*   **Virtual Machines:** Rely on hardware-level virtualization driven by a Hypervisor. A VM allocates virtualized hardware (CPU, RAM, Disks) and boots a complete, independent guest Operating System kernel. This introduces heavy memory overhead and high boot latency.
*   **Docker:** Relies on OS-level virtualization. Containers do not boot their own kernel; they share the host machine's Linux kernel. Process isolation is achieved purely through kernel namespaces (isolating mount points, network interfaces, and process IDs) and cgroups (restricting resource consumption).

#### Secrets vs Environment Variables
*   **Secrets (Docker Swarm):** Cryptographic payloads or passwords that are securely mounted into the container's memory using a `tmpfs` filesystem (typically at `/run/secrets/`). They are never written to physical disk and are strictly isolated from the standard process environment block.
*   **Environment Variables:** Key-value pairs injected directly into the container's environment block during the `exec` phase. They are easily accessible via the `env` command and can leak if an application dumps its state, making them less secure for sensitive credentials in production environments.

#### Docker Network vs Host Network
*   **Docker Network (Bridge):** Instructs the kernel to instantiate a virtual switch (`bridge` interface) and uses `veth` pairs to connect isolated container network namespaces to it. The host applies `iptables` NAT routing to handle outbound traffic. It provides a secure, private subnet with built-in DNS resolution for inter-container communication.
*   **Host Network:** Bypasses Docker's virtual network isolation entirely. The container shares the host system's exact network namespace. If a container binds to port 80, it binds directly to the host's physical network interface card, preventing any other process on the host from using that port.

#### Docker Volumes vs Bind Mounts
*   **Docker Volumes:** Storage managed entirely by the Docker daemon (typically located in `/var/lib/docker/volumes/`). Docker controls the metadata, permissions, and lifecycle of the data independent of the host filesystem structure.
*   **Bind Mounts:** A direct mount namespace binding from a specific, explicitly defined path on the host filesystem (e.g., `/home/mgamraou/data`) directly into the container. The data lifecycle is detached from Docker, and host POSIX file permissions strictly apply to the reading and writing of data.

## Instructions

The project is orchestrated entirely via a `Makefile`. Ensure Docker and Docker Compose are installed on your host machine before proceeding. 

*Note: Before starting the environment, you must map the local domain by adding the following line to your `/etc/hosts` file:*
`127.0.0.1 mgamraou.42.fr`

### Makefile Execution Rules

*   **`make`** or **`make all`** (Compilation & Execution)
    Initializes the required host volume directories (`/home/mgamraou/data/...`), builds the custom Docker images from the provided Dockerfiles, and starts the containers in the background (`-d`).

*   **`make down`**
    Stops the running containers and removes the virtual bridge network. The physical host data and built images are preserved.

*   **`make clean`**
    Stops the containers, removes the network, and drops the internal Docker volume metadata bindings (`docker compose down -v`).

*   **`make fclean`**
    Performs a complete infrastructure teardown. It stops all services, removes the project's specific Docker images (`--rmi all`), and executes `rm -rf` to forcefully delete the persistent database and WordPress files from the physical host machine.

*   **`make re`**
    Executes a complete reset by running `fclean` followed immediately by `all`.

## Resources
*   [Docker Documentation: Network and Storage drivers](https://docs.docker.com/)
